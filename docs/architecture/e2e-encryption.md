# End-to-End Encryption Design

Nexterm encrypts all sensitive user data on the device before it ever leaves the app. The sync server stores only ciphertext; no plaintext credentials or SSH configurations are transmitted or stored server-side.

---

## Threat Model

| Threat | Mitigation |
|--------|-----------|
| Server breach | Server stores only AES-256-GCM ciphertext; no keys |
| Network interception | HTTPS transit + client-side encryption |
| Device theft | Master password required on app open; biometric session cache |
| Backup file theft | Backup files are AES-256-GCM encrypted with the master key |
| Forgotten master password | Recovery key (stored separately by the user) |

---

## Cryptographic Primitives

| Primitive | Algorithm | Library |
|-----------|-----------|---------|
| Symmetric encryption | AES-256-GCM | pointycastle (`GCMBlockCipher`) |
| Key derivation | PBKDF2-HMAC-SHA256 | pointycastle (`PBKDF2KeyDerivator`) |
| CSPRNG | Fortuna | pointycastle (`FortunaRandom`) |
| Secure key storage | OS Keychain / Keystore | flutter_secure_storage |
| Biometric unlock | Face ID / Touch ID | local_auth |

---

## Master Password → Encryption Key Derivation

```
User enters master password
         │
         ▼
CryptoService.deriveKey(password, salt, iterations: 100_000)
         │
         ├─► PBKDF2-HMAC-SHA256
         │     input  : UTF-8 bytes of password
         │     salt   : 32 random bytes (stored in flutter_secure_storage)
         │     rounds : 100,000
         │     output : 32 bytes (256 bits)
         │
         ▼
encryptionKey: Uint8List(32)   ← held in memory during the session
```

The derived key is **never persisted to disk**. It lives only in memory for the duration of the unlocked session. The salt is stored in the OS secure enclave (flutter_secure_storage) so the same password always derives the same key.

---

## AES-256-GCM Encrypt / Decrypt

### Encrypt

```
CryptoService.encrypt(plaintext: List<int>, key: Uint8List) → Uint8List

1. Generate 12-byte random IV via FortunaRandom
2. Initialise GCMBlockCipher(AESEngine) in encryption mode
     key  : 256-bit key
     iv   : 12-byte IV
     aad  : empty (no additional authenticated data)
     tagLen: 128 bits (16 bytes)
3. Process plaintext → ciphertext (same length as input)
4. doFinal → appends 16-byte GCM authentication tag
5. Return: [ IV (12) | ciphertext (N) | tag (16) ]
                                              total = N + 28 bytes
```

### Decrypt

```
CryptoService.decrypt(data: Uint8List, key: Uint8List) → Uint8List

1. Split: iv = data[0..12), ciphertextAndTag = data[12..)
2. Initialise GCMBlockCipher in decryption mode
3. processBytes + doFinal → verifies GCM tag, throws on mismatch
4. Return plaintext (N bytes)
```

GCM authentication ensures integrity: any bit-flip in the ciphertext, IV, or tag causes decryption to throw an exception, preventing silent data corruption.

---

## Sync Record Wire Format

Each sync record sent to or received from the server carries:

```
SyncRecord {
  id              : UUID (client-generated, public)
  user_id         : UUID (server-assigned at registration)
  record_type     : "host" | "ssh_key" | "snippet" | "port_forward"
  encrypted_payload : base64( ciphertext + tag )   // N + 16 bytes
  iv              : base64( 12-byte GCM IV )
  updated_at      : ISO-8601 UTC timestamp
  is_deleted      : boolean (soft-delete)
  version         : integer (optimistic concurrency)
}
```

The server never sees the plaintext. `record_type` and `id` are the only metadata available to the server.

### Client-side encrypt before push

```
SyncService.encryptRecord(plainRecord: Map<String, dynamic>)

1. jsonEncode(plainRecord)  →  UTF-8 bytes
2. CryptoService.encrypt(bytes, encryptionKey)
     →  [ IV(12) | ciphertext | tag(16) ]
3. Split: iv = encrypted[0..12), payload = encrypted[12..)
4. Return: {
     "iv": base64(iv),
     "encrypted_payload": base64(payload)
   }
```

### Client-side decrypt after pull

```
SyncService.decryptRecord(encryptedPayloadB64, ivB64)

1. base64Decode(ivB64)              → iv (12 bytes)
2. base64Decode(encryptedPayloadB64)→ payload (ciphertext + tag)
3. combined = [ iv | payload ]
4. CryptoService.decrypt(combined, encryptionKey)
     → plaintext bytes
5. utf8.decode(plaintext)  →  JSON string
6. jsonDecode(...)          →  Map<String, dynamic>
```

---

## Recovery Key Mechanism

The recovery key allows restoring the master encryption key if the user forgets their master password or switches devices.

```
Generate recovery key:
  RecoveryService.generateRecoveryKey(masterKey)
    1. recoveryKey = CryptoService.generateRandomKey(32)   ← 32 random bytes
    2. encryptedMasterKey = CryptoService.encrypt(masterKey, recoveryKey)
    3. flutter_secure_storage.write(
         key: 'encrypted_master_key_backup',
         value: base64(encryptedMasterKey)
       )
    4. Return base64(recoveryKey) to the user
         → user must save this string externally (paper / password manager)

Recover:
  RecoveryService.recoverMasterKey(recoveryKeyB64)
    1. recoveryKey = base64Decode(recoveryKeyB64)
    2. encryptedBackup = flutter_secure_storage.read('encrypted_master_key_backup')
    3. masterKey = CryptoService.decrypt(base64Decode(encryptedBackup), recoveryKey)
    4. Return masterKey (derive session key from it)
```

The encrypted master key backup is stored in the OS secure enclave (not in plaintext files or SQLite). The recovery key itself is never stored by the app.

---

## Biometric Session Caching

Biometric unlock avoids re-entering the master password on every app foreground:

```
App unlock flow:
  1. BiometricService.isAvailable()
       → checks canCheckBiometrics && isDeviceSupported
  2. If available:
       BiometricService.authenticate()
         → local_auth.authenticate(biometricOnly: false, persistAcrossBackgrounding: true)
  3. On success:
       → Retrieve cached encryptionKey from flutter_secure_storage
         (the key was stored there after the last full password unlock)
  4. Set SyncService.setEncryptionKey(key) for the session

Full password unlock (first time or after biometric failure):
  1. User enters master password
  2. CryptoService.deriveKey(password, salt) → encryptionKey
  3. Store encryptionKey in flutter_secure_storage (biometric-protected)
  4. SyncService.setEncryptionKey(encryptionKey)
```

The key stored in flutter_secure_storage is protected by the device biometric / PIN policy enforced by the OS. It is cleared when the user changes their master password.

---

## Data Export Encryption

When the user exports a backup:

```
DataExportService.exportEncrypted(encryptionKey)
  1. Collect all hosts and SSH keys from their repositories
  2. Build export manifest:
       { version, exported_at, hosts_count, keys_count }
  3. jsonEncode → UTF-8 bytes
  4. CryptoService.encrypt(bytes, encryptionKey)
       → [ IV(12) | ciphertext | tag(16) ]
  5. base64Encode → string
  6. Write to: <AppDocumentsDir>/nexterm_backup_<timestamp>.enc
  7. SharePlus.share(file) → system share sheet
```

The `.enc` file is opaque without the master encryption key and cannot be decrypted without it.

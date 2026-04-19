# Cloud Sync Protocol

This document describes how Nexterm synchronises encrypted user data between devices via the FastAPI sync server.

---

## Design Goals

| Goal | How |
|------|-----|
| Offline-first | All data lives in local SQLite; sync is additive |
| End-to-end encrypted | Server stores only ciphertext; no plaintext ever sent |
| Incremental | Only changed records are transferred after first sync |
| Conflict-safe | Last-write-wins with monotonically increasing version numbers |
| Multi-device | Any number of devices; each tracks its own sync timestamp |

---

## Sync Record Structure

Each piece of user data (host, SSH key, snippet, port forward) is stored as a `SyncRecord` in both the local SQLite database and on the server:

```
SyncRecord {
  id              : UUID        // stable, client-generated on entity creation
  record_type     : string      // "host" | "ssh_key" | "snippet" | "port_forward"
  encrypted_payload : bytes     // AES-256-GCM ciphertext + authentication tag
  iv              : bytes       // 12-byte GCM initialisation vector
  updated_at      : datetime    // UTC, set on every write
  is_deleted      : bool        // soft-delete flag
  version         : int         // starts at 1, incremented on every write
}
```

The `id` is the stable identity of the entity across all devices and the server. The server indexes on `(user_id, updated_at)` for efficient incremental pulls.

---

## Incremental Timestamp-Based Sync

### Pull (server → client)

```
Client stores: last_sync_timestamp (UTC ISO-8601 string)

GET /api/v1/sync?since=<last_sync_timestamp>
         │
         ▼
Server queries:
  SELECT * FROM sync_records
   WHERE user_id = :uid
     AND updated_at > :since
   ORDER BY updated_at ASC

Response:
  {
    "records": [ ... ],
    "server_timestamp": "2024-01-01T12:00:00Z"
  }

Client:
  1. Decrypt each record (see e2e-encryption.md)
  2. For each decrypted record:
       if is_deleted: remove from local DB
       else: upsert into local DB (by id)
  3. Update last_sync_timestamp = server_timestamp
```

### Push (client → server)

```
Client collects locally-modified records since last_sync_timestamp

POST /api/v1/sync
Body: { "records": [...], "device_id": "..." }
         │
         ▼
Server (sync_service.push_records):
  For each record:
    existing = SELECT * FROM sync_records WHERE id = :id AND user_id = :uid
    if existing is None:
      INSERT new record
      synced_count++
    else if record.version > existing.version:
      UPDATE existing record (ciphertext, iv, updated_at, is_deleted, version)
      synced_count++
    else:
      conflicts_count++   // older version — ignore

Response: { "synced": N, "conflicts": M }
```

---

## Conflict Resolution: Last-Write-Wins + Version

```
Two devices edit the same host concurrently:

  Device A (version 2)    Device B (version 2)
       │                        │
       ├─ Edit → version 3      ├─ Edit → version 3
       │                        │
       ▼                        ▼
   Push version 3           Push version 3

Server receives A first:
  → INSERT/UPDATE to version 3  (synced)

Server receives B next (same id, version 3):
  existing.version = 3
  incoming.version = 3  →  3 > 3 is false  →  conflict (ignored)

Device B pulls:
  → Gets A's version 3
  → Overwrites its own local version 3

Result: A's edit wins (first write wins when version numbers tie).
```

For most SSH terminal use-cases (host config updates, key renames) simultaneous edits on two devices are rare. The simple last-write-wins strategy avoids the complexity of three-way merges.

---

## Offline-First Design

```
No network available:
  All reads → local SQLite (always up-to-date for this device)
  All writes → local SQLite only
  last_sync_timestamp is not updated

Network returns:
  SyncService.pullAndDecrypt(since: last_sync_timestamp, ...)
    → Catches up on remote changes
  SyncService.encryptAndPush(localChanges, ...)
    → Pushes any locally accumulated writes

User experience:
  App is fully functional offline.
  No blocking spinners waiting for sync.
  Sync runs in the background when connectivity is restored.
```

The app uses `connectivity_plus` to detect network changes and trigger sync on reconnection.

---

## Full Sync for New Devices

When a new device registers or when `last_sync_timestamp` is missing/corrupt:

```
GET /api/v1/sync/full
         │
         ▼
Server queries:
  SELECT * FROM sync_records
   WHERE user_id = :uid
     AND is_deleted = false
   ORDER BY updated_at ASC

Returns ALL non-deleted records for the user.

Client:
  1. Decrypt all records
  2. Replace local SQLite contents for this user
  3. Set last_sync_timestamp = server_timestamp
```

Full sync is also used after account recovery (master password + recovery key scenario).

---

## Device Management

Each device is registered with the server and tracked independently:

```
Register device:
  POST /api/v1/devices
  Body: { "device_name": "iPhone 15 Pro", "platform": "ios" }
  Response: { "id": "uuid", "device_name": ..., "platform": ..., "created_at": ... }

  Client stores device_id locally.
  device_id is included in every push request body.

List devices:
  GET /api/v1/devices
  → Shows the user all their registered devices and last_sync_at times

Remove device:
  DELETE /api/v1/devices/{device_id}
  → Removes the device record from the server.
    Does not delete sync_records (they belong to the user, not the device).
```

Device management enables the user to see which devices have access and remove old or lost devices. Because sync records are not deleted on device removal, data is preserved.

---

## Authentication Flow

```
First use:
  POST /api/v1/auth/register
    { "email": "user@example.com", "password": "..." }
    → { "access_token": "<jwt>", "refresh_token": "<jwt>" }

Subsequent launches:
  POST /api/v1/auth/login
    { "email": "user@example.com", "password": "..." }
    → { "access_token": "<jwt>", "refresh_token": "<jwt>" }

Token refresh (access token expires in 30 min):
  POST /api/v1/auth/refresh
    { "refresh_token": "<refresh_jwt>" }
    → { "access_token": "<new_jwt>", "refresh_token": "<new_jwt>" }

All sync / device endpoints:
  Authorization: Bearer <access_token>
```

Tokens are stored in flutter_secure_storage (OS keychain / Keystore). The master encryption key is **never** sent to the server — not in headers, not in the body.

---

## Sequence Diagram: Normal Sync Cycle

```
Client                              Server                 PostgreSQL
  │                                    │                       │
  │── GET /sync?since=T0 ─────────────►│                       │
  │                                    │── SELECT updated>T0 ──►│
  │                                    │◄─ rows ────────────────│
  │◄─ { records, server_timestamp=T1 }─│                       │
  │                                    │                       │
  │ (decrypt, merge into SQLite)        │                       │
  │                                    │                       │
  │── POST /sync { records, device } ──►│                       │
  │                                    │── UPSERT records ─────►│
  │                                    │◄─ ok ──────────────────│
  │◄─ { synced: N, conflicts: 0 } ─────│                       │
  │                                    │                       │
  │ last_sync_timestamp = T1           │                       │
```

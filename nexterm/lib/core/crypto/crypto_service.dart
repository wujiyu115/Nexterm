import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';

class CryptoService {
  static const int _ivLength = 12;
  static const int _tagLength = 16;

  final SecureRandom _secureRandom;

  CryptoService() : _secureRandom = _createSecureRandom();

  static SecureRandom _createSecureRandom() {
    final random = FortunaRandom();
    final seed = Uint8List(32);
    final dartRandom = Random.secure();
    for (var i = 0; i < 32; i++) {
      seed[i] = dartRandom.nextInt(256);
    }
    random.seed(KeyParameter(seed));
    return random;
  }

  Uint8List generateRandomKey(int length) {
    return _secureRandom.nextBytes(length);
  }

  Uint8List encrypt(List<int> plaintext, Uint8List key) {
    final iv = generateRandomKey(_ivLength);
    final cipher = GCMBlockCipher(AESEngine())
      ..init(true, AEADParameters(KeyParameter(key), _tagLength * 8, iv, Uint8List(0)));
    final input = Uint8List.fromList(plaintext);
    final output = Uint8List(input.length + _tagLength);
    var offset = 0;
    offset += cipher.processBytes(input, 0, input.length, output, offset);
    cipher.doFinal(output, offset);
    return Uint8List.fromList([...iv, ...output]);
  }

  Uint8List decrypt(Uint8List data, Uint8List key) {
    if (data.length < _ivLength + _tagLength) {
      throw ArgumentError('Data too short to contain IV and tag');
    }
    final iv = data.sublist(0, _ivLength);
    final ciphertextAndTag = data.sublist(_ivLength);
    final cipher = GCMBlockCipher(AESEngine())
      ..init(false, AEADParameters(KeyParameter(key), _tagLength * 8, iv, Uint8List(0)));
    final output = Uint8List(ciphertextAndTag.length - _tagLength);
    var offset = 0;
    offset += cipher.processBytes(ciphertextAndTag, 0, ciphertextAndTag.length, output, offset);
    cipher.doFinal(output, offset);
    return output;
  }

  Uint8List deriveKey(String password, Uint8List salt, {int iterations = 100000}) {
    final params = Pbkdf2Parameters(salt, iterations, 32);
    final kdf = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))..init(params);
    return kdf.process(Uint8List.fromList(password.codeUnits));
  }
}

import 'dart:math';
import 'dart:typed_data';

/// This encryptor just runs the logical xor-Function to encrypt bytes.
///
/// This encryptro is not a high security encryptor. It just obfuscates one saved record, so a normal user can
/// not retrive the file data from just coping the file and share it with others.
class XorEncryptor {
  /// Generates a random byte.
  static int generateKey() {
    final random = Random();
    return random.nextInt(255);
  }

  /// Encrypts a [value] with given [key] by simple xor function.
  ///
  /// [key] must be a value between 0 and 255.
  static Uint8List encrypt(Uint8List value, int key) {
    return _xor(value, key);
  }

  /// Decrypts a [value] with given [key] by simple xor function.
  ///
  /// [key] must be a value between 0 and 255.
  static Uint8List decrypt(Uint8List encryptedValue, int key) {
    return _xor(encryptedValue, key);
  }

  /// Runs xor operation on [value] and [key].
  ///
  /// [key] must be a value between 0 and 255.
  static Uint8List _xor(Uint8List value, int key) {
    if (key > 255) {
      throw RangeError.range(255, 0, 255);
    }

    return Uint8List.fromList(value.map((e) => e ^ key).toList());
  }
}

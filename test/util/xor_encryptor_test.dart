import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mml_app/util/xor_encryptor.dart';

void main() {
  final data = Uint8List.fromList(List.generate(1024, (i) => i % 256));

  test('decrypt restores encrypted data for every key', () {
    for (var key = 0; key <= 255; key++) {
      final encrypted = XorEncryptor.encrypt(data, key);
      expect(XorEncryptor.decrypt(encrypted, key), data);
    }
  });

  test('encrypt keeps the byte format of previously stored files', () {
    for (var key = 0; key <= 255; key++) {
      final legacy = Uint8List.fromList(data.map((e) => e ^ key).toList());
      expect(XorEncryptor.encrypt(data, key), legacy);
    }
  });

  test('encrypt does not modify the input', () {
    final input = Uint8List.fromList([1, 2, 3]);
    XorEncryptor.encrypt(input, 42);
    expect(input, [1, 2, 3]);
  });

  test('rejects keys outside the byte range', () {
    expect(() => XorEncryptor.encrypt(data, 256), throwsRangeError);
    expect(() => XorEncryptor.encrypt(data, -1), throwsRangeError);
  });
}

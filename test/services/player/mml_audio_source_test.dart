// ignore_for_file: experimental_member_use

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mml_app/services/player/mml_audio_source.dart';
import 'package:mml_app/util/xor_encryptor.dart';

void main() {
  const key = 42;
  final data = Uint8List.fromList(List.generate(1024, (i) => i % 256));
  late Directory directory;
  late File file;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('mml_audio_source');
    file = File('${directory.path}/record')
      ..writeAsBytesSync(XorEncryptor.encrypt(data, key));
  });

  tearDown(() => directory.deleteSync(recursive: true));

  test('decrypts the requested range', () async {
    final response = await MMLAudioSource(file, key).request(10, 20);

    final bytes = await response.stream.expand((chunk) => chunk).toList();

    expect(bytes, data.sublist(10, 20));
    expect(response.offset, 10);
    expect(response.contentLength, 10);
    expect(response.sourceLength, data.length);
  });

  test('does not read further after the request was cancelled', () async {
    final response = await MMLAudioSource(file, key).request();

    // A broadcast stream keeps reading the file without any listener.
    expect(response.stream.isBroadcast, isFalse);
  });
}

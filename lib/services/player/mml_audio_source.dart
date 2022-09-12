import 'dart:io';
import 'dart:typed_data';

import 'package:just_audio/just_audio.dart';
import 'package:mml_app/util/xor_encryptor.dart';

/// AudioSource for the local records streams.
class MMLAudioSource extends StreamAudioSource {
  /// file whcih will be played.
  final File file;

  /// key with whcih the file is ecrypted.
  final int cryptKey;

  /// Initializes the [MMLAudioSource] with [file] to play and [cryptKey] to decrypt file.
  MMLAudioSource(
    this.file,
    this.cryptKey,
  ) : super(tag: "MMLAudioSource");

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= await file.length();
    return StreamAudioResponse(
      sourceLength: await file.length(),
      contentLength: end - start,
      offset: start,
      stream: file.openRead(start, end).asyncMap((List<int> input) {
        return XorEncryptor.decrypt(Uint8List.fromList(input), cryptKey);
      }).asBroadcastStream(),
      contentType: 'audio/mpeg',
    );
  }
}

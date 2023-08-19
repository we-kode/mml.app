import 'dart:io';
import 'dart:typed_data';

import 'package:just_audio/just_audio.dart';
import 'package:mml_app/util/xor_encryptor.dart';

/// AudioSource for the local records streams.
class MMLStreamSource extends StreamAudioSource {
  final String streamId;

  /// Initializes the [MMLAudioSource] with [file] to play and [cryptKey] to decrypt file.
  MMLStreamSource(
    this.streamId,
  ) : super(tag: "MMLStreamSource");

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    print(streamId);
    throw Exception("Here we go");
    // start ??= 0;
    // end ??= await file.length();
    // return StreamAudioResponse(
    //   sourceLength: await file.length(),
    //   contentLength: end - start,
    //   offset: start,
    //   stream: file.openRead(start, end).asyncMap((List<int> input) {
    //     return XorEncryptor.decrypt(Uint8List.fromList(input), cryptKey);
    //   }).asBroadcastStream(),
    //   contentType: 'audio/mpeg',
    // );
  }

  // TODO: streamid in recordid umwandeln
  // dislayname in title
  // sonst automatisches generieren von json wird problematisch

  // TODO: Idee
  /// Im Constructor socketconnection aufbauen
  /// socketconnection füllt einen buffer immer wieder von neuem auf
  /// stream source spielt bei jeder änderung den buffer von neuem ab.
  /// wenn buffer leer dann ichts mehr
  /// 
  /// socketconnectiion wird für alle clients mit gleichem endpoint aufgebaut.
  /// im backend broadcastgen wir dann an alle connected clients
  /// heißt for uns am ende bauen wir nur einen backend client zu unserem eigentlichenstreaming servcie auf.
  /// wenn stream bereits läuft wird nur neuer client hinzugefügt. wenn ict wird eine connection im backend erzeugt

}

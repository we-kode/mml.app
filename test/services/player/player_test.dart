import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mml_app/services/player/mml_audio_handler.dart';
import 'package:mml_app/services/player/player.dart';
import 'package:mml_app/services/player/player_state.dart' as mml;

class _Handler extends Fake implements MMLAudioHandler {
  final StreamController<bool> playing = StreamController.broadcast();

  @override
  double currentSeekPosition = 0;

  @override
  Stream<Duration> get positionStream => const Stream.empty();

  @override
  Stream<PlaybackEvent> get playbackEventStream => const Stream.empty();

  @override
  Stream<bool> get playingStream => playing.stream;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('updates the state, when the playing state changes', () async {
    final handler = _Handler();
    final service = PlayerService.getInstance()..audioHandler = handler;
    final state = service.playerState = mml.PlayerState(handler);
    service.initializeListeners();
    addTearDown(() => service.playerState = null);
    var notified = 0;
    state.addListener(() => notified++);

    handler.playing.add(true);
    await pumpEventQueue();

    expect(notified, 1);
  });
}

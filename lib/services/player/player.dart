import 'package:flutter/material.dart';
import 'package:mml_app/components/player_sheet.dart';
import 'package:mml_app/models/id3_tag_filter.dart';
import 'package:mml_app/models/record.dart';
import 'package:mml_app/services/player/mml_audio_handler.dart';
import 'package:mml_app/services/player/player_repeat_mode.dart';

class PlayerService {
  static PlayerService? _instance;

  late MMLAudioHandler _audioHandler;

  PersistentBottomSheetController? _controller;

  PlayerState? playerState;

  PlayerService._();

  static PlayerService getInstance() {
    _instance ??= PlayerService._();

    return _instance!;
  }

  set audioHandler(MMLAudioHandler audioHandler) {
    _audioHandler = audioHandler;
    _initializeListeners();
  }

  Future closePlayer() async {
    _controller?.close();
    await _reset();
  }

  Future play(
    BuildContext context,
    Record record,
    String? filter,
    ID3TagFilter? tagFilter,
  ) async {
    _audioHandler.filter = filter;
    _audioHandler.tagFilter = tagFilter;

    playerState ??= PlayerState(_audioHandler);

    _controller ??= showBottomSheet(
      enableDrag: false,
      context: context,
      builder: (BuildContext context) {
        return PlayerSheet();
      },
    );

    await _audioHandler.playRecord(record);
  }

  void pause() {
    _audioHandler.pause();
    playerState?.update();
  }

  void resume() {
    _audioHandler.play();
    playerState?.update();
  }

  Future playNext() async {
    await _audioHandler.skipToNext();
    playerState?.update();
  }

  Future playPrevious() async {
    await _audioHandler.skipToPrevious();
    playerState?.update();
  }

  Future seek(Duration newDuration) async {
    await _audioHandler.seek(newDuration);
    playerState?.update();
  }

  set shuffle(bool value) {
    _audioHandler.shuffle = value;

    if (_audioHandler.shuffle) {
      _audioHandler.repeat = PlayerRepeatMode.none;
    }

    playerState?.update();
  }

  set repeat(PlayerRepeatMode value) {
    _audioHandler.repeat = value;
    playerState?.update();
  }

  Future _reset() async {
    playerState = null;
    _controller = null;
    _audioHandler.currentSeekPosition = 0;
    _audioHandler.currentRecord = null;
  }

  _initializeListeners() {
    _audioHandler.positionStream.listen(
      (event) {
        var recordDuration = _audioHandler.currentRecord?.duration ?? 0;
        var duration = double.tryParse(
          '${event.inMilliseconds.clamp(0, recordDuration)}',
        );

        _audioHandler.currentSeekPosition = duration ?? 0;

        playerState?.update();
      },
    );

    _audioHandler.playbackEventStream.listen(
      (event) {
        playerState?.update();
      },
    );
  }
}

class PlayerState extends ChangeNotifier {
  final MMLAudioHandler _audioHandler;

  bool get shuffle => _audioHandler.shuffle;

  PlayerRepeatMode get repeat => _audioHandler.repeat;

  bool get isPlaying => _audioHandler.isPlaying;

  Record? get currentReocrd => _audioHandler.currentRecord;

  double get currentSeekPosition => _audioHandler.currentSeekPosition;

  PlayerState(this._audioHandler);

  void update() {
    notifyListeners();
  }
}

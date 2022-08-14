import 'package:flutter/material.dart';
import 'package:mml_app/components/player_sheet.dart';
import 'package:mml_app/models/id3_tag_filter.dart';
import 'package:mml_app/models/record.dart';
import 'package:mml_app/services/player/mml_audio_handler.dart';
import 'package:mml_app/services/player/player_repeat_mode.dart';

class PlayerService extends ChangeNotifier {
  static PlayerService? _instance;

  late MMLAudioHandler _audioHandler;

  PersistentBottomSheetController? _controller;

  bool get shuffle => _audioHandler.shuffle;

  PlayerRepeatMode get repeat => _audioHandler.repeat;

  bool get isPlaying => _audioHandler.isPlaying;

  Record? get currentReocrd => _audioHandler.currentRecord;

  double get currentSeekPosition => _audioHandler.currentSeekPosition;

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
    _audioHandler.currentRecord = record;
    _audioHandler.filter = filter;
    _audioHandler.tagFilter = tagFilter;

    _controller ??= showBottomSheet(
      enableDrag: false,
      context: context,
      builder: (BuildContext context) {
        return PlayerSheet();
      },
    );

    await _audioHandler.play();
  }

  void pause() {
    _audioHandler.pause();
    notifyListeners();
  }

  void resume() {
    _audioHandler.play();
    notifyListeners();
  }

  Future playNext() async {
    await _audioHandler.skipToNext();
    notifyListeners();
  }

  Future playPrevious() async {
    await _audioHandler.skipToPrevious();
    notifyListeners();
  }

  Future seek(Duration newDuration) async {
    await _audioHandler.seek(newDuration);
    notifyListeners();
  }

  set shuffle(bool value) {
    _audioHandler.shuffle = value;

    if (_audioHandler.shuffle) {
      _audioHandler.repeat = PlayerRepeatMode.none;
    }

    notifyListeners();
  }

  set repeat(PlayerRepeatMode value) {
    _audioHandler.repeat = value;
    notifyListeners();
  }

  Future _reset() async {
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

        notifyListeners();
      },
    );
  }
}

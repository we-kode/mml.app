import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:mml_app/components/player_sheet.dart';
import 'package:mml_app/extensions/duration_double.dart';
import 'package:mml_app/models/id3_tag_filter.dart';
import 'package:mml_app/models/record.dart';
import 'package:mml_app/services/player/mml_audio_handler.dart';
import 'package:mml_app/services/player/player_repeat_mode.dart';
import 'package:mml_app/services/player/player_state.dart';

/// Service that handles all actions for playing records.
class PlayerService {
  /// Instance of the [PlayerService].
  static PlayerService? _instance;

  /// Audio handler that interacts with the player background service and the
  /// notification bar.
  late MMLAudioHandler _audioHandler;

  /// Controller of the current showed bottom sheet, used to close the bottom
  /// sheet when necessary.
  PersistentBottomSheetController? _controller;

  /// State if the seek bar is dragged by the user.
  bool _isSeeking = false;

  /// State of the player.
  PlayerState? playerState;

  /// Event stream, when actual playing record changes.
  StreamController<Record?> onRecordChanged = StreamController.broadcast();

  /// Private constructor of the [PlayerService].
  PlayerService._();

  /// Returns the singleton instance of the [PlayerService] or creates a new
  /// one.
  static PlayerService getInstance() {
    _instance ??= PlayerService._();

    return _instance!;
  }

  /// Sets the given [audioHandler] and initializes the necessary listeners.
  set audioHandler(MMLAudioHandler audioHandler) {
    _audioHandler = audioHandler;
    _initializeListeners();
  }

  /// Sets the repeat mode to the given [value].
  set repeat(PlayerRepeatMode value) {
    _audioHandler.repeat = value;
    playerState?.update();
  }

  /// Sets the shuffle mode to the given [value].
  set shuffle(bool value) {
    _audioHandler.shuffle = value;

    if (_audioHandler.shuffle) {
      _audioHandler.repeat = PlayerRepeatMode.none;
    }

    playerState?.update();
  }

  /// Stops the music and closes the player bottom sheet.
  Future closePlayer({bool stopAudioHandler = true}) async {
    if (stopAudioHandler) {
      await _audioHandler.stop();
    }

    _controller?.close();
    await _reset();
  }

  /// Plays the given [record] and opens the bottom [PlayerSheet] if not
  /// already done.
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
      context: context,
      builder: (BuildContext context) {
        return const PlayerSheet();
      },
      enableDrag: false,
    );

    await _audioHandler.playRecord(record);
  }

  /// Pauses the playback.
  void pause() {
    _audioHandler.pause();
    playerState?.update();
  }

  /// Resumes the playback.
  void resume() {
    _audioHandler.play();
    playerState?.update();
  }

  /// Plays the next record in the filtered record list.
  Future playNext() async {
    await _audioHandler.skipToNext();
    playerState?.update();
  }

  /// Plays the previous record in the filtered record list.
  Future playPrevious() async {
    await _audioHandler.skipToPrevious();
    playerState?.update();
  }

  /// Forwards the current playback by the defined
  /// [AudioServiceConfig.fastForwardInterval].
  Future fastForward() async {
    await _audioHandler.fastForward();
    playerState?.update();
  }

  /// Rewinds the current playback by the defined
  /// [AudioServiceConfig.rewindInterval].
  Future rewind() async {
    await _audioHandler.rewind();
    playerState?.update();
  }

  /// Seeks the current playback to the passed [newDuration].
  Future seek(double newDuration, {bool updatePlayerSeek = false}) async {
    if (updatePlayerSeek) {
      _isSeeking = false;
      await _audioHandler.seek(newDuration.asDuration());
    } else {
      _audioHandler.currentSeekPosition = newDuration;
    }
    playerState?.update();
  }

  /// Initializes the listeners used to update the [PlayerState] and the gui.
  _initializeListeners() {
    _audioHandler.positionStream.listen(
      (event) {
        if (_isSeeking) {
          return;
        }

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

  /// Resets the current player.
  Future _reset() async {
    _audioHandler.currentSeekPosition = 0;
    _audioHandler.currentRecord = null;
    playerState?.update();
    onRecordChanged.add(playerState?.currentReocrd);
    playerState = null;
    _controller = null;
  }

  /// Activtes the state, that the seek bar is actually be dragged by the user.
  startSeekDrag() {
    _isSeeking = true;
  }

  /// Resets the Stream controller for actual playing records.
  Future resetOnRecordChange() async {
    await onRecordChanged.close();
    onRecordChanged = StreamController.broadcast();
  }
}

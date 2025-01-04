import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mml_app/components/player_sheet.dart';
import 'package:mml_app/constants/mml_media_constants.dart';
import 'package:mml_app/extensions/duration_double.dart';
import 'package:mml_app/models/id3_tag_filter.dart';
import 'package:mml_app/models/record.dart';
import 'package:mml_app/services/player/mml_audio_handler.dart';
import 'package:mml_app/services/player/player_repeat_mode.dart';
import 'package:mml_app/services/player/player_state.dart';
import 'package:mml_app/l10n/mml_app_localizations.dart';
import 'package:mml_app/services/router.dart';

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

  /// Updates the playback speed in 0.25 steps
  void speedUp() {
    _audioHandler.speed = max((_audioHandler.speed + .25) % 2.25, 1);
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
    Record record,
    String? filter,
    ID3TagFilter? tagFilter,
  ) async {
    var context = RouterService.getInstance().getCurrentContext();

    if (context == null || !context.mounted) {
      return;
    }

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
    initializeListeners();
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
  initializeListeners() {
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

    _audioHandler.playbackEventStream.listen((event) {
      playerState?.update();
    }, onError: (Object e, StackTrace stackTrace) async {
      if (e is PlatformException && e.message == 'Source error') {
        await _audioHandler.refreshToken();
      }
    });
  }

  /// Resets the current player.
  Future _reset() async {
    _audioHandler.currentSeekPosition = 0;
    _audioHandler.currentRecord = null;
    playerState?.update();
    onRecordChanged.add(playerState?.currentRecord);
    playerState = null;
    _controller = null;
  }

  /// Activates the state, that the seek bar is actually be dragged by the user.
  startSeekDrag() {
    _isSeeking = true;
  }

  /// Resets the Stream controller for actual playing records.
  Future resetOnRecordChange() async {
    await onRecordChanged.close();
    onRecordChanged = StreamController.broadcast();
  }

  Future initializeAudioHandler(BuildContext context) async {
    var notificationColor = Theme.of(context).colorScheme.inverseSurface;

    _audioHandler = await AudioService.init(
      builder: () => MMLAudioHandler(context),
      config: AudioServiceConfig(
        androidNotificationChannelId: "de.wekode.mml.audio",
        androidNotificationChannelName: AppLocalizations.of(context)!.appTitle,
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
        androidBrowsableRootExtras: {
          MMLMediaConstants.mediaBrowseSupported: true,
          MMLMediaConstants.mediaPlayableContentKey:
              MMLMediaConstants.mediaPlayableContentGridItemValue,
        },
        notificationColor: notificationColor,
        androidNotificationIcon: 'mipmap/ic_notification',
        fastForwardInterval: const Duration(seconds: 10),
        rewindInterval: const Duration(seconds: 10),
      ),
    );
  }
}

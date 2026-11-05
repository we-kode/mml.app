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
import 'package:mml_app/services/playback_resume.dart';
import 'package:mml_app/l10n/mml_app_localizations.dart';
import 'package:mml_app/services/router.dart';

/// Service that handles all actions for playing records.
class PlayerService with WidgetsBindingObserver {
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

  final List<StreamSubscription> _subscriptions = [];

  /// Whether this service observes the lifecycle of the app.
  bool _observesLifecycle = false;

  /// Private constructor of the [PlayerService].
  PlayerService._();

  /// Returns the singleton instance of the [PlayerService] or creates a new
  /// one.
  static PlayerService getInstance() {
    _instance ??= PlayerService._();

    return _instance!;
  }

  /// Sets the [handler] without initializing the audio service.
  @visibleForTesting
  set audioHandler(MMLAudioHandler handler) => _audioHandler = handler;

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
    _rememberPosition(force: true);
    if (stopAudioHandler) {
      await _audioHandler.stop();
    }

    _controller?.close();
    await _reset();
  }

  /// Plays the given [record] starting at [startAt] and opens the bottom
  /// [PlayerSheet] if not already done. The record is only prepared and paused,
  /// if [autoPlay] is false.
  Future play(
    Record record,
    String? filter,
    ID3TagFilter? tagFilter, {
    Duration? startAt,
    bool autoPlay = true,
  }) async {
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

    await _audioHandler.playRecord(
      record,
      startAt: startAt,
      autoPlay: autoPlay,
    );
    initializeListeners();
  }

  /// Pauses the playback.
  void pause() {
    _audioHandler.pause();
    _rememberPosition(force: true);
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
      _audioHandler.currentSeekPosition = newDuration;
      _rememberPosition(force: true, allowStart: true);
    } else {
      _audioHandler.currentSeekPosition = newDuration;
    }
    playerState?.update();
  }

  /// Initializes the listeners used to update the [PlayerState] and the gui.
  void initializeListeners() {
    if (!_observesLifecycle) {
      _observesLifecycle = true;
      WidgetsBinding.instance.addObserver(this);
    }

    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    _subscriptions.add(
      _audioHandler.positionStream.listen((event) {
        if (_isSeeking) {
          return;
        }

        var recordDuration = _audioHandler.currentRecord?.duration ?? 0;
        var duration = double.tryParse(
          '${event.inMilliseconds.clamp(0, recordDuration)}',
        );

        final previousSecond = _audioHandler.currentSeekPosition ~/ 1000;
        _audioHandler.currentSeekPosition = duration ?? 0;
        _rememberPosition();

        if (previousSecond != _audioHandler.currentSeekPosition ~/ 1000) {
          playerState?.updatePosition();
        }
      }),
    );

    _subscriptions.add(
      _audioHandler.playingStream.listen((_) => playerState?.update()),
    );

    _subscriptions.add(
      _audioHandler.playbackEventStream.listen(
        (event) {
          playerState?.update();
        },
        onError: (Object e, StackTrace stackTrace) async {
          if (e is PlatformException && e.message == 'Source error') {
            await _audioHandler.refreshToken();
          }
        },
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _rememberPosition(force: true);
    }
  }

  /// Remembers the current position to continue the playback after a restart.
  void _rememberPosition({bool force = false, bool allowStart = false}) {
    PlaybackResumeService.getInstance().remember(
      _audioHandler.currentRecord,
      _audioHandler.currentSeekPosition,
      force: force,
      allowStart: allowStart,
    );
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
  void startSeekDrag() {
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
        androidNotificationOngoing: false,
        androidStopForegroundOnPause: true,
        androidResumeOnClick: false,
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

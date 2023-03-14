import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mml_app/models/id3_tag_filter.dart';
import 'package:mml_app/models/local_record.dart';
import 'package:mml_app/models/record.dart';
import 'package:mml_app/services/api.dart';
import 'package:mml_app/services/client.dart';
import 'package:mml_app/services/db.dart';
import 'package:mml_app/services/file.dart';
import 'package:mml_app/services/logging.dart';
import 'package:mml_app/services/messenger.dart';
import 'package:mml_app/services/player/mml_audio_source.dart';
import 'package:mml_app/services/player/player.dart';
import 'package:mml_app/services/player/player_repeat_mode.dart';
import 'package:mml_app/services/secure_storage.dart';

/// Audio handler that interacts with the player background service and the
/// notification bar.
///
/// Should not be used directly. Instead the playback should be modified with
/// the [PlayerService].
class MMLAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  /// [AudioPlayer] used to start  the native playback.
  AudioPlayer? _player;

  /// [ApiService] used to send requests to the server.
  final ApiService _apiService = ApiService.getInstance();

  /// [ClientService] used to refresh the token if necessary.
  final ClientService _clientService = ClientService.getInstance();

  /// [ID3TagFilter] set by the user.
  ID3TagFilter? _tagFilter;

  /// Filter set by the user.
  String? _filter;

  /// Currently played record.
  Record? currentRecord;

  /// The current seek position of the playback.
  double currentSeekPosition = 0.0;

  /// Bool, that indicates, whether shuffle is enabled or not.
  bool _shuffle = false;

  /// Indicates, that the source to be played is loading.
  bool _isLoading = false;

  /// Repeat mode that is currently set.
  PlayerRepeatMode repeat = PlayerRepeatMode.none;

  /// Creates an instance of the [MMLAudioHandler] and initializes the
  /// listeners.
  MMLAudioHandler();

  /// Stream with the current playback position.
  Stream<Duration> get positionStream => _player!.positionStream;

  /// Stream with the current playback events.
  Stream<PlaybackEvent> get playbackEventStream => _player!.playbackEventStream;

  /// Bool, that indicates, whether the record is playing or not.
  bool get isPlaying => _player?.playing ?? false;

  /// Indicates, that the source to be played is loading.
  bool get isLoading => _isLoading;

  /// Bool, that indicates, whether shuffle is enabled or not.
  bool get shuffle => _shuffle;

  /// Sets the given [filter].
  set filter(String? filter) => _filter = filter;

  /// Sets the given [filter].
  set tagFilter(ID3TagFilter? filter) => _tagFilter = filter;

  /// Sets the given [shuffle] mode.
  set shuffle(bool shuffle) {
    _shuffle = shuffle;
    _addPlaybackState();
  }

  /// Plays the given [record].
  Future<void> playRecord(Record record) async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    currentRecord = record;
    if (_player == null) {
      _initPlayer();
    }
    await _playCurrentRecord();
  }

  /// Cretaes new instance of the [AudioPlayer], if player not exists yet.
  void _initPlayer() {
    _player ??= AudioPlayer();
    _initializeListeners();
  }

  @override
  Future<void> play() => _player!.play();

  @override
  Future<void> pause() => _player!.pause();

  @override
  Future<void> stop() async {
    await _player!.stop();
    await _player!.dispose();
    playbackState.add(
      playbackState.value.copyWith(
        processingState: {
          ProcessingState.idle: AudioProcessingState.idle,
        }[_player!.processingState]!,
      ),
    );
    _player = null;
    await PlayerService.getInstance().closePlayer(stopAudioHandler: false);
  }

  @override
  Future<void> onNotificationDeleted() async {
    await _player!.stop();
  }

  @override
  Future<void> seek(Duration position) => _player!.seek(position);

  @override
  Future<void> skipToNext() async {
    await _skipTo("next");
  }

  @override
  Future<void> skipToPrevious() async {
    await _skipTo("previous");
  }

  /// Initializes the listeners to handle errors, show notifications and skip to
  /// the next record on playback end.
  void _initializeListeners() {
    _player!.playbackEventStream.listen(
      (PlaybackEvent event) {
        _addPlaybackState();
      },
      onError: (Object e, StackTrace st) {
        Logging.logError(
          (MMLAudioHandler).toString(),
          "playbackEventStream",
          "Error on listening to playbackEventStream: $e",
        );
        Logging.logError(
          (MMLAudioHandler).toString(),
          "playbackEventStream",
          "Stacktrace: $st",
        );
      },
    );

    _player!.playerStateStream.listen(
      (event) {
        if (event.processingState == ProcessingState.completed) {
          skipToNext();
        }
      },
    );
  }

  /// Adds or updates the current playback notification message.
  void _addPlaybackState() {
    final playing = _player!.playing;

    List<MediaControl> controls = [];
    List<int> compatIndices = [0, 2];

    if (!_shuffle) {
      controls.add(MediaControl.skipToPrevious);
      compatIndices = [0, 1, 3];
    }

    controls.addAll([
      if (playing) MediaControl.pause else MediaControl.play,
      MediaControl.stop,
      MediaControl.skipToNext,
    ]);

    playbackState.add(
      playbackState.value.copyWith(
        controls: controls,
        systemActions: const {
          MediaAction.seek,
        },
        androidCompactActionIndices: compatIndices,
        processingState: const {
          ProcessingState.idle: AudioProcessingState.loading,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player!.processingState]!,
        playing: playing,
        updatePosition: _player!.position,
        bufferedPosition: _player!.bufferedPosition,
        speed: _player!.speed,
        queueIndex: _player!.currentIndex,
      ),
    );
  }

  /// Handles errors during playback and refreshes the token if necessary.
  Future<bool> _handleError(Object error) async {
    try {
      await _clientService.refreshToken();
      return await _setPlayerSource(isRetry: true);
    } catch (e) {
      Logging.logError(
        (MMLAudioHandler).toString(),
        "_handleError",
        "Error $e",
      );
      _errorOnLoadingRecord();
      return false;
    }
  }

  /// Plays the [currentRecord].
  Future<void> _playCurrentRecord() async {
    var success = await _setPlayerSource();

    if (!success) {
      return;
    }

    PlayerService.getInstance().onRecordChanged.add(currentRecord);
    mediaItem.add(
      MediaItem(
        id: currentRecord!.recordId!,
        album: currentRecord?.album,
        title: currentRecord?.title ?? 'Unknown',
        artist: currentRecord?.artist,
        genre: currentRecord?.genre,
        duration: Duration(
          milliseconds: (currentRecord?.duration ?? 0).toInt(),
        ),
      ),
    );

    _player!.play();
  }

  /// Skips the playback in the given [direction] to the next or
  /// previous record.
  Future<void> _skipTo(String direction) async {
    if (_isLoading) {
      return;
    }

    if (repeat == PlayerRepeatMode.one) {
      _player!.seek(Duration.zero);
      return;
    }

    _isLoading = true;
    Record? record = await getRecord(direction);

    if (record != null) {
      currentRecord = record;
      await _playCurrentRecord();
    } else {
      _player!.stop();
    }
  }

  /// Returns next or previous record in range depending on [direction] to be played.
  Future<Record?> getRecord(String direction) async {
    if (currentRecord is LocalRecord) {
      var record = await DBService.getInstance().next(
        currentRecord!.recordId!,
        (currentRecord! as LocalRecord).playlist.id!,
        repeat: repeat == PlayerRepeatMode.all,
        reverse: direction == 'previous',
        shuffle: shuffle,
      );
      _isLoading = record != null;
      return record;
    }

    var params = <String, dynamic>{};
    params['repeat'] = repeat == PlayerRepeatMode.all;
    params['shuffle'] = _shuffle;

    if (_filter != null) {
      params['filter'] = _filter;
    }

    try {
      var response = await _apiService.request(
        'media/stream/$direction/${currentRecord!.recordId!}',
        queryParameters: params,
        data: _tagFilter != null ? _tagFilter!.toJson() : {},
        options: Options(
          method: 'POST',
        ),
      );

      if (response.data != null) {
        return Record.fromJson(response.data);
      }
    } catch (e) {
      // Catch all errors and stop playing afterwards.
    }

    _isLoading = false;
    return null;
  }

  /// Sets the source format of the player depending on the record type to be played.
  Future<bool> _setPlayerSource({bool isRetry = false}) async {
    if (currentRecord == null) {
      await PlayerService.getInstance().closePlayer();
      return false;
    }

    if (isRetry) {
      await _player!.stop();
      await _player!.dispose();
      _player = null;
      _initPlayer();
      _player!.seek(Duration.zero);
      PlayerService.getInstance().initializeListeners();
    }

    if (currentRecord is LocalRecord) {
      File file;
      try {
        file = await FileService.getInstance().getFile(
          currentRecord!.checksum!,
        );
      } catch (e) {
        await PlayerService.getInstance().closePlayer();
        return false;
      }

      final cryptKey = await SecureStorageService.getInstance().get(
        SecureStorageService.cryptoKey,
      );

      try {
        _player!.setAudioSource(
          MMLAudioSource(file, int.parse(cryptKey!)),
          preload: false,
        );
        _isLoading = false;
        return true;
      } catch (e) {
        if (isRetry) {
          _errorOnLoadingRecord();
          return false;
        }

        return _setPlayerSource(isRetry: true);
      }
    }

    var baseUrl = await _apiService.getBaseUrl();
    var headers = await _apiService.getHeaders();

    try {
      Logging.logInfo(
        (MMLAudioHandler).toString(),
        "_setPlayerSource",
        "---- Try to play url: ${baseUrl}media/stream/${currentRecord?.recordId}.mp3 ----",
      );
      await _player!.setUrl(
        '${baseUrl}media/stream/${currentRecord!.recordId}.mp3',
        headers: headers,
      );
      _isLoading = false;
    } catch (e) {
      Logging.logError(
        (MMLAudioHandler).toString(),
        "_setPlayerSource",
        "Error $e",
      );
      if (isRetry) {
        _errorOnLoadingRecord();
        return false;
      }

      return _handleError(e);
    }

    return true;
  }

  Future<void> _errorOnLoadingRecord() async {
    _isLoading = false;
    await _player!.stop();
    await PlayerService.getInstance().closePlayer(stopAudioHandler: false);
    final ms = MessengerService.getInstance();
    ms.showMessage(ms.notReachableRecord);
  }
}

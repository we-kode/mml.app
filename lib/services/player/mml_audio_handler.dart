import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mml_app/constants/mml_media_constants.dart';
import 'package:mml_app/extensions/duration_double.dart';
import 'package:mml_app/gen/assets.gen.dart';
import 'package:mml_app/l10n/mml_app_localizations.dart';
import 'package:mml_app/models/id3_tag_filter.dart';
import 'package:mml_app/models/livestream.dart';
import 'package:mml_app/models/local_record.dart';
import 'package:mml_app/models/record.dart';
import 'package:mml_app/models/record_view_settings.dart';
import 'package:mml_app/services/api.dart';
import 'package:mml_app/services/client.dart';
import 'package:mml_app/services/db.dart';
import 'package:mml_app/services/file.dart';
import 'package:mml_app/services/livestreams.dart';
import 'package:mml_app/services/messenger.dart';
import 'package:mml_app/services/player/mml_media_item_service.dart';
import 'package:mml_app/services/player/mml_audio_source.dart';
import 'package:mml_app/services/player/player.dart';
import 'package:mml_app/services/player/player_repeat_mode.dart';
import 'package:mml_app/services/record.dart';
import 'package:mml_app/services/secure_storage.dart';
import 'package:mml_app/util/assets.dart';

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
  PlayerRepeatMode _repeat = PlayerRepeatMode.none;

  /// App localizations.
  AppLocalizations? locales;

  /// Creates an instance of the [MMLAudioHandler] and initializes the
  /// listeners.
  MMLAudioHandler(BuildContext context) {
    locales = AppLocalizations.of(context);
  }

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

  /// The actual playback speed
  double get speed => _player?.speed ?? 1.0;

  /// Sets the [speed] of the playback.
  set speed(double speed) {
    _player?.setSpeed(speed);
  }

  /// Repeat mode that is currently set.
  PlayerRepeatMode get repeat => _repeat;

  /// Sets the given [filter].
  set filter(String? filter) => _filter = filter;

  /// Sets the given [filter].
  set tagFilter(ID3TagFilter? filter) => _tagFilter = filter;

  /// Sets the given [shuffle] mode.
  set shuffle(bool shuffle) {
    _shuffle = shuffle;
    _addPlaybackState();
  }

  /// Sets the given [repeat] mode.
  set repeat(PlayerRepeatMode repeat) {
    _repeat = repeat;
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

  /// Creates new instance of the [AudioPlayer], if player not exists yet.
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

  @override
  Future<List<MediaItem>> getChildren(String parentMediaId,
      [Map<String, dynamic>? options]) async {
    return await MMLMediaItemService.getInstance(locales!)
        .getChildren(parentMediaId, options);
  }

  @override
  Future<void> playFromMediaId(String mediaId,
      [Map<String, dynamic>? extras]) async {
    if (mediaId == MMLMediaConstants.offlineId) {
      throw PlatformException(
        code: MMLMediaConstants.errorCodeUnknownError,
        message: locales!.offlineErrorTitle(locales!.appTitle),
      );
    }

    Record? record;
    var tagFilter = ID3TagFilter();
    var filter = "";

    if (mediaId.startsWith(MMLMediaConstants.localRecordId)) {
      record = (await DBService.getInstance().getRecords(
        int.tryParse(mediaId.replaceAll(
              '${MMLMediaConstants.localRecordId}:',
              '',
            )) ??
            0,
      ))
          .firstOrNull;
    } else if (mediaId.startsWith(MMLMediaConstants.livestreamId)) {
      record = await LivestreamService.getInstance().getLivestream(
        mediaId.replaceAll(
          '${MMLMediaConstants.livestreamId}:',
          '',
        ),
      );
    } else {
      if (mediaId.startsWith(MMLMediaConstants.genreId)) {
        tagFilter.genres = [
          mediaId.replaceAll(
            '${MMLMediaConstants.genreId}:',
            '',
          )
        ];
      } else if (mediaId.startsWith(MMLMediaConstants.albumId)) {
        tagFilter.albums = [
          mediaId.replaceAll(
            '${MMLMediaConstants.albumId}:',
            '',
          )
        ];
      } else if (mediaId.startsWith(MMLMediaConstants.artistId)) {
        tagFilter.artists = [
          mediaId.replaceAll(
            '${MMLMediaConstants.artistId}:',
            '',
          )
        ];
      } else if (mediaId.startsWith(MMLMediaConstants.languageId)) {
        tagFilter.languages = [
          mediaId.replaceAll(
            '${MMLMediaConstants.languageId}:',
            '',
          )
        ];
      } else {
        record = await RecordService.getInstance().getRecord(mediaId);
      }

      record ??= (await RecordService.getInstance().getRecords(
        filter,
        extras != null && extras.containsKey(MMLMediaConstants.extraPage)
            ? extras[MMLMediaConstants.extraPage]
            : MMLMediaConstants.defaultPage,
        extras != null && extras.containsKey(MMLMediaConstants.extraPageSize)
            ? extras[MMLMediaConstants.extraPageSize]
            : MMLMediaConstants.defaultPageSize,
        tagFilter,
        RecordViewSettings(
          genre: true,
          album: true,
          cover: true,
          language: true,
          tracknumber: true,
        ),
      ))
          .firstOrNull as Record?;
    }

    if (record != null) {
      await PlayerService.getInstance().play(
        record,
        filter,
        tagFilter,
      );
    }
  }

  @override
  Future<void> playFromSearch(String query,
      [Map<String, dynamic>? extras]) async {
    var searchResult = await MMLMediaItemService.getInstance(
      locales!,
    ).searchRecords(
      query,
      extras,
    );

    var tagFilter = searchResult.$2;
    var filter = searchResult.$3;

    var record = searchResult.$1.firstOrNull as Record?;

    if (record != null) {
      await PlayerService.getInstance().play(
        record,
        filter,
        tagFilter,
      );
    }
  }

  @override
  Future<List<MediaItem>> search(String query,
      [Map<String, dynamic>? extras]) async {
    return (await MMLMediaItemService.getInstance(locales!).search(
      query,
      extras,
    ))
        .$1;
  }

  /// Refreshes the access token and updates the headers of the audio source.
  /// Necessary if the token expires during playback.
  Future<void> refreshToken() async {
    var duration = currentSeekPosition.asDuration();
    await _clientService.refreshToken();

    var baseUrl = await _apiService.getBaseUrl();
    var headers = await _apiService.getHeaders();

    final url = currentRecord is Livestream
        ? '${baseUrl}v2.0/media/livestream/stream/${currentRecord!.recordId}'
        : '${baseUrl}v2.0/media/stream/${currentRecord!.recordId}.mp3';
    await _player!.setUrl(
      url,
      headers: headers,
      initialPosition: duration,
    );
  }

  /// Initializes the listeners to handle errors, show notifications and skip to
  /// the next record on playback end.
  void _initializeListeners() {
    _player!.playbackEventStream.listen(
      (PlaybackEvent event) {
        _addPlaybackState();
      },
      onError: (Object e, StackTrace st) {},
    );

    _player!.playerStateStream.listen(
      (event) {
        if (event.processingState == ProcessingState.completed) {
          skipToNext();
        }
      },
    );
  }

  @override
  Future customAction(String name, [Map<String, dynamic>? extras]) {
    switch (name) {
      case MMLMediaConstants.customActionShuffle:
        shuffle = !shuffle;
        break;
      case MMLMediaConstants.customActionRepeat:
        var nextModeIndex =
            (_repeat.index + 1) % PlayerRepeatMode.values.length;
        PlayerService.getInstance().repeat =
            PlayerRepeatMode.values[nextModeIndex];
        break;
    }

    return super.customAction(name, extras);
  }

  /// Adds or updates the current playback notification message.
  void _addPlaybackState() {
    final playing = _player!.playing;

    List<MediaControl> controls = [
      MediaControl.custom(
        androidIcon: repeat == PlayerRepeatMode.all
            ? 'drawable/repeat_on'
            : repeat == PlayerRepeatMode.one
                ? 'drawable/repeat_one_on'
                : 'drawable/repeat',
        label: locales!.repeat,
        name: MMLMediaConstants.customActionRepeat,
      ),
      MediaControl.custom(
        androidIcon: !_shuffle ? 'drawable/shuffle' : 'drawable/shuffle_on',
        label: locales!.shuffle,
        name: MMLMediaConstants.customActionShuffle,
      ),
    ];
    List<int> compatIndices = [0, 2];

    if (!_shuffle && currentRecord is! Livestream) {
      controls.add(MediaControl.skipToPrevious);
      compatIndices = [0, 1, 3];
    }

    if (currentRecord is! Livestream) {
      controls.addAll([
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ]);
    } else {
      controls = [
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
      ];
      compatIndices = [0, 1];
    }

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

    final brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    final isDarkMode = brightness == Brightness.dark;
    final bgImageUri = await currentRecord?.getAvatarUri() ??
        (await getImageFileFromAssets(
          !isDarkMode ? Assets.images.bgLight.path : Assets.images.bgDark.path,
        ))
            .uri;

    PlayerService.getInstance().onRecordChanged.add(currentRecord);
    mediaItem.add(
      MediaItem(
        id: currentRecord!.recordId!,
        album: currentRecord?.album,
        title: currentRecord?.title ?? locales!.unknown,
        artist: currentRecord?.artist,
        genre: currentRecord?.genre,
        artUri: bgImageUri,
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
        '/media/stream/$direction/${currentRecord!.recordId!}',
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
          currentRecord!,
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
      final url = currentRecord is Livestream
          ? '${baseUrl}v2.0/media/livestream/stream/${currentRecord!.recordId}'
          : '${baseUrl}v2.0/media/stream/${currentRecord!.recordId}.mp3';
      await _player!.setUrl(
        url,
        headers: headers,
      );
      _isLoading = false;
    } catch (e) {
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

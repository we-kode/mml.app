import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mml_app/models/id3_tag_filter.dart';
import 'package:mml_app/models/record.dart';
import 'package:mml_app/services/api.dart';
import 'package:mml_app/services/client.dart';
import 'package:mml_app/services/player/player.dart';
import 'package:mml_app/services/player/player_repeat_mode.dart';

/// Audio handler that interacts with the player background service and the
/// notification bar.
///
/// Should not be used directly. Instead the playback should be modified with
/// the [PlayerService].
class MMLAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  /// [AudioPlayer] used to start  the native playback.
  final _player = AudioPlayer();

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

  /// Repeat mode that is currently set.
  PlayerRepeatMode repeat = PlayerRepeatMode.none;

  /// Creates an instance of the [MMLAudioHandler] and initializes the
  /// listeners.
  MMLAudioHandler() {
    _initializeListeners();
  }

  /// Stream with the current playback position.
  Stream<Duration> get positionStream => _player.positionStream;

  /// Stream with the current playback events.
  Stream<PlaybackEvent> get playbackEventStream => _player.playbackEventStream;

  /// Bool, that indicates, whether the record is playing or not.
  bool get isPlaying => _player.playing;

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
    currentRecord = record;
    await _playCurrentRecord();
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await PlayerService.getInstance().closePlayer(stopAudioHandler: false);
  }

  @override
  Future<void> onNotificationDeleted() async {
    await _player.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

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
    _player.playbackEventStream.listen(
      (PlaybackEvent event) {
        _addPlaybackState();
      },
      onError: (Object e, StackTrace st) {
        _handleError(e);
      },
    );

    _player.playerStateStream.listen(
      (event) {
        if (event.processingState == ProcessingState.completed) {
          skipToNext();
        }
      },
    );
  }

  /// Adds or updates the current playback notification message.
  void _addPlaybackState() {
    final playing = _player.playing;

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
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: _player.currentIndex,
      ),
    );
  }

  /// Handles errors during playback and refreshes the token if necessary.
  Future<void> _handleError(Object error) async {
    try {
      await _clientService.refreshToken();

      var baseUrl = await _apiService.getBaseUrl();
      var headers = await _apiService.getHeaders();

      await _player.setUrl(
        '${baseUrl}media/stream/${currentRecord!.recordId!}',
        headers: headers,
        initialPosition: Duration(milliseconds: currentSeekPosition.ceil()),
      );
    } catch (e) {
      _player.stop();
    }
  }

  /// Plays the [currentRecord].
  Future<void> _playCurrentRecord() async {
    var baseUrl = await _apiService.getBaseUrl();
    var headers = await _apiService.getHeaders();

    try {
      await _player.setUrl(
        '${baseUrl}media/stream/${currentRecord!.recordId!}',
        headers: headers,
      );
    } catch (e) {
      _handleError(e);
    }

    mediaItem.add(
      MediaItem(
        id: '${baseUrl}media/stream/${currentRecord!.recordId!}',
        album: currentRecord?.album,
        title: currentRecord?.title ?? 'Unbekannt',
        artist: currentRecord?.artist,
        genre: currentRecord?.genre,
        duration: Duration(
          milliseconds: (currentRecord?.duration ?? 0).toInt(),
        ),
      ),
    );

    _player.play();
  }

  /// Skips the playback in the given [direction] to the next or
  /// previous record.
  Future<void> _skipTo(String direction) async {
    if (repeat == PlayerRepeatMode.one) {
      _player.seek(Duration.zero);
      return;
    }

    Record? record;

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
        record = Record.fromJson(response.data);
      }
    } catch (e) {
      // Catch all errors and stop playing afterwards.
    }

    if (record != null) {
      currentRecord = record;
      await _playCurrentRecord();
    } else {
      _player.stop();
    }
  }
}

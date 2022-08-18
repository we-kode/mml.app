import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mml_app/models/id3_tag_filter.dart';
import 'package:mml_app/models/record.dart';
import 'package:mml_app/services/api.dart';
import 'package:mml_app/services/client.dart';
import 'package:mml_app/services/player/player.dart';
import 'package:mml_app/services/player/player_repeat_mode.dart';

class MMLAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final _player = AudioPlayer();

  final ApiService _apiService = ApiService.getInstance();

  final ClientService _clientService = ClientService.getInstance();

  ID3TagFilter? _tagFilter;

  String? _filter;

  Record? currentRecord;

  double currentSeekPosition = 0.0;

  bool shuffle = false;

  PlayerRepeatMode repeat = PlayerRepeatMode.none;

  MMLAudioHandler() {
    _initializeListeners();
  }

  Stream<Duration> get positionStream => _player.positionStream;

  Stream<PlaybackEvent> get playbackEventStream => _player.playbackEventStream;

  bool get isPlaying => _player.playing;

  set filter(String? filter) => _filter = filter;

  set tagFilter(ID3TagFilter? filter) => _tagFilter = filter;

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
    if (repeat == PlayerRepeatMode.one) {
      _player.seek(Duration.zero);
      return;
    }

    Record? nextRecord;

    var params = <String, dynamic>{};
    params['repeat'] = repeat == PlayerRepeatMode.all;
    params['shuffle'] = shuffle;

    if (_filter != null) {
      params['filter'] = _filter;
    }

    try {
      var response = await _apiService.request(
        'media/stream/next/${currentRecord!.recordId!}',
        queryParameters: params,
        data: _tagFilter != null ? _tagFilter!.toJson() : {},
        options: Options(
          method: 'POST',
        ),
      );

      if (response.data != null) {
        nextRecord = Record.fromJson(response.data);
      }
    } catch (e) {
      // Catch all errors and stop playing afterwards.
    }

    if (nextRecord != null) {
      currentRecord = nextRecord;
      await _playCurrentRecord();
    } else {
      _player.stop();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (repeat == PlayerRepeatMode.one) {
      _player.seek(Duration.zero);
      return;
    }

    Record? previuousRecord;

    var params = <String, dynamic>{};
    params['repeat'] = repeat == PlayerRepeatMode.all;
    params['shuffle'] = shuffle;

    if (_filter != null) {
      params['filter'] = _filter;
    }

    try {
      var response = await _apiService.request(
        'media/stream/previous/${currentRecord!.recordId!}',
        queryParameters: params,
        data: _tagFilter != null ? _tagFilter!.toJson() : {},
        options: Options(
          method: 'POST',
        ),
      );

      if (response.data != null) {
        previuousRecord = Record.fromJson(response.data);
      }
    } catch (e) {
      // Catch all errors and stop playing afterwards.
    }

    if (previuousRecord != null) {
      currentRecord = previuousRecord;
      await _playCurrentRecord();
    } else {
      _player.stop();
    }
  }

  void _initializeListeners() {
    _player.playbackEventStream.listen(
      (PlaybackEvent event) {
        final playing = _player.playing;
        playbackState.add(
          playbackState.value.copyWith(
            controls: [
              MediaControl.skipToPrevious,
              if (playing) MediaControl.pause else MediaControl.play,
              MediaControl.stop,
              MediaControl.skipToNext,
            ],
            systemActions: const {
              MediaAction.seek,
            },
            androidCompactActionIndices: const [0, 1, 2],
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
            queueIndex: event.currentIndex,
          ),
        );
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

  Future _handleError(Object error) async {
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
}

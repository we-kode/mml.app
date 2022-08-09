import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mml_app/components/player_sheet.dart';
import 'package:mml_app/models/id3_tag_filter.dart';
import 'package:mml_app/models/record.dart';
import 'package:mml_app/services/api.dart';
import 'package:mml_app/services/client.dart';

class PlayerService extends ChangeNotifier {
  static PlayerService? _instance;

  final ApiService _apiService = ApiService.getInstance();

  final ClientService _clientService = ClientService.getInstance();

  PersistentBottomSheetController? _controller;

  AudioPlayer? _player;

  Record? _currentRecord;

  double _currentSeekPosition = 0.0;

  bool _shuffle = false;

  PlayerRepeatMode _repeat = PlayerRepeatMode.none;

  ID3TagFilter? _tagFilter;

  String? _filter;

  bool get shuffle => _shuffle;

  PlayerRepeatMode get repeat => _repeat;

  bool get isPlaying => _player?.playing ?? false;

  Record? get currentReocrd => _currentRecord;

  double get currentSeekPosition => _currentSeekPosition;

  PlayerService._() {
    _player ??= AudioPlayer();
    _initializeListeners();
  }

  static PlayerService getInstance() {
    _instance ??= PlayerService._();

    return _instance!;
  }

  Future closePlayer() async {
    _controller?.close();
    await _dispose();
  }

  Future play(
    BuildContext context,
    Record record, {
    String? filter,
    ID3TagFilter? tagFilter,
  }) async {
    _currentRecord = record;
    _filter = filter;
    _tagFilter = tagFilter;

    _controller ??= showBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return PlayerSheet();
      },
    );

    await _playCurrentRecord();
  }

  void pause() {
    _player?.pause();
    notifyListeners();
  }

  void resume() {
    _player?.play();
    notifyListeners();
  }

  Future playNext() async {
    Record? nextRecord;

    var params = <String, dynamic>{};
    params['repeat'] = _repeat;
    params['shuffle'] = _shuffle;

    if (_filter != null) {
      params['filter'] = _filter;
    }

    try {
      var response = await _apiService.request(
        'media/stream/next/${_currentRecord!.recordId!}',
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
      _currentRecord = nextRecord;
      await _playCurrentRecord();
    } else {
      await _player?.stop();
    }

    notifyListeners();
  }

  Future playPrevious() async {
    Record? previuousRecord;

    var params = <String, dynamic>{};
    params['repeat'] = _repeat;
    params['shuffle'] = _shuffle;

    if (_filter != null) {
      params['filter'] = _filter;
    }

    try {
      var response = await _apiService.request(
        'media/stream/previous/${_currentRecord!.recordId!}',
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
      _currentRecord = previuousRecord;
      await _playCurrentRecord();
    } else {
      await _player?.stop();
    }

    notifyListeners();
  }

  void seek(Duration newDuration) {
    _player?.seek(newDuration);
  }

  set shuffle(bool value) {
    _shuffle = value;

    if (_shuffle) {
      _repeat = PlayerRepeatMode.none;
    }

    notifyListeners();
  }

  set repeat(PlayerRepeatMode value) {
    _repeat = value;
    notifyListeners();
  }

  Future _dispose() async {
    await _player?.dispose();
    _player = null;
    _controller = null;
    _currentSeekPosition = 0;
    _currentRecord = null;
    _instance = null;
  }

  Future _handleError(Object error) async {
    try {
      await _clientService.refreshToken();

      var baseUrl = await _apiService.getBaseUrl();
      var headers = await _apiService.getHeaders();

      await _player?.setUrl(
        '${baseUrl}media/stream/${_currentRecord!.recordId!}',
        headers: headers,
        initialPosition: Duration(milliseconds: currentSeekPosition.ceil()),
      );
    } catch (e) {
      _player?.stop();
    }
  }

  _initializeListeners() {
    _player?.playbackEventStream.listen(
      null,
      onError: (Object e, StackTrace st) {
        _handleError(e);
      },
    );

    _player?.playerStateStream.listen(
      (event) {
        if (event.processingState == ProcessingState.completed) {
          if (_repeat == PlayerRepeatMode.one) {
            _player?.seek(Duration.zero);
          } else {
            playNext();
          }
        }
      },
    );

    _player?.positionStream.listen(
      (event) {
        var duration = double.tryParse(
          '${event.inMilliseconds.clamp(0, _currentRecord?.duration ?? 0)}',
        );
        _currentSeekPosition = duration ?? 0;
        notifyListeners();
      },
    );
  }

  Future _playCurrentRecord() async {
    var baseUrl = await _apiService.getBaseUrl();
    var headers = await _apiService.getHeaders();

    try {
      await _player?.setUrl(
        '${baseUrl}media/stream/${_currentRecord!.recordId!}',
        headers: headers,
      );
    } catch (e) {
      _handleError(e);
    }

    _player?.play();
  }
}

enum PlayerRepeatMode {
  none,
  all,
  one,
}

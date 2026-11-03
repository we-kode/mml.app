import 'package:dio/dio.dart';
import 'package:mml_app/models/local_record.dart';
import 'package:mml_app/models/livestream.dart';
import 'package:mml_app/models/record.dart';
import 'package:mml_app/services/db.dart';
import 'package:mml_app/services/file.dart';
import 'package:mml_app/services/player/player.dart';
import 'package:mml_app/services/record.dart';
import 'package:mml_app/services/secure_storage.dart';

/// Service that remembers the last played record and its position, so the
/// playback can be continued after the app was restarted.
class PlaybackResumeService {
  /// Minimal time between two stored positions.
  static const Duration _storeInterval = Duration(seconds: 10);

  /// Positions before this time do not replace a later stored position of the
  /// same record, because players report the start while they are loading or
  /// stopping.
  static const Duration _startTolerance = Duration(seconds: 1);

  /// Records ending within this time are considered as played completely.
  static const Duration _endTolerance = Duration(seconds: 3);

  /// Names of the values of the stored playback.
  static const String _recordIdKey = 'recordId';
  static const String _positionKey = 'position';
  static const String _playlistIdKey = 'playlistId';

  /// Instance of the playback resume service.
  static final PlaybackResumeService _instance = PlaybackResumeService._();

  /// Instance of the [SecureStorageService] the position is stored in.
  final SecureStorageService _store = SecureStorageService.getInstance();

  /// Whether the continuation is enabled. Null as long as it is not loaded.
  bool? _enabled;

  /// Time the position was stored last.
  DateTime? _lastStored;

  /// Id and position of the stored record, if they are loaded.
  String? _storedId;
  int? _storedPosition;
  bool _storedLoaded = false;

  /// Private constructor of the service.
  PlaybackResumeService._();

  /// Returns the singleton instance of the [PlaybackResumeService].
  static PlaybackResumeService getInstance() {
    return _instance;
  }

  /// Whether the playback is continued after the app was restarted. Disabled by
  /// default.
  Future<bool> isEnabled() async {
    return _enabled ??=
        await _store.get(SecureStorageService.resumePlaybackStorageKey) ==
        'true';
  }

  /// Enables or disables the continuation. Disabling forgets the stored
  /// position.
  Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;
    await _store.set(
      SecureStorageService.resumePlaybackStorageKey,
      enabled.toString(),
    );
    if (!enabled) {
      await clear();
    }
  }

  /// Remembers the [position] in milliseconds of the playing [record]. The
  /// position is stored at most once per [_storeInterval], unless [force] is
  /// set. A position at the start of the record is only stored, if [allowStart]
  /// is set or no later position of the record is stored. Livestreams are not
  /// remembered.
  Future<void> remember(
    Record? record,
    double position, {
    bool force = false,
    bool allowStart = false,
  }) async {
    // The player reports positions several times per second, so frequent calls
    // return before any asynchronous work.
    final now = DateTime.now();
    final last = _lastStored;
    if (_enabled == false ||
        (!force && last != null && now.difference(last) < _storeInterval)) {
      return;
    }

    if (record == null ||
        record.recordId == null ||
        record is Livestream ||
        !await isEnabled()) {
      return;
    }

    await _loadStored();
    if (!allowStart &&
        position < _startTolerance.inMilliseconds &&
        _storedId == record.recordId &&
        (_storedPosition ?? 0) >= _startTolerance.inMilliseconds) {
      return;
    }

    _lastStored = now;
    if ((record.duration ?? 0) > 0 &&
        position >= record.duration! - _endTolerance.inMilliseconds) {
      await clear();
      return;
    }

    _storedId = record.recordId;
    _storedPosition = position.round();
    await _store.setJson(SecureStorageService.lastPlaybackStorageKey, {
      _recordIdKey: _storedId,
      _positionKey: _storedPosition,
      if (record is LocalRecord) _playlistIdKey: record.playlist.id,
    });
  }

  Future<void> _loadStored() async {
    if (_storedLoaded) {
      return;
    }

    _storedLoaded = true;
    final stored = await _store.getJson(
      SecureStorageService.lastPlaybackStorageKey,
    );
    _storedId = stored[_recordIdKey] as String?;
    _storedPosition = stored[_positionKey] as int?;
  }

  /// Forgets the stored position.
  Future<void> clear() async {
    _lastStored = null;
    _storedId = null;
    _storedPosition = null;
    _storedLoaded = true;
    await _store.setJson(SecureStorageService.lastPlaybackStorageKey, null);
  }

  /// Loads the last played record and prepares the player at the stored
  /// position without starting the playback. Does nothing, if the continuation
  /// is disabled or nothing is stored. A record, which was removed or which the
  /// user may not play anymore, is forgotten without a message. Never throws.
  Future<void> restore() async {
    try {
      if (!await isEnabled()) {
        return;
      }

      final stored = await _store.getJson(
        SecureStorageService.lastPlaybackStorageKey,
      );
      final id = stored[_recordIdKey];
      final position = stored[_positionKey];
      if (id is! String || position is! int) {
        return;
      }

      final playlistId = stored[_playlistIdKey] as int?;
      final record = playlistId == null
          ? await _serverRecord(id)
          : await _localRecord(id, playlistId);
      if (record == null) {
        return;
      }

      await PlayerService.getInstance().play(
        record,
        null,
        null,
        startAt: Duration(milliseconds: position),
        autoPlay: false,
      );
    } catch (_) {
      // Continuing the playback may never break the start of the app.
    }
  }

  Future<Record?> _serverRecord(String id) async {
    try {
      return await RecordService.getInstance().getRecord(id, silent: true);
    } on DioException catch (e) {
      // The record was removed or the user lost the right to play it. Other
      // errors, like a missing connection, keep it for the next start.
      if (e.response?.statusCode == 404 || e.response?.statusCode == 403) {
        await clear();
      }

      return null;
    }
  }

  Future<Record?> _localRecord(String id, int playlistId) async {
    final records = await DBService.getInstance().getRecords(playlistId);
    final record = records.where((r) => r.recordId == id).firstOrNull;
    if (record == null || !await FileService.getInstance().exists(record)) {
      await clear();
      return null;
    }

    return record;
  }
}

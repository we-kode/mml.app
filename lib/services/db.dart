import 'dart:io';
import 'dart:math';

import 'package:mml_app/migrations/migration.dart';
import 'package:mml_app/migrations/v1.dart';
import 'package:mml_app/models/local_record.dart';
import 'package:mml_app/models/model_list.dart';
import 'package:mml_app/models/playlist.dart';
import 'package:mml_app/models/record.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Service that handles the databse of the client.
class DBService {
  /// Instance of the service.
  static final DBService _instance = DBService._();

  /// the databse name on device.
  final String _dbName = 'wekode_mml.db';

  /// Table name of the playlist table.
  final String _tPlaylists = 'playlists';

  /// Table name of the records table.
  final String _tRecords = 'records';

  /// Table name of the records playlist many-to-many table.
  final String _tRecordsPlaylists = 'records_playlists';

  /// The databse instance.
  Database? _db;

  /// Returns the singleton instance of the [DBService].
  static DBService getInstance() {
    return _instance;
  }

  /// Holds all information for the migrations of the versions of the databse.
  final Map<int, DBMigration Function()> _migrations = {
    1: () => V1Migration(),
  };

  /// Private constructor of the service.
  DBService._();

  /// Returns the database.
  ///
  /// If the database is not initialized and opened it will be done before returning the insatnce of the databse.
  Future<Database> get _database async {
    if (_db != null) return _db!;

    _db = await _initDB();
    return _db!;
  }

  /// Configures the databse.
  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Is called on creation of database.
  Future _onCreate(Database db, int version) async {
    if (!_migrations.containsKey(version)) {
      return;
    }
    var batch = db.batch();
    _migrations[version]!().onCreate(batch);
    await batch.commit();
  }

  /// Is called on upgrading the database.
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    var batch = db.batch();
    for (var actualVersion = oldVersion + 1;
        actualVersion <= newVersion;
        actualVersion++) {
      _migrations[actualVersion]!().onUpdate(batch);
      await batch.commit();
    }
  }

  /// Inits the databse and opens the databse.
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    try {
      await Directory(dbPath).create(recursive: true);
    } catch (_) {}

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
      onDowngrade: onDatabaseDowngradeDelete,
    );
  }

  /// Loads the saved records and returns a list of [OfflineRecords].
  Future<ModelList> load(
    String? filter,
    int? offset,
    int? take,
    int? playlist,
  ) async {
    final db = await _database;

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT p.id as playlistId, p.name as playlistName, r.*, rp.id FROM $_tRecords r
        INNER JOIN $_tRecordsPlaylists rp ON rp.recordId = r.recordId
        INNER JOIN $_tPlaylists p ON rp.playlistId = p.id
        WHERE p.id = ?
        ORDER BY p.name, r.title
        LIMIT ? OFFSET ?
    ''', [
      playlist,
      take ?? 0,
      offset ?? 0,
    ]);

    return ModelList(
      List.generate(
        maps.length,
        (index) => LocalRecord(
          recordId: maps[index]['recordId'],
          album: maps[index]['album'],
          artist: maps[index]['artist'],
          genre: maps[index]['genre'],
          title: maps[index]['title'],
          checksum: maps[index]['checksum'],
          duration: double.parse(maps[index]['duration'] ?? '0'),
          playlist: Playlist(
            id: maps[index]['playlistId'],
            name: maps[index]['playlistName'],
          ),
        ),
      ),
      offset ?? 0,
      maps.length,
    );
  }

  /// Updates existing playlist.
  Future updatePlaylist(Playlist playlist) async {
    final db = await _database;
    await db.update(
      _tPlaylists,
      playlist.toMap(),
      where: '"id" = ?',
      whereArgs: [playlist.id],
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );
  }

  /// creates a new playlist entry.
  Future createPlaylist(Playlist playlist) async {
    final db = await _database;
    await db.insert(
      _tPlaylists,
      playlist.toMap(),
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );
  }

  /// Loads one playlist.
  Future<Playlist> getPlaylist(int playlistId) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tPlaylists,
      where: '"id" = ?',
      whereArgs: [playlistId],
      limit: 1,
    );

    if (maps.isEmpty) {
      return Playlist();
    }

    var result = maps.first;
    return Playlist(
      id: result['id'],
      name: result['name'],
    );
  }

  /// Loads all available playlists from database.
  Future<ModelList> getPlaylists(String? filter, int? offset, int? take) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tPlaylists,
      where: '? = 1 OR "name" LIKE ?',
      whereArgs: [(filter ?? '').isEmpty ? 1 : 0, "%${filter ?? ''}%"],
      orderBy: 'name',
      limit: take ?? 0,
      offset: offset ?? 0,
    );

    return ModelList(
      List.generate(
        maps.length,
        (index) => Playlist(
          id: maps[index]['id'],
          name: maps[index]['name'],
        ),
      ),
      offset ?? 0,
      maps.length,
    );
  }

  /// Adds [record] to [playlists] with given [fileName] of downloaded file.
  Future addRecord(Record record, List<dynamic> playlists) async {
    final db = await _database;
    await db.insert(
      _tRecords,
      Map.of({
        'recordId': record.recordId,
        'album': record.album,
        'artist': record.artist,
        'genre': record.genre,
        'title': record.title,
        'checksum': record.checksum,
        'duration': record.duration
      }),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    for (var playlist in playlists) {
      final List<Map<String, dynamic>> maps = await db.query(
        _tRecordsPlaylists,
        where: 'recordId = ? AND playlistId = ?',
        whereArgs: [record.recordId, playlist],
      );

      if (maps.isEmpty) {
        await db.insert(
          _tRecordsPlaylists,
          Map.of({
            'recordId': record.recordId,
            'playlistId': playlist,
          }),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
  }

  /// Removes one playlist from playlist.
  Future removeFromPlaylist(String recordId, int playlistId) async {
    final db = await _database;
    await db.delete(
      _tRecordsPlaylists,
      where: 'recordId = ? AND playlistId = ?',
      whereArgs: [recordId, playlistId],
    );
  }

  /// Checks if one record is in any playlist.
  Future<bool> isInPlaylist(String recordId) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tRecordsPlaylists,
      where: 'recordId = ?',
      whereArgs: [recordId],
    );

    return maps.isNotEmpty;
  }

  /// Removes record.
  Future removeRecord(String recordId) async {
    final db = await _database;
    await db.delete(
      _tRecords,
      where: 'recordId = ?',
      whereArgs: [recordId],
    );
  }

  /// Returns the file name which belongs to the [recordId].
  Future<String?> file(String recordId) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tRecords,
      where: 'recordId = ?',
      whereArgs: [recordId],
    );

    return maps.isNotEmpty ? maps.first['checksum'] : null;
  }

  /// Retunrs the [Record] of the [recordId] from db or null if no record found.
  Future<Record?> getRecord(String recordId) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tRecords,
      where: 'recordId = ?',
      whereArgs: [recordId],
    );

    if (maps.isEmpty) {
      return null;
    }

    return _mapRecord(maps.first);
  }

  /// Retunrs the next or previous [Record] of the [recordId] or null if no record exists.
  ///
  /// Default returns the next record in playlist. if [reverse] is set to true, the previous record will be returned.
  /// [shuffle] configures if the records should be mixed. If [repeat] is set, the playlist will be running in endless
  /// thread until stopped.
  Future<Record?> next(
    String recordId,
    int playlistId, {
    bool reverse = false,
    bool shuffle = false,
    bool repeat = false,
  }) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT r.*, p.id as playlistId, p.name as playlistName
        FROM $_tPlaylists p
        INNER JOIN $_tRecordsPlaylists rp ON rp.playlistId = p.id
        INNER JOIN $_tRecords r ON rp.recordId = r.recordId
        WHERE p.id = ? 
        ORDER BY r.title
    ''', [playlistId]);

    if (maps.isEmpty) {
      return null;
    }

    final records = List.generate(
      maps.length,
      (index) => _mapRecord(maps[index]),
    );

    if (shuffle) {
      final random = Random();
      return records.elementAt(random.nextInt(records.length - 1));
    }

    final actualIndex =
        records.indexWhere((element) => element.recordId == recordId);
    if (!reverse) {
      return actualIndex == (records.length - 1)
          ? !repeat
              ? null
              : records.elementAt(0)
          : records.elementAt(actualIndex + 1);
    }

    return actualIndex == 0
        ? !repeat
            ? null
            : records.elementAt(records.length - 1)
        : records.elementAt(actualIndex - 1);
  }

  /// Mpas a database [result] to a [Record] object.
  LocalRecord _mapRecord(Map<String, dynamic> result) {
    return LocalRecord(
      recordId: result['recordId'],
      playlist: Playlist(
        id: result['playlistId'],
        name: result['playlistName'],
      ),
      album: result['album'],
      artist: result['artist'],
      duration: double.parse(result['duration'] ?? '0'),
      genre: result['genre'],
      title: result['title'],
      checksum: result['checksum'],
    );
  }

  /// Removes all database entries.
  Future clean() async {
    final db = await _database;
    db.delete(_tRecordsPlaylists);
    db.delete(_tPlaylists);
    db.delete(_tRecords);
  }

  /// Get all records by a [playlistId].
  Future<List<LocalRecord>> getRecords(int playlistId) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
        SELECT r.*, p.id as playlistId, p.name as playlistName from $_tRecords r
        INNER JOIN $_tRecordsPlaylists rp ON rp.recordId = r.recordId
        INNER JOIN $_tPlaylists p ON rp.playlistId = p.id
        WHERE p.id = ?
    ''',
      [
        playlistId,
      ],
    );

    return List.generate(
      maps.length,
      (index) => _mapRecord(maps[index]),
    );
  }

  /// Delets one playlist by [playlistId].
  Future removePlaylist(int playlistId) async {
    final db = await _database;
    await db.delete(
      _tPlaylists,
      where: 'id = ?',
      whereArgs: [playlistId],
    );
  }
}

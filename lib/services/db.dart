import 'dart:io';

import 'package:mml_app/migrations/migration.dart';
import 'package:mml_app/migrations/v1.dart';
import 'package:mml_app/models/model_list.dart';
import 'package:mml_app/models/offline_record.dart';
import 'package:mml_app/models/playlist.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Service that handles the databse of the client.
class DBService {
  /// Instance of the service.
  static final DBService _instance = DBService._();

  /// the databse name on device.
  final String _dbName = 'wekode_mml.db';

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
  Future<ModelList> load(String? filter, int? offset, int? take) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT p.id as playlistId, p.name as playlistName, r.* FROM playlists p
        LEFT JOIN records_playlists rp ON rp.playlistId = p.id
        LEFT JOIN records r ON rp.recordId = r.recordId
        ORDER BY p.name, r.title
        LIMIT ? OFFSET ?
    ''', [
      take ?? 0,
      offset ?? 0,
    ]);

    return ModelList(
      List.generate(
        maps.length,
        (index) => OfflineRecord(
          recordId: maps[index]['recordId'],
          album: maps[index]['album'],
          artist: maps[index]['artist'],
          genre: maps[index]['genre'],
          title: maps[index]['title'],
          file: maps[index]['file'],
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
      'playlists',
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
      'playlists',
      playlist.toMap(),
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );
  }

  /// Loads one playlist.
  Future<Playlist> getPlaylist(int playlistId) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      'playlists',
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
}

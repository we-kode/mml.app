import 'package:mml_app/migrations/migration.dart';
import 'package:sqflite/sqlite_api.dart';

/// First version of the databse.
class V1Migration implements DBMigration {
  @override
  void onCreate(Batch batch) {
    batch.execute('DROP TABLE IF EXISTS Records');
    batch.execute('DROP TABLE IF EXISTS Playlists');
    batch.execute('DROP TABLE IF EXISTS Records_Playlists');

    // cretae playlists
    batch.execute('''CREATE TABLE Playlists (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT UNIQUE
    )''');

    // create records
    batch.execute('''CREATE TABLE Records (
      recordId TEXT PRIMARY KEY UNIQUE,
      title TEXT,
      checksum TEXT,
      date TEXT,
      duration TEXT,
      artist TEXT NULL,
      genre TEXT NULL,
      album TEXT NULL
    )''');

    // create n-to-m table
    batch.execute('''CREATE TABLE Records_Playlists (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      recordId TEXT,
      playlistId INTEGER,
      FOREIGN KEY (recordId) REFERENCES Records (recordId) ON DELETE NO ACTION ON UPDATE NO ACTION,
      FOREIGN KEY (playlistId) REFERENCES Playlists (id) ON DELETE NO ACTION ON UPDATE NO ACTION
    )''');

    batch.execute('''INSERT INTO Playlists (name) VALUES('Favorites')''');
  }

  @override
  void onUpdate(Batch batch) {
    // nothing to update since first version.
  }
}

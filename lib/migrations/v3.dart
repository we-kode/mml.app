import 'package:mml_app/migrations/migration.dart';
import 'package:mml_app/migrations/v2.dart';
import 'package:sqflite/sqflite.dart';

/// Version 3 of the databse.
class V3Migration implements DBMigration {
  @override
  void onCreate(Batch batch) {
    V2Migration().onCreate(batch);
    onUpdate(batch);
  }

  @override
  void onUpdate(Batch batch) {
    batch.execute('''ALTER TABLE Records ADD tracknumber INTEGER NULL''');

    batch.execute('''
      CREATE TABLE RecordViewSettings (
        id INTEGER DEFAULT 1 PRIMARY KEY,
        genre INTEGER DEFAULT 1 NOT NULL,
        album INTEGER DEFAULT 1 NOT NULL,
        language INTEGER DEFAULT 1 NOT NULL,
        tracknumber INTEGER DEFAULT 1 NOT NULL
    )
    ''');
  }
}

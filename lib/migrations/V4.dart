import 'package:mml_app/migrations/migration.dart';
import 'package:mml_app/migrations/v3.dart';
import 'package:sqflite/sqflite.dart';

/// Version 4 of the databse.
class V4Migration implements DBMigration {
  @override
  void onCreate(Batch batch) {
    V3Migration().onCreate(batch);
    onUpdate(batch);
  }

  @override
  void onUpdate(Batch batch) {
   batch.execute('''
      CREATE TABLE ID3Filters (
        key TEXT PRIMARY KEY,
        filter TEXT NOT NULL
    )
    ''');
  }
}
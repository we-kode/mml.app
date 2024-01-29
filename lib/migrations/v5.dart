import 'package:mml_app/migrations/migration.dart';
import 'package:mml_app/migrations/version_4.dart';
import 'package:sqflite/sqflite.dart';

/// Version 5 of the databse.
class V5Migration implements DBMigration {
  @override
  void onCreate(Batch batch) {
    V4Migration().onCreate(batch);
    onUpdate(batch);
  }

  @override
  void onUpdate(Batch batch) {
    batch.execute('''ALTER TABLE Records ADD cover TEXT NULL''');

    batch.execute('''
      ALTER TABLE RecordViewSettings ADD cover INTEGER DEFAULT 0 NOT NULL
    ''');
  }
}

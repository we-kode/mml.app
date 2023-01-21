import 'package:mml_app/migrations/migration.dart';
import 'package:sqflite/sqlite_api.dart';

/// First version of the databse.
class V2Migration implements DBMigration {
  @override
  void onCreate(Batch batch) {
    // should be created in version 1
  }

  @override
  void onUpdate(Batch batch) {
    // create records
    batch.execute('''ALTER TABLE Records ADD language TEXT NULL
    ''');
  }
}

import 'package:mml_app/migrations/migration.dart';
import 'package:mml_app/migrations/v1.dart';
import 'package:sqflite/sqlite_api.dart';

/// First version of the databse.
class V2Migration implements DBMigration {
  @override
  void onCreate(Batch batch) {
    V1Migration().onCreate(batch);
    batch.execute('''ALTER TABLE Records ADD language TEXT NULL''');
  }

  @override
  void onUpdate(Batch batch) {
    // create records
    batch.execute('''ALTER TABLE Records ADD language TEXT NULL
    ''');
  }
}

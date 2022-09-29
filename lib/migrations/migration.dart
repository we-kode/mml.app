import 'package:sqflite/sqflite.dart';

/// Defines functions for database schema changes.
abstract class DBMigration {
  /// When databse is created first time call this function.
  void onCreate(Batch batch);

  /// When one extisting databse is updated from one older version to one newer version call this function.
  void onUpdate(Batch batch);
}

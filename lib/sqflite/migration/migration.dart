import 'package:flutter_desktop_app/plain_sqlite/migration/migration_v2.dart';
import 'package:flutter_desktop_app/plain_sqlite/migration/migration_v3.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void executeMigration(Batch batch, int newVersion) {
  if (newVersion == 2) {
    migrationV2(batch);
  } else if (newVersion == 3) {
    migrationV3(batch);
  }
}
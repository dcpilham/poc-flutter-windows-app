import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void migrationV3(Batch batch) {
  dropColumnCreatedAt(batch);
}

void dropColumnCreatedAt(Batch batch) {
  batch.execute("alter table sales drop created_at;");
}
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void migrationV2(Batch batch) {
  _createColumnCreatedAt(batch);
}

void _createColumnCreatedAt(Batch batch) {
  batch.execute("alter table sales add created_at text;");
}
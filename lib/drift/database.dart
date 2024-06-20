import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_desktop_app/drift/entity/order.dart';
import 'package:flutter_desktop_app/drift/entity/product.dart';
import 'package:flutter_desktop_app/drift/migration/orders_add_created_at_column.dart';
import 'package:flutter_desktop_app/drift/repository/order.dart';
import 'package:flutter_desktop_app/drift/repository/order_product.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

@DriftDatabase(tables: [Orders, OrderProducts, Products], daos: [OrderRepository, OrderProductRepository])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        //await initData(products);
      },
      onUpgrade: (m, from, to) async {
        await customStatement("pragma foreign_keys=off");
        await transaction(() async {
          if (from < 2) {
            await runMigrationV2(m);
          }
        });
        if (kDebugMode) {
          final wrongForeignKeys = await customSelect('PRAGMA foreign_key_check').get();
          assert(wrongForeignKeys.isEmpty,'${wrongForeignKeys.map((e) => e.data)}');
        }
      },
      beforeOpen: (details) async {
        await customStatement("pragma foreign_keys=on");
      }
    );
  }
}


LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'segari_pos.db'));

    return NativeDatabase.createInBackground(file);
  });
}
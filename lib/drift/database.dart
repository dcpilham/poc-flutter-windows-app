import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_desktop_app/drift/migration/migration_v2.dart';
import 'package:flutter_desktop_app/drift/repository/order.dart';
import 'package:flutter_desktop_app/drift/repository/order_item.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

@DataClassName("Order")
class Orders extends Table {
  Column<int> get id => integer().autoIncrement()();
  Column<String> get customer => text()();
  Column<double> get total => real()();
  Column<DateTime> get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName("OrderItem")
class OrderItems extends Table {
  Column<int> get id => integer().autoIncrement()();
  Column<String> get name => text()();
  Column<int> get quantity => integer()();
  Column<double> get price => real()();
  Column<int> get orderId => integer().references(Orders, #id)();
}

@DriftDatabase(tables: [Orders, OrderItems], daos: [OrdersRepository, OrderItemsRepository])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
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
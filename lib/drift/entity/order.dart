import 'package:drift/drift.dart';

@DataClassName("Order")
class Orders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get customer => text()();
  RealColumn get total => real()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName("OrderProduct")
class OrderProducts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get quantity => integer()();
  IntColumn get orderId => integer().references(Orders, #id)();
  IntColumn get productId => integer().withDefault(const Constant(-1))();
}
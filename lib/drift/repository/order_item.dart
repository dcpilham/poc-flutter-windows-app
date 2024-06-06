import 'package:drift/drift.dart';
import 'package:flutter_desktop_app/drift/database.dart';

part 'order_item.g.dart';

@DriftAccessor(tables: [OrderItems])
class OrderItemsRepository extends DatabaseAccessor<AppDatabase> with _$OrderItemsRepositoryMixin {

  OrderItemsRepository(AppDatabase db) : super(db);

  Future<int> insert(OrderItemsCompanion orderItem) async {
    return into(orderItems).insert(orderItem);
  }
}
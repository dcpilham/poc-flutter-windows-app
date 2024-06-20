import 'package:drift/drift.dart';
import 'package:flutter_desktop_app/drift/database.dart';
import 'package:flutter_desktop_app/drift/entity/order.dart';

part 'order.g.dart';

@DriftAccessor(tables: [Orders])
class OrderRepository extends DatabaseAccessor<AppDatabase> with _$OrderRepositoryMixin {

  OrderRepository(super.db);
  
  Future<List<Order>> getAll() async {
    return customSelect("select * from orders", readsFrom: {orders})
    .map((item) => Order(id: item.data["id"], customer: item.data["customer"], total: item.data["total"], createdAt: DateTime.parse(item.data["created_at"])))
    .get();
  }

  Future<int> insert(OrdersCompanion order) async {
    return into(orders).insert(order);
  }
}
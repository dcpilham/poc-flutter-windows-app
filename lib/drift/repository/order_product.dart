import 'package:drift/drift.dart';
import 'package:flutter_desktop_app/drift/database.dart';
import 'package:flutter_desktop_app/drift/entity/order.dart';

part 'order_product.g.dart';

@DriftAccessor(tables: [OrderProducts])
class OrderProductRepository extends DatabaseAccessor<AppDatabase> with _$OrderProductRepositoryMixin {

  OrderProductRepository(super.db);

  Future<int> insert(OrderProductsCompanion orderProduct) async {
    return into(orderProducts).insert(orderProduct);
  }
}
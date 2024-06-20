import 'dart:async';

import 'package:flutter_desktop_app/sqflite/dto/sales.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';

class SalesProvider {
  Database db = GetIt.I<Database>();

  SalesProvider();

  Future<List<Sales>> getAll() async {
    List<Map<String,  Object?>> salesResults = await db.rawQuery("select * from sales");
    List<Sales> salesList = salesResults.map((e) => Sales.fromMap(e)).toList();
    for (Sales s in salesList) {
      List<Map<String,  Object?>> salesItemResults = await db.rawQuery("select * from sales_items where sales_id = ${s.id}");
      List<SalesItem> salesItemList = salesItemResults.map((e) => SalesItem.fromMap(e)).toList();
      if (salesItemList.isNotEmpty) {
        s.items?.addAll(salesItemList);
      }
    }
    return salesList;
  }


  Future<void> insertSales(Sales sales) async {
    final salesId = await db.rawInsert("insert into sales(customer_name, total) values ('${sales.customerName}', ${sales.total});");
    sales.items?.forEach((i) async {
      final salesItemId = await db.rawInsert("insert into sales_items(name, sales_id, price, quantity) values('${i.name}', $salesId, ${i.price}, ${i.quantity})");
      print(salesItemId);
    });
  }
}
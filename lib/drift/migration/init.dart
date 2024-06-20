import 'package:drift/drift.dart';
import 'package:flutter_desktop_app/drift/database.dart';

void initData($ProductsTable products) async {
  var items = [
    ProductsCompanion.insert(name: "Indomie Goreng", price: 3100), 
    ProductsCompanion.insert(name: "Indomie Goreng Aceh", price: 3200),
    ProductsCompanion.insert(name: "Foom Liquid Fantasy Red Strawberry Soda Salt Nic", price: 95000),
    ProductsCompanion.insert(name: "Foom Liquid Icy Berry", price: 95000),
    ProductsCompanion.insert(name: "Champ Nugget Ayam 500 gr", price: 50000),
    ProductsCompanion.insert(name: "Champ Nugget Ayam Stick 500 gr", price: 50000)
  ];

  await products.insertAll(items);
}
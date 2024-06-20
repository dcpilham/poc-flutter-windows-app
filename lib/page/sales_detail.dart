import 'package:flutter/material.dart';
import 'package:flutter_desktop_app/sqflite/dto/sales.dart';


class SalesDetailPageArguments {
  Sales sales;

  SalesDetailPageArguments(this.sales);
}

class SalesDetailPage extends StatelessWidget {
  static const routeName = 'SalesDetailPage';
  Sales? sales;

  SalesDetailPage(SalesDetailPageArguments args, {super.key}) {
    sales = args.sales;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: generateSalesDetails(),
      ),
    );
  }
  
  Widget generateSalesDetails() {
    return ListView.builder(itemBuilder: (context, index) {
      var salesItem = sales?.items?[index];
      return Column(
        children: [
            Text("${salesItem!.name} - ${salesItem.price}"),
            Text("${salesItem.quantity}x, subtotal = ${salesItem.price! * salesItem.quantity!}")
          ]
        );
    });
  }

}
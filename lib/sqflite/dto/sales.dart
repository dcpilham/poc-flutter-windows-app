import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sales.g.dart';

@JsonSerializable()
class Sales {
  int? id;
  String? customerName;
  List<SalesItem>? items;
  double? total;

  Sales({this.id, required this.customerName, this.items, required this.total});

  factory Sales.fromJson(Map<String, dynamic> json) => _$SalesFromJson(json);
  
  Map<String, dynamic> toJson() => _$SalesToJson(this);

  factory Sales.fromMap(Map<String, Object?> map) {
    return Sales(
      id: map["id"] as int,
      customerName: map["customer_name"] as String,
      total: map["total"] as double,
      items: []
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'customerName': customerName,
      'total': total,
    };
  }
}

@JsonSerializable()
class SalesItem {
  int? id;
  String? name;
  double? price;
  int? quantity;

  SalesItem({this.id, required this.name, required this.price, required this.quantity});

  factory SalesItem.fromJson(Map<String, dynamic> json) => _$SalesItemFromJson(json);

  Map<String, dynamic> toJson() => _$SalesItemToJson(this);

    factory SalesItem.fromMap(Map<String, Object?> map) {
    return SalesItem(
      id: map["id"] as int,
      name: map["name"] as String,
      price: map["price"] as double,
      quantity: map["quantity"] as int,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'name': name,
      'price': price,
      'quantity': quantity
    };
  }
}
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Sales _$SalesFromJson(Map<String, dynamic> json) => Sales(
      id: (json['id'] as num?)?.toInt(),
      customerName: json['customerName'] as String?,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => SalesItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$SalesToJson(Sales instance) => <String, dynamic>{
      'id': instance.id,
      'customerName': instance.customerName,
      'items': instance.items,
      'total': instance.total,
    };

SalesItem _$SalesItemFromJson(Map<String, dynamic> json) => SalesItem(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      quantity: (json['quantity'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SalesItemToJson(SalesItem instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
      'quantity': instance.quantity,
    };

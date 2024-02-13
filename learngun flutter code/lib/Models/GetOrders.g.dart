// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'GetOrders.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetOrders _$GetOrdersFromJson(Map<String, dynamic> json) => GetOrders(
      id: json['id'] as int,
      status: json['status'] as String,
      key: json['key'] as String,
      total: json['total'] as String,
      date: json['date'] as String,
      method: json['method'] as List<dynamic>,
      items: ItemsBean.fromJson(json['items'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GetOrdersToJson(GetOrders instance) => <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'key': instance.key,
      'date': instance.date,
      'total': instance.total,
      'method': instance.method,
      'items': instance.items,
    };

ItemsBean _$ItemsBeanFromJson(Map<String, dynamic> json) => ItemsBean(
      order_items_loaded: json['order_items_loaded'],
    );

Map<String, dynamic> _$ItemsBeanToJson(ItemsBean instance) => <String, dynamic>{
      'order_items_loaded': instance.order_items_loaded,
    };

ItemLoadedBean _$ItemLoadedBeanFromJson(Map<String, dynamic> json) =>
    ItemLoadedBean(
      total: json['total'] as String,
      id: json['id'] as String,
      name: json['name'] as String,
      subtotal: json['subtotal'] as String,
      course_id: json['course_id'] as String,
      quantity: json['quantity'] as String,
    );

Map<String, dynamic> _$ItemLoadedBeanToJson(ItemLoadedBean instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'course_id': instance.course_id,
      'quantity': instance.quantity,
      'subtotal': instance.subtotal,
      'total': instance.total,
    };

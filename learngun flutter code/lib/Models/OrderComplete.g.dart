// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'OrderComplete.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

complete_order _$complete_orderFromJson(Map<String, dynamic> json) =>
    complete_order(
      success: json['success'] as bool,
      order_id: json['order_id'] as num,
      payment_method: json['payment_method'] as String,
      subtotal: json['subtotal'] as num,
      total: json['total'] as num,
      order_date: json['order_date'] as String,
      courses: (json['courses'] as List<dynamic>)
          .map((e) => coursesBean.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$complete_orderToJson(complete_order instance) =>
    <String, dynamic>{
      'success': instance.success,
      'order_id': instance.order_id,
      'payment_method': instance.payment_method,
      'subtotal': instance.subtotal,
      'total': instance.total,
      'order_date': instance.order_date,
      'courses': instance.courses,
    };

coursesBean _$coursesBeanFromJson(Map<String, dynamic> json) => coursesBean(
      title: json['title'] as String,
      price: json['price'] as num,
      origin_price: json['origin_price'] as num,
      sale_price: json['sale_price'] as num,
    );

Map<String, dynamic> _$coursesBeanToJson(coursesBean instance) =>
    <String, dynamic>{
      'title': instance.title,
      'price': instance.price,
      'origin_price': instance.origin_price,
      'sale_price': instance.sale_price,
    };

import 'package:json_annotation/json_annotation.dart';
part 'GetOrders.g.dart';

@JsonSerializable()
class GetOrders {
  int id;
  String status;
  String key;
  String date;
  String total;
  List method;
  ItemsBean items;
  GetOrders(
      {required this.id,
      required this.status,
      required this.key,
      required this.total,
      required this.date,
      required this.method,
      required this.items});
  factory GetOrders.fromJson(Map<String, dynamic> json) => _$GetOrdersFromJson(json);
  Map<String, dynamic> toJson() => _$GetOrdersToJson(this);
}

@JsonSerializable()
class ItemsBean {
  final order_items_loaded;
  ItemsBean({required this.order_items_loaded});
  factory ItemsBean.fromJson(Map<String, dynamic> json) => _$ItemsBeanFromJson(json);
  Map<String, dynamic> toJson() => _$ItemsBeanToJson(this);
}

@JsonSerializable()
class ItemLoadedBean {
  String id;
  String name;
  String course_id;
  String quantity;
  String subtotal;
  String total;
  ItemLoadedBean(
      {required this.total,
      required this.id,
      required this.name,
      required this.subtotal,
      required this.course_id,
      required this.quantity});
  factory ItemLoadedBean.fromJson(Map<String, dynamic> json) => _$ItemLoadedBeanFromJson(json);
  Map<String, dynamic> toJson() => _$ItemLoadedBeanToJson(this);
}

import 'package:json_annotation/json_annotation.dart';
part 'OrderComplete.g.dart';

@JsonSerializable()
class complete_order {
  bool success;
  num order_id;
  String payment_method;
  num subtotal;
  num total;
  String order_date;
  List<coursesBean> courses;
  complete_order(
      {required this.success,
      required this.order_id,
      required this.payment_method,
      required this.subtotal,
      required this.total,
      required this.order_date,
      required this.courses});
  factory complete_order.fromJson(Map<String, dynamic> json) => _$complete_orderFromJson(json);
  Map<String, dynamic> toJson() => _$complete_orderToJson(this);
}

@JsonSerializable()
class coursesBean {
  String title;
  num price;
  num origin_price;
  num sale_price;
  coursesBean({required this.title, required this.price, required this.origin_price, required this.sale_price});
  factory coursesBean.fromJson(Map<String, dynamic> json) => _$coursesBeanFromJson(json);
  Map<String, dynamic> toJson() => _$coursesBeanToJson(this);
}

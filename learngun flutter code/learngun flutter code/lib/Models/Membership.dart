import 'package:json_annotation/json_annotation.dart';

part 'Membership.g.dart';

@JsonSerializable()
class Membership {
  List<PlansBean> plans;
  final membership;
  Membership({required this.plans, required this.membership});
  factory Membership.fromJson(Map<String, dynamic> json) =>
      _$MembershipFromJson(json);
  Map<String, dynamic> toJson() => _$MembershipToJson(this);
}

@JsonSerializable()
class PlansBean {
  String id;
  String name;
  String description;
  num initial_payment;
  String expiration_number;
  String expiration_period;
  final categories;
  PlansBean({
    required this.id,
    required this.name,
    required this.description,
    required this.initial_payment,
    required this.expiration_number,
    required this.expiration_period,
    required this.categories,
  });
  factory PlansBean.fromJson(Map<String, dynamic> json) =>
      _$PlansBeanFromJson(json);
  Map<String, dynamic> toJson() => _$PlansBeanToJson(this);
}

@JsonSerializable()
class Membershipbean {
  String id;
  String subscription_id;
  String name;
  String startdate;
  String enddate;
  Membershipbean(
      {required this.id,
      required this.subscription_id,
      required this.name,
      required this.startdate,
      required this.enddate});
  factory Membershipbean.fromJson(Map<String, dynamic> json) =>
      _$MembershipbeanFromJson(json);
  Map<String, dynamic> toJson() => _$MembershipbeanToJson(this);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Membership.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Membership _$MembershipFromJson(Map<String, dynamic> json) => Membership(
      plans: (json['plans'] as List<dynamic>)
          .map((e) => PlansBean.fromJson(e as Map<String, dynamic>))
          .toList(),
      membership: json['membership'],
    );

Map<String, dynamic> _$MembershipToJson(Membership instance) =>
    <String, dynamic>{
      'plans': instance.plans,
      'membership': instance.membership,
    };

PlansBean _$PlansBeanFromJson(Map<String, dynamic> json) => PlansBean(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      initial_payment: json['initial_payment'] as num,
      expiration_number: json['expiration_number'] as String,
      expiration_period: json['expiration_period'] as String,
      categories: json['categories'],
    );

Map<String, dynamic> _$PlansBeanToJson(PlansBean instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'initial_payment': instance.initial_payment,
      'expiration_number': instance.expiration_number,
      'expiration_period': instance.expiration_period,
      'categories': instance.categories,
    };

Membershipbean _$MembershipbeanFromJson(Map<String, dynamic> json) =>
    Membershipbean(
      id: json['id'] as String,
      subscription_id: json['subscription_id'] as String,
      name: json['name'] as String,
      startdate: json['startdate'] as String,
      enddate: json['enddate'] as String,
    );

Map<String, dynamic> _$MembershipbeanToJson(Membershipbean instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subscription_id': instance.subscription_id,
      'name': instance.name,
      'startdate': instance.startdate,
      'enddate': instance.enddate,
    };

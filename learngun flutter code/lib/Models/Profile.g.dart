// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
      id: json['id'] as num,
      username: json['username'] as String,
      name: json['name'] as String,
      first_name: json['first_name'] as String,
      last_name: json['last_name'] as String,
      email: json['email'] as String,
      description: json['description'] as String,
      link: json['link'] as String,
      avatar_url: json['avatar_url'] as String,
      social: Socialbean.fromJson(json['social'] as Map<String, dynamic>),
      tabs: tabsbean.fromJson(json['tabs'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'name': instance.name,
      'first_name': instance.first_name,
      'last_name': instance.last_name,
      'email': instance.email,
      'description': instance.description,
      'link': instance.link,
      'avatar_url': instance.avatar_url,
      'social': instance.social,
      'tabs': instance.tabs,
    };

Socialbean _$SocialbeanFromJson(Map<String, dynamic> json) => Socialbean(
      facebook: json['facebook'] as String,
      twitter: json['twitter'] as String,
      youtube: json['youtube'] as String,
      linkedin: json['linkedin'] as String,
    );

Map<String, dynamic> _$SocialbeanToJson(Socialbean instance) =>
    <String, dynamic>{
      'facebook': instance.facebook,
      'twitter': instance.twitter,
      'youtube': instance.youtube,
      'linkedin': instance.linkedin,
    };

tabsbean _$tabsbeanFromJson(Map<String, dynamic> json) => tabsbean(
      orders: Ordersbean.fromJson(json['orders'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$tabsbeanToJson(tabsbean instance) => <String, dynamic>{
      'orders': instance.orders,
    };

Ordersbean _$OrdersbeanFromJson(Map<String, dynamic> json) => Ordersbean(
      content: json['content'],
    );

Map<String, dynamic> _$OrdersbeanToJson(Ordersbean instance) =>
    <String, dynamic>{
      'content': instance.content,
    };

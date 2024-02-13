// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Reviews.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

reviews _$reviewsFromJson(Map<String, dynamic> json) => reviews(
      title: json['title'] as String,
      content: json['content'] as String,
      avatar: json['avatar'] as String,
      comment_id: json['comment_id'] as String,
      display_name: json['display_name'] as String,
      rate: json['rate'] as String,
      time: json['time'] as String,
    );

Map<String, dynamic> _$reviewsToJson(reviews instance) => <String, dynamic>{
      'comment_id': instance.comment_id,
      'display_name': instance.display_name,
      'title': instance.title,
      'content': instance.content,
      'rate': instance.rate,
      'avatar': instance.avatar,
      'time': instance.time,
    };

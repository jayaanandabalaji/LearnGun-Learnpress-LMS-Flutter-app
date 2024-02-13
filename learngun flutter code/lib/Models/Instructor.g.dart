// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Instructor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Instructor _$InstructorFromJson(Map<String, dynamic> json) => Instructor(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      description: json['description'] as String,
      link: json['link'] as String,
      avatar_url: json['avatar_url'] as String,
      first_name: json['first_name'] as String,
      last_name: json['last_name'] as String,
      social: socialBean.fromJson(json['social'] as Map<String, dynamic>),
      instructor_data: InstructorDataBean.fromJson(
          json['instructor_data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$InstructorToJson(Instructor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'description': instance.description,
      'link': instance.link,
      'avatar_url': instance.avatar_url,
      'first_name': instance.first_name,
      'last_name': instance.last_name,
      'social': instance.social,
      'instructor_data': instance.instructor_data,
    };

socialBean _$socialBeanFromJson(Map<String, dynamic> json) => socialBean(
      facebook: json['facebook'] as String,
      twitter: json['twitter'] as String,
      youtube: json['youtube'] as String,
      linkedin: json['linkedin'] as String,
    );

Map<String, dynamic> _$socialBeanToJson(socialBean instance) =>
    <String, dynamic>{
      'facebook': instance.facebook,
      'twitter': instance.twitter,
      'youtube': instance.youtube,
      'linkedin': instance.linkedin,
    };

InstructorDataBean _$InstructorDataBeanFromJson(Map<String, dynamic> json) =>
    InstructorDataBean(
      courses: json['total_courses'] as num,
      students: json['total_users'] as num,
    );

Map<String, dynamic> _$InstructorDataBeanToJson(InstructorDataBean instance) =>
    <String, dynamic>{
      'total_courses': instance.courses,
      'total_users': instance.students,
    };

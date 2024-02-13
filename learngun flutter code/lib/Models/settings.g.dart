// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

settings _$settingsFromJson(Map<String, dynamic> json) => settings(
      PrimaryColor: json['primary-color'] as String,
      SecondaryColor: json['secondary-color'] as String,
      banner_title: json['banner_title'] as List<dynamic>? ?? const [],
      home_category_courses:
          json['home_category_courses'] as List<dynamic>? ?? const [],
      banner_image: (json['banner_image'] as List<dynamic>?)
              ?.map((e) => BannerimageBean.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      BannerType: json['banner-type'] as List<dynamic>? ?? const [],
      type_value: json['type_value'] as List<dynamic>? ?? const [],
      Typography:
          typography.fromJson(json['opt-typography'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$settingsToJson(settings instance) => <String, dynamic>{
      'primary-color': instance.PrimaryColor,
      'secondary-color': instance.SecondaryColor,
      'banner_title': instance.banner_title,
      'home_category_courses': instance.home_category_courses,
      'banner_image': instance.banner_image,
      'banner-type': instance.BannerType,
      'opt-typography': instance.Typography,
      'type_value': instance.type_value,
    };

BannerimageBean _$BannerimageBeanFromJson(Map<String, dynamic> json) =>
    BannerimageBean(
      url: json['url'] as String,
    );

Map<String, dynamic> _$BannerimageBeanToJson(BannerimageBean instance) =>
    <String, dynamic>{
      'url': instance.url,
    };

typography _$typographyFromJson(Map<String, dynamic> json) => typography(
      FontFamily: json['font-family'] as String? ?? "",
    );

Map<String, dynamic> _$typographyToJson(typography instance) =>
    <String, dynamic>{
      'font-family': instance.FontFamily,
    };

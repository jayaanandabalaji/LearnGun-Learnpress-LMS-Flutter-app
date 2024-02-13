import 'package:json_annotation/json_annotation.dart';
part 'settings.g.dart';

@JsonSerializable()
class settings {
  @JsonKey(name: "primary-color")
  final String PrimaryColor;
  @JsonKey(name: "secondary-color")
  final String SecondaryColor;
  List banner_title = [];
  List home_category_courses = [];
  List<BannerimageBean> banner_image;
  @JsonKey(name: "banner-type")
  final List BannerType;
  @JsonKey(name: "opt-typography")
  final typography Typography;
  List type_value;
  settings(
      {required this.PrimaryColor,
      required this.SecondaryColor,
      this.banner_title = const [],
      this.home_category_courses = const [],
      this.banner_image = const [],
      this.BannerType = const [],
      this.type_value = const [],
      required this.Typography});
  factory settings.fromJson(Map<String, dynamic> json) => _$settingsFromJson(json);
  Map<String, dynamic> toJson() => _$settingsToJson(this);
}

@JsonSerializable()
class BannerimageBean {
  String url;
  BannerimageBean({required this.url});
  factory BannerimageBean.fromJson(Map<String, dynamic> json) => _$BannerimageBeanFromJson(json);
  Map<String, dynamic> toJson() => _$BannerimageBeanToJson(this);
}

@JsonSerializable()
class typography {
  @JsonKey(name: "font-family")
  final String FontFamily;
  typography({this.FontFamily = ""});
  factory typography.fromJson(Map<String, dynamic> json) => _$typographyFromJson(json);
  Map<String, dynamic> toJson() => _$typographyToJson(this);
}

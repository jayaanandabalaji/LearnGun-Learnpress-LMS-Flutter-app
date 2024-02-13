import 'package:json_annotation/json_annotation.dart';

part 'Courses.g.dart';

@JsonSerializable()
class Courses {
  num id;
  String name;
  String permalink;
  String image;
  bool on_sale;
  String status;
  String date_modified_gmt;
  String content;
  String duration;
  var can_retake;
  int ratake_count;
  bool can_finish;
  final rating;
  num count_students;
  num price;
  num origin_price;
  num sale_price;
  List<CategoryBean> categories;
  List<TagsBean> tags;
  InstructorBean instructor;
  List<SectionBean> sections;
  CourseDataBean course_data;
  metaDataBean meta_data;
  var certificate;
  final membership;
  Courses(
      {required this.id,
      required this.membership,
      required this.name,
      required this.permalink,
      required this.image,
      required this.on_sale,
      required this.status,
      required this.date_modified_gmt,
      required this.content,
      required this.duration,
      required this.can_retake,
      required this.ratake_count,
      required this.can_finish,
      required this.rating,
      required this.count_students,
      required this.price,
      required this.origin_price,
      required this.sale_price,
      required this.categories,
      required this.tags,
      required this.instructor,
      required this.sections,
      required this.course_data,
      required this.meta_data,
      required this.certificate});
  factory Courses.fromJson(Map<String, dynamic> json) =>
      _$CoursesFromJson(json);
  Map<String, dynamic> toJson() => _$CoursesToJson(this);
}

@JsonSerializable()
class CategoryBean {
  num id;
  String name;
  String slug;
  CategoryBean({this.id = -1, this.name = "", this.slug = ""});
  factory CategoryBean.fromJson(Map<String, dynamic> json) =>
      _$CategoryBeanFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryBeanToJson(this);
}

@JsonSerializable()
class TagsBean {
  num id;
  String name;
  String slug;
  TagsBean({this.id = -1, this.name = "", this.slug = ""});
  factory TagsBean.fromJson(Map<String, dynamic> json) =>
      _$TagsBeanFromJson(json);

  Map<String, dynamic> toJson() => _$TagsBeanToJson(this);
}

@JsonSerializable()
class InstructorBean {
  String avatar;
  num id;
  String name;
  String description;
  InstructorBean(
      {this.avatar = "", this.id = -1, this.name = "", this.description = ""});
  factory InstructorBean.fromJson(Map<String, dynamic> json) =>
      _$InstructorBeanFromJson(json);

  Map<String, dynamic> toJson() => _$InstructorBeanToJson(this);
}

@JsonSerializable()
class CourseDataBean {
  String graduation;
  String status;
  String start_time;
  final end_time;
  String expiration_time;
  courseResultsBean result;
  CourseDataBean(
      {required this.graduation,
      this.start_time = "",
      this.end_time = "",
      required this.status,
      required this.result,
      required this.expiration_time});
  factory CourseDataBean.fromJson(Map<String, dynamic> json) =>
      _$CourseDataBeanFromJson(json);
  Map<String, dynamic> toJson() => _$CourseDataBeanToJson(this);
}

@JsonSerializable()
class courseResultsBean {
  num result;
  num count_items;
  num completed_items;
  courseResultsBean(
      {required this.result,
      required this.completed_items,
      required this.count_items});
  factory courseResultsBean.fromJson(Map<String, dynamic> json) =>
      _$courseResultsBeanFromJson(json);
  Map<String, dynamic> toJson() => _$courseResultsBeanToJson(this);
}

@JsonSerializable()
class SectionBean {
  String id;
  String title;
  String description;
  num percent;
  List<ItemsBean> items;
  SectionBean(
      {required this.id,
      required this.title,
      required this.description,
      this.percent = 0,
      required this.items});
  factory SectionBean.fromJson(Map<String, dynamic> json) =>
      _$SectionBeanFromJson(json);
  Map<String, dynamic> toJson() => _$SectionBeanToJson(this);
}

@JsonSerializable()
class ItemsBean {
  num id;
  String type;
  String title;
  bool preview;
  String duration;
  String graduation;
  String status;
  bool locked;
  ItemsBean(
      {required this.id,
      required this.title,
      required this.type,
      required this.preview,
      required this.duration,
      required this.graduation,
      required this.status,
      required this.locked});
  factory ItemsBean.fromJson(Map<String, dynamic> json) =>
      _$ItemsBeanFromJson(json);
  Map<String, dynamic> toJson() => _$ItemsBeanToJson(this);
}

@JsonSerializable()
class metaDataBean {
  @JsonKey(name: "_lp_level")
  final lp_level;
  @JsonKey(name: "_lp_requirements")
  final lp_requirements;
  @JsonKey(name: "_lp_target_audiences")
  final lp_target_audiences;
  @JsonKey(name: "_lp_key_features")
  final lp_key_features;
  @JsonKey(name: "_lp_faqs")
  final lp_faqs;

  metaDataBean(
      {required this.lp_level,
      required this.lp_requirements,
      required this.lp_target_audiences,
      required this.lp_key_features,
      required this.lp_faqs});
  factory metaDataBean.fromJson(Map<String, dynamic> json) =>
      _$metaDataBeanFromJson(json);
  Map<String, dynamic> toJson() => _$metaDataBeanToJson(this);
}

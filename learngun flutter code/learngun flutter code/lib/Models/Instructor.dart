import 'package:json_annotation/json_annotation.dart';
part 'Instructor.g.dart';

@JsonSerializable()
class Instructor {
  int id;
  String name;
  String email;
  String description;
  String link;
  String avatar_url;
  String first_name;
  String last_name;
  socialBean social;
  InstructorDataBean instructor_data;
  Instructor(
      {required this.id,
      required this.name,
      required this.email,
      required this.description,
      required this.link,
      required this.avatar_url,
      required this.first_name,
      required this.last_name,
      required this.social,
      required this.instructor_data});
  factory Instructor.fromJson(Map<String, dynamic> json) => _$InstructorFromJson(json);
  Map<String, dynamic> toJson() => _$InstructorToJson(this);
}

@JsonSerializable()
class socialBean {
  String facebook;
  String twitter;
  String youtube;
  String linkedin;
  socialBean({required this.facebook, required this.twitter, required this.youtube, required this.linkedin});
  factory socialBean.fromJson(Map<String, dynamic> json) => _$socialBeanFromJson(json);
  Map<String, dynamic> toJson() => _$socialBeanToJson(this);
}

@JsonSerializable()
class InstructorDataBean {
  @JsonKey(name: "total_courses")
  num courses;
  @JsonKey(name: "total_users")
  num students;
  InstructorDataBean({required this.courses, required this.students});
  factory InstructorDataBean.fromJson(Map<String, dynamic> json) => _$InstructorDataBeanFromJson(json);
  Map<String, dynamic> toJson() => _$InstructorDataBeanToJson(this);
}

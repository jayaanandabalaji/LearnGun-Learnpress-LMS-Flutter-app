import 'package:json_annotation/json_annotation.dart';

part 'Reviews.g.dart';

@JsonSerializable()
class reviews {
  String comment_id;
  String display_name;
  String title;
  String content;
  String rate;
  String avatar;
  String time;
  reviews(
      {required this.title,
      required this.content,
      required this.avatar,
      required this.comment_id,
      required this.display_name,
      required this.rate,
      required this.time});
  factory reviews.fromJson(Map<String, dynamic> json) => _$reviewsFromJson(json);
  Map<String, dynamic> toJson() => _$reviewsToJson(this);
}

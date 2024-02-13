import 'package:json_annotation/json_annotation.dart';
part 'StartQuiz.g.dart';

@JsonSerializable()
class StartQuizResponse {
  String status;
  String message;
  ResultsBean results;
  StartQuizResponse({
    required this.status,
    required this.message,
    required this.results,
  });
  factory StartQuizResponse.fromJson(Map<String, dynamic> json) => _$StartQuizResponseFromJson(json);
  Map<String, dynamic> toJson() => _$StartQuizResponseToJson(this);
}

@JsonSerializable()
class ResultsBean {
  num duration;
  String status;
  num retaken;
  List<QuestionsBean> questions;
  var answered;
  ResultsBean(
      {required this.duration,
      required this.status,
      required this.retaken,
      required this.questions,
      required this.answered});
  factory ResultsBean.fromJson(Map<String, dynamic> json) => _$ResultsBeanFromJson(json);
  Map<String, dynamic> toJson() => _$ResultsBeanToJson(this);
}

@JsonSerializable()
class QuestionsBean {
  num id;
  String title;
  String type;
  num point;
  String content;
  List<OptionsBean> options;
  QuestionsBean(
      {required this.id,
      required this.title,
      required this.type,
      required this.point,
      this.content = "",
      required this.options});
  factory QuestionsBean.fromJson(Map<String, dynamic> json) => _$QuestionsBeanFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionsBeanToJson(this);
}

@JsonSerializable()
class OptionsBean {
  String title;
  String value;
  num uid;
  OptionsBean({required this.title, required this.value, this.uid = 0});
  factory OptionsBean.fromJson(Map<String, dynamic> json) => _$OptionsBeanFromJson(json);

  Map<String, dynamic> toJson() => _$OptionsBeanToJson(this);
}

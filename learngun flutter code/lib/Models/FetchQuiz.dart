import 'package:json_annotation/json_annotation.dart';
part 'FetchQuiz.g.dart';

@JsonSerializable()
class FetchQuiz {
  num id;
  String name;
  String permalink;
  String status;
  String content;
  bool can_finish_course;
  String duration;
  List<QuestionsBean> questions;
  ResultsBean results;
  FetchQuiz(
      {required this.id,
      required this.name,
      required this.permalink,
      required this.status,
      required this.content,
      required this.can_finish_course,
      required this.duration,
      required this.questions,
      required this.results});
  factory FetchQuiz.fromJson(Map<String, dynamic> json) => _$FetchQuizFromJson(json);

  Map<String, dynamic> toJson() => _$FetchQuizToJson(this);
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
  OptionsBean({required this.title, required this.value, required this.uid});
  factory OptionsBean.fromJson(Map<String, dynamic> json) => _$OptionsBeanFromJson(json);

  Map<String, dynamic> toJson() => _$OptionsBeanToJson(this);
}

@JsonSerializable()
class ResultsBean {
  String passing_grade;
  bool negative_marking;
  bool instant_check;
  num retake_count;
  num duration;
  String status;
  num retaken;
  final results;
  List<AttemptsBean> attempts;
  final answered;
  ResultsBean(
      {required this.passing_grade,
      required this.negative_marking,
      required this.instant_check,
      required this.retake_count,
      required this.duration,
      required this.status,
      required this.retaken,
      this.results = "",
      required this.attempts,
      this.answered});
  factory ResultsBean.fromJson(Map<String, dynamic> json) => _$ResultsBeanFromJson(json);

  Map<String, dynamic> toJson() => _$ResultsBeanToJson(this);
}

@JsonSerializable()
class AttemptsBean {
  num mark;
  num user_mark;
  int question_count;
  int question_empty;
  int question_answered;
  int question_wrong;
  int question_correct;
  String status;
  num result;
  String time_spend;
  String passing_grade;
  num pass;
  AttemptsBean({
    required this.mark,
    required this.user_mark,
    required this.question_answered,
    required this.question_empty,
    required this.question_count,
    required this.question_correct,
    required this.question_wrong,
    required this.status,
    required this.result,
    required this.passing_grade,
    this.pass = 0,
    required this.time_spend,
  });
  factory AttemptsBean.fromJson(Map<String, dynamic> json) => _$AttemptsBeanFromJson(json);
  Map<String, dynamic> toJson() => _$AttemptsBeanToJson(this);
}

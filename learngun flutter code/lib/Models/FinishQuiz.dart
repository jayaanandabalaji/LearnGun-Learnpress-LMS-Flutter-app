import 'package:json_annotation/json_annotation.dart';

part 'FinishQuiz.g.dart';

@JsonSerializable()
class FinishQuiz {
  String status;
  String message;
  ResultsBean results;
  FinishQuiz({required this.status, required this.message, required this.results});
  factory FinishQuiz.fromJson(Map<String, dynamic> json) => _$FinishQuizFromJson(json);
  Map<String, dynamic> toJson() => _$FinishQuizToJson(this);
}

@JsonSerializable()
class ResultsBean {
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
  List<AttemptsBean> attempts;
  final answered;
  ResultsBean(
      {required this.mark,
      required this.user_mark,
      required this.question_answered,
      required this.question_empty,
      required this.question_count,
      required this.question_correct,
      required this.question_wrong,
      required this.status,
      required this.result,
      required this.passing_grade,
      required this.pass,
      required this.time_spend,
      required this.attempts,
      required this.answered});
  factory ResultsBean.fromJson(Map<String, dynamic> json) => _$ResultsBeanFromJson(json);
  Map<String, dynamic> toJson() => _$ResultsBeanToJson(this);
}

@JsonSerializable()
class AnsweredBean {
  final answered;
  bool correct;
  num mark;
  String explanation;
  OptionsBean options;
  AnsweredBean(
      {required this.mark,
      required this.answered,
      required this.correct,
      required this.explanation,
      required this.options});
  factory AnsweredBean.fromJson(Map<String, dynamic> json) => _$AnsweredBeanFromJson(json);
  Map<String, dynamic> toJson() => _$AnsweredBeanToJson(this);
}

@JsonSerializable()
class OptionsBean {
  String title;
  String value;
  String is_true;
  int uid;
  OptionsBean({required this.value, required this.uid, required this.title, required this.is_true});
  factory OptionsBean.fromJson(Map<String, dynamic> json) => _$OptionsBeanFromJson(json);
  Map<String, dynamic> toJson() => _$OptionsBeanToJson(this);
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
  AttemptsBean(
      {required this.mark,
      required this.user_mark,
      required this.question_answered,
      required this.question_empty,
      required this.question_count,
      required this.question_correct,
      required this.question_wrong,
      required this.status,
      required this.result,
      required this.passing_grade,
      required this.pass,
      required this.time_spend});
  factory AttemptsBean.fromJson(Map<String, dynamic> json) => _$AttemptsBeanFromJson(json);
  Map<String, dynamic> toJson() => _$AttemptsBeanToJson(this);
}

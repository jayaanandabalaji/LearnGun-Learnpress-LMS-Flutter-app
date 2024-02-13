// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'FinishQuiz.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FinishQuiz _$FinishQuizFromJson(Map<String, dynamic> json) => FinishQuiz(
      status: json['status'] as String,
      message: json['message'] as String,
      results: ResultsBean.fromJson(json['results'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FinishQuizToJson(FinishQuiz instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'results': instance.results,
    };

ResultsBean _$ResultsBeanFromJson(Map<String, dynamic> json) => ResultsBean(
      mark: json['mark'] as num,
      user_mark: json['user_mark'] as num,
      question_answered: json['question_answered'] as int,
      question_empty: json['question_empty'] as int,
      question_count: json['question_count'] as int,
      question_correct: json['question_correct'] as int,
      question_wrong: json['question_wrong'] as int,
      status: json['status'] as String,
      result: json['result'] as num,
      passing_grade: json['passing_grade'] as String,
      pass: json['pass'] as num,
      time_spend: json['time_spend'] as String,
      attempts: (json['attempts'] as List<dynamic>)
          .map((e) => AttemptsBean.fromJson(e as Map<String, dynamic>))
          .toList(),
      answered: json['answered'],
    );

Map<String, dynamic> _$ResultsBeanToJson(ResultsBean instance) =>
    <String, dynamic>{
      'mark': instance.mark,
      'user_mark': instance.user_mark,
      'question_count': instance.question_count,
      'question_empty': instance.question_empty,
      'question_answered': instance.question_answered,
      'question_wrong': instance.question_wrong,
      'question_correct': instance.question_correct,
      'status': instance.status,
      'result': instance.result,
      'time_spend': instance.time_spend,
      'passing_grade': instance.passing_grade,
      'pass': instance.pass,
      'attempts': instance.attempts,
      'answered': instance.answered,
    };

AnsweredBean _$AnsweredBeanFromJson(Map<String, dynamic> json) => AnsweredBean(
      mark: json['mark'] as num,
      answered: json['answered'],
      correct: json['correct'] as bool,
      explanation: json['explanation'] as String,
      options: OptionsBean.fromJson(json['options'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AnsweredBeanToJson(AnsweredBean instance) =>
    <String, dynamic>{
      'answered': instance.answered,
      'correct': instance.correct,
      'mark': instance.mark,
      'explanation': instance.explanation,
      'options': instance.options,
    };

OptionsBean _$OptionsBeanFromJson(Map<String, dynamic> json) => OptionsBean(
      value: json['value'] as String,
      uid: json['uid'] as int,
      title: json['title'] as String,
      is_true: json['is_true'] as String,
    );

Map<String, dynamic> _$OptionsBeanToJson(OptionsBean instance) =>
    <String, dynamic>{
      'title': instance.title,
      'value': instance.value,
      'is_true': instance.is_true,
      'uid': instance.uid,
    };

AttemptsBean _$AttemptsBeanFromJson(Map<String, dynamic> json) => AttemptsBean(
      mark: json['mark'] as num,
      user_mark: json['user_mark'] as num,
      question_answered: json['question_answered'] as int,
      question_empty: json['question_empty'] as int,
      question_count: json['question_count'] as int,
      question_correct: json['question_correct'] as int,
      question_wrong: json['question_wrong'] as int,
      status: json['status'] as String,
      result: json['result'] as num,
      passing_grade: json['passing_grade'] as String,
      pass: json['pass'] as num,
      time_spend: json['time_spend'] as String,
    );

Map<String, dynamic> _$AttemptsBeanToJson(AttemptsBean instance) =>
    <String, dynamic>{
      'mark': instance.mark,
      'user_mark': instance.user_mark,
      'question_count': instance.question_count,
      'question_empty': instance.question_empty,
      'question_answered': instance.question_answered,
      'question_wrong': instance.question_wrong,
      'question_correct': instance.question_correct,
      'status': instance.status,
      'result': instance.result,
      'time_spend': instance.time_spend,
      'passing_grade': instance.passing_grade,
      'pass': instance.pass,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'FetchQuiz.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FetchQuiz _$FetchQuizFromJson(Map<String, dynamic> json) => FetchQuiz(
      id: json['id'] as num,
      name: json['name'] as String,
      permalink: json['permalink'] as String,
      status: json['status'] as String,
      content: json['content'] as String,
      can_finish_course: json['can_finish_course'] as bool,
      duration: json['duration'] as String,
      questions: (json['questions'] as List<dynamic>)
          .map((e) => QuestionsBean.fromJson(e as Map<String, dynamic>))
          .toList(),
      results: ResultsBean.fromJson(json['results'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FetchQuizToJson(FetchQuiz instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'permalink': instance.permalink,
      'status': instance.status,
      'content': instance.content,
      'can_finish_course': instance.can_finish_course,
      'duration': instance.duration,
      'questions': instance.questions,
      'results': instance.results,
    };

QuestionsBean _$QuestionsBeanFromJson(Map<String, dynamic> json) =>
    QuestionsBean(
      id: json['id'] as num,
      title: json['title'] as String,
      type: json['type'] as String,
      point: json['point'] as num,
      content: json['content'] as String? ?? "",
      options: (json['options'] as List<dynamic>)
          .map((e) => OptionsBean.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$QuestionsBeanToJson(QuestionsBean instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'type': instance.type,
      'point': instance.point,
      'content': instance.content,
      'options': instance.options,
    };

OptionsBean _$OptionsBeanFromJson(Map<String, dynamic> json) => OptionsBean(
      title: json['title'] as String,
      value: json['value'] as String,
      uid: json['uid'] as num,
    );

Map<String, dynamic> _$OptionsBeanToJson(OptionsBean instance) =>
    <String, dynamic>{
      'title': instance.title,
      'value': instance.value,
      'uid': instance.uid,
    };

ResultsBean _$ResultsBeanFromJson(Map<String, dynamic> json) => ResultsBean(
      passing_grade: json['passing_grade'] as String,
      negative_marking: json['negative_marking'] as bool,
      instant_check: json['instant_check'] as bool,
      retake_count: json['retake_count'] as num,
      duration: json['duration'] as num,
      status: json['status'] as String,
      retaken: json['retaken'] as num,
      results: json['results'] ?? "",
      attempts: (json['attempts'] as List<dynamic>)
          .map((e) => AttemptsBean.fromJson(e as Map<String, dynamic>))
          .toList(),
      answered: json['answered'],
    );

Map<String, dynamic> _$ResultsBeanToJson(ResultsBean instance) =>
    <String, dynamic>{
      'passing_grade': instance.passing_grade,
      'negative_marking': instance.negative_marking,
      'instant_check': instance.instant_check,
      'retake_count': instance.retake_count,
      'duration': instance.duration,
      'status': instance.status,
      'retaken': instance.retaken,
      'results': instance.results,
      'attempts': instance.attempts,
      'answered': instance.answered,
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
      pass: json['pass'] as num? ?? 0,
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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'StartQuiz.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StartQuizResponse _$StartQuizResponseFromJson(Map<String, dynamic> json) =>
    StartQuizResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      results: ResultsBean.fromJson(json['results'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StartQuizResponseToJson(StartQuizResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'results': instance.results,
    };

ResultsBean _$ResultsBeanFromJson(Map<String, dynamic> json) => ResultsBean(
      duration: json['duration'] as num,
      status: json['status'] as String,
      retaken: json['retaken'] as num,
      questions: (json['questions'] as List<dynamic>)
          .map((e) => QuestionsBean.fromJson(e as Map<String, dynamic>))
          .toList(),
      answered: json['answered'],
    );

Map<String, dynamic> _$ResultsBeanToJson(ResultsBean instance) =>
    <String, dynamic>{
      'duration': instance.duration,
      'status': instance.status,
      'retaken': instance.retaken,
      'questions': instance.questions,
      'answered': instance.answered,
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
      uid: json['uid'] as num? ?? 0,
    );

Map<String, dynamic> _$OptionsBeanToJson(OptionsBean instance) =>
    <String, dynamic>{
      'title': instance.title,
      'value': instance.value,
      'uid': instance.uid,
    };

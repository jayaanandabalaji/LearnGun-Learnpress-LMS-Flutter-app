import 'BaseAPI.dart';

class LessonsApi {
  static CompleteLesson(int LessonId) async {
    var response = await baseAPI().postAsync(
        "lessons/finish?id=" + LessonId.toString(), {"requirestoken": "true"});
    return response;
  }

  static GetLesson(int LessonId) async {
    var response = await baseAPI().getAsync("lessons/" + LessonId.toString(),
        data: {"requirestoken": "true"});
    return response;
  }

  static GetH5P(int LessonId) async {
    var response = await baseAPI().getAsync(
        "learnpressapp/v1/h5p_lesson?id=" + LessonId.toString(),
        data: {"requirestoken": "true"},
        customUrl: true);
    return response;
  }
}

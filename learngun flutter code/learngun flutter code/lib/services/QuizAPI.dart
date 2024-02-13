import '../../Models/FetchQuiz.dart';
import '../../Models/StartQuiz.dart';
import 'BaseAPI.dart';
import '../../Models/FinishQuiz.dart';

class QuizApi {
  static GetQuiz(num QuizID) async {
    var response = await baseAPI().getAsync("quiz/" + QuizID.toString(), data: {"requirestoken": "true"});
    try {
      return FetchQuiz.fromJson(response);
    } catch (e) {
      return response;
    }
  }

  static StartQuiz(num QuizID) async {
    var response = await baseAPI().postAsync("quiz/start?id=" + QuizID.toString(), {"requirestoken": "true"});
    try {
      StartQuizResponse.fromJson(response);
    } catch (e) {
      return response["message"];
    }
    return StartQuizResponse.fromJson(response);
  }

  static finishQuiz(num QuizID, var data, num timeSpent) async {
    var response = await baseAPI().postAsync("learnpressapp/v1/quiz/finish",
        {"requirestoken": "true", "id": QuizID.toString(), "answered": data, "time_spend": timeSpent.toString()},
        customUrl: true);
    return FinishQuiz.fromJson(response);
  }
}

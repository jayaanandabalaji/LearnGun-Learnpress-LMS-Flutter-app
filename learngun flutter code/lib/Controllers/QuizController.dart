import 'dart:async';
import 'package:get/get.dart';

import '../widgets/Notify/notify.dart';
import '../screens/Quiz/QuizHome.dart';
import '../screens/Quiz/QuizResult.dart';
import '../services/QuizAPI.dart';
import '../Models/FetchQuiz.dart';
import '../screens/Quiz/QuizReview.dart';
import '../screens/Quiz/TakeQuiz.dart';

class Quizcontroller extends GetxController {
  var startQuizLoading = false.obs;
  var answered_array = {};
  var quizTimer = 0.obs;
  var Startquiz;
  var fetchQuiz;
  var QuizHomeLoading = false.obs;

  openQuiz(FetchQuiz Quiz) {
    startQuizLoading.value = false;
    fetchQuiz = Quiz;
    Get.to(quizscreen());
  }

  RefreshQuizHome() async {
    QuizHomeLoading.value = true;
    FetchQuiz response = await QuizApi.GetQuiz(fetchQuiz.id);
    fetchQuiz = response;
    fetchQuiz.results.attempts.insert(0, AttemptsBean.fromJson(fetchQuiz.results.results));
    QuizHomeLoading.value = false;
  }

  StartQuiz(FetchQuiz Quiz) async {
    answered_array = {};
    startQuizLoading.value = true;
    Startquiz = Quiz;
    quizTimer.value = Quiz.results.duration as dynamic;
    var response = await QuizApi.StartQuiz(Quiz.id);

    if (response.runtimeType.toString() == "String") {
      if (response == "LP_User::retake_quiz - User has not completed quiz.") {
        Get.to(TakeQuizScreen(Quiz.questions, 0, Quiz.name));
      }
    } else {
      Get.to(TakeQuizScreen(response.results.questions, 0, Quiz.name));
    }
    startTimer(response.results.questions);
    startQuizLoading.value = false;
  }

  get_question_position(var question, var questions) {
    int count = 0;
    for (var Question in questions) {
      count++;
      if (Question.id == question.id) {
        break;
      }
    }
    return count;
  }

  startTimer(var questions) {
    Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (quizTimer.value == 0 || quizTimer.value < 0) {
          if (quizTimer.value < 0) {
            timer.cancel();
          } else {
            finishQuiz(questions);
          }
        } else {
          quizTimer.value--;
        }
      },
    );
  }

  finishQuiz(var questions) async {
    notify.showLoadingDialog("Finishing Quiz...");
    var response = await QuizApi.finishQuiz(Startquiz.id, answered_array, Startquiz.results.duration - quizTimer.value);
    quizTimer.value = -1;
    Get.back();
    RefreshQuizHome();
    Get.off(() => QuizResultScreen(response, questions));
  }

  reviewQuiz(var Questions, var answered) {
    Get.to(QuizReview(Questions, answered));
  }
}

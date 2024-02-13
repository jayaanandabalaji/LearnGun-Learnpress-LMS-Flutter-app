import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/constants.dart';
import '../../widgets/HtmlWidget.dart';
import '../../Controllers/QuizController.dart';
import '../../Models/FetchQuiz.dart';
import '../../widgets/Card.dart';
import '../../widgets/Button.dart';

// ignore: must_be_immutable
class StartQuizWidget extends StatelessWidget {
  FetchQuiz Quiz;
  StartQuizWidget(this.Quiz);
  final Quizcontroller _quizcontroller = Get.put(Quizcontroller());
  @override
  Widget build(BuildContext context) {
    return card.shadow_card(Padding(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
        child: Column(
          children: [
            Center(
                child: Text(
              Quiz.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25.sp,
              ),
            )),
            html_content.html_widget(Quiz.content),
            build_Quiz_details("Questions".tr + " ", Icons.quiz, (Quiz.questions.length).toString()),
            build_Quiz_details("Duration".tr + " ", Icons.access_time_filled, Quiz.duration),
            build_Quiz_details("Passing grade".tr + " ", Icons.show_chart, Quiz.results.passing_grade, is_last: true),
            if (Quiz.results.attempts.isEmpty)
              Obx(() {
                if (!_quizcontroller.startQuizLoading.value) {
                  return theme_buttons.material_button("Start".tr, 0.5, onTap: () {
                    _quizcontroller.StartQuiz(Quiz);
                  });
                }
                return theme_buttons.material_button("", 0.5, is_circular: true);
              }),
            if (Quiz.results.retake_count - Quiz.results.retaken > 0)
              Obx(() {
                if (!_quizcontroller.startQuizLoading.value) {
                  return theme_buttons.material_button(
                      "Retake".tr + " (" + (Quiz.results.retake_count - Quiz.results.retaken).toString() + ")", 0.5,
                      onTap: () {
                    _quizcontroller.StartQuiz(Quiz);
                  });
                }
                return theme_buttons.material_button("", 0.5, is_circular: true);
              }),
            if (Quiz.results.answered.length > 0)
              theme_buttons.material_button("Review".tr, 0.5, onTap: () {
                _quizcontroller.reviewQuiz(Quiz.questions, Quiz.results.answered);
              })
          ],
        )));
  }

  Widget build_Quiz_details(String title, var icon, String value, {is_last = false}) {
    return Container(
      decoration: BoxDecoration(
          border: Border(
        bottom: BorderSide(
          //                    <--- top side
          color: (is_last) ? Colors.white : Colors.grey,
          width: 1.w,
        ),
      )),
      padding: EdgeInsets.fromLTRB(0, 10.h, 0, 10.h),
      child: Row(
        children: [
          Icon(
            icon,
            color: Constants.primary_color,
          ),
          SizedBox(
            width: 10.w,
          ),
          Text(
            title,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(value)
        ],
      ),
    );
  }
}

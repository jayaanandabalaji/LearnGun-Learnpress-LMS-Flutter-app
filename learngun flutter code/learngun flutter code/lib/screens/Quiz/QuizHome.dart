import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../widgets/Card.dart';
import '../../Models/FetchQuiz.dart';
import '../../Controllers/QuizController.dart';
import '../../utils/constants.dart';
import 'StartQuizWidget.dart';

class quizscreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<quizscreen> {
  final Quizcontroller _quizcontroller = Get.put(Quizcontroller());
  @override
  void initState() {
    if (_quizcontroller.fetchQuiz.results.results != "") {
      _quizcontroller.fetchQuiz.results.attempts
          .insert(0, AttemptsBean.fromJson(_quizcontroller.fetchQuiz.results.results));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.black, //change your color here
          ),
          elevation: 0,
          backgroundColor: Colors.white,
        ),
        body: Obx(() {
          if (!_quizcontroller.QuizHomeLoading.value) {
            return ListView(
              children: [
                Padding(
                    padding: EdgeInsets.fromLTRB(30.w, 30.h, 30.w, 30.h),
                    child: StartQuizWidget(_quizcontroller.fetchQuiz)),
                if (_quizcontroller.fetchQuiz.results.attempts.length > 0)
                  Padding(
                    padding: EdgeInsets.fromLTRB(30.w, 0, 30.w, 30.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Previous attempts".tr,
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                        for (var attempt in _quizcontroller.fetchQuiz.results.attempts) build_attempt(attempt)
                      ],
                    ),
                  )
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }));
  }

  static Widget build_attempt(AttemptsBean attempt) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 10.h, 0, 10.h),
      child: card.shadow_card(Container(
        padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 10.h),
        child: Row(
          children: [
            CircularPercentIndicator(
              progressColor: Constants.primary_color,
              radius: 50.r,
              lineWidth: 5.w,
              animation: true,
              percent: attempt.result / 100.toDouble(),
              center: Text(
                num.parse(attempt.result.toStringAsFixed(2)).toString() + "%",
                style: TextStyle(fontSize: 19.sp),
              ),
              circularStrokeCap: CircularStrokeCap.round,
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 10.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Time Taken".tr,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Text(attempt.time_spend)
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Marks".tr,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Text(attempt.user_mark.toString() + " / " + attempt.mark.toString())
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Questions".tr,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Text(attempt.question_answered.toString() + " / " + attempt.question_count.toString())
                    ],
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                ],
              ),
            )
          ],
        ),
      )),
    );
  }
}

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';

import '../../utils/constants.dart';
import '../../widgets/Button.dart';
import '../../Controllers/QuizController.dart';
import '../../Models/FinishQuiz.dart';

class QuizResultsWidget extends StatelessWidget {
  final FinishQuiz response;
  final questions;
  QuizResultsWidget(this.response, this.questions);
  static ScreenshotController screenshotController = ScreenshotController();
  final Quizcontroller _quizcontroller = Get.put(Quizcontroller());
  @override
  Widget build(BuildContext context) {
    return Screenshot(
        controller: screenshotController,
        child: Container(
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularPercentIndicator(
                  progressColor: Constants.primary_color,
                  radius: 90.r,
                  lineWidth: 20.w,
                  animation: true,
                  percent: response.results.result / 100.toDouble(),
                  center: Text(
                    num.parse(response.results.result.toStringAsFixed(2)).toString() + "%",
                    style: TextStyle(fontSize: 25.sp),
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                ),
                SizedBox(
                  height: 25.h,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Your todays results are here".tr + ":",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 20.h, 0, 20.h),
                  decoration: BoxDecoration(
                      border: Border(
                    bottom: BorderSide(
                      //                   <--- left side
                      color: Colors.grey.withOpacity(0.5),
                      width: 2.w,
                    ),
                  )),
                  child: Row(
                    children: [
                      results_widget("Correct".tr, response.results.question_correct, Icons.check_circle, Colors.green),
                      results_widget("Skipped".tr, response.results.question_empty, Icons.fiber_manual_record_outlined,
                          Constants.primary_color),
                      results_widget(
                          "Wrong".tr, response.results.question_wrong, FontAwesomeIcons.solidCircleXmark, Colors.red),
                    ],
                  ),
                ),
                build_row("Time Taken".tr, response.results.time_spend),
                build_row("Marks".tr, response.results.user_mark.toString() + " / " + response.results.mark.toString()),
                build_row("Status".tr, response.results.status),
                SizedBox(
                  height: 10.h,
                ),
                theme_buttons.material_button("Review".tr, 0.7, onTap: () {
                  _quizcontroller.reviewQuiz(questions, response.results.answered);
                }),
                SizedBox(
                  height: 10.h,
                ),
                theme_buttons.material_button("Go back".tr, 0.7, onTap: () {
                  Get.back();
                }),
                share_widget(),
              ],
            ),
          ),
        ));
  }

  static Widget share_widget() {
    return Padding(
        padding: EdgeInsets.fromLTRB(10.w, 15.h, 10.w, 5.h),
        child: GestureDetector(
          onTap: () async {
            await screenshotController.capture(delay: const Duration(milliseconds: 10)).then((image) async {
              if (image != null) {
                final directory = await getApplicationDocumentsDirectory();
                final imagePath = await File('${directory.path}/image.png').create();
                await imagePath.writeAsBytes(image);

                /// Share Plugin
                await Share.shareFiles([imagePath.path],
                    text: "Hey, have a look at my score on".tr + " " + Constants.appName);
              }
            });
          },
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 10.h, 0, 10.h),
            color: Colors.grey.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.share),
                SizedBox(
                  width: 15.w,
                ),
                Text(
                  "Share results with your friends.".tr,
                  style: TextStyle(fontSize: 18.sp),
                )
              ],
            ),
          ),
        ));
  }

  Widget build_row(String text, String value) {
    return Container(
      decoration: BoxDecoration(
          border: Border(
        bottom: BorderSide(
          //                   <--- left side
          color: Colors.grey.withOpacity(0.1),
          width: 2.w,
        ),
      )),
      padding: EdgeInsets.fromLTRB(25.w, 15.h, 25.w, 15.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
          ),
          Text(value, style: TextStyle(fontSize: 17.sp))
        ],
      ),
    );
  }

  Widget results_widget(String text, int value, var icon, var color, {is_FontAwesome = false}) {
    return Container(
      decoration: BoxDecoration(
          border: Border(
        right: BorderSide(
          //                   <--- left side
          color: Colors.grey.withOpacity(0.5),
          width: 2.w,
        ),
      )),
      width: (Get.width - 13.3333333333.w) * 0.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              (is_FontAwesome)
                  ? FaIcon(
                      icon,
                      color: color,
                    )
                  : Icon(
                      icon,
                      color: color,
                    ),
              SizedBox(
                width: 5.w,
              ),
              Text(
                value.toString() + " / " + response.results.question_count.toString(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
              )
            ],
          ),
          SizedBox(
            height: 2.h,
          ),
          Text(
            text,
            style: TextStyle(color: Colors.grey, fontSize: 16.sp),
          ),
        ],
      ),
    );
  }
}

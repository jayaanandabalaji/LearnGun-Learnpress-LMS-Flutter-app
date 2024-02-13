import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../utils/constants.dart';
import '../../widgets/Button.dart';
import '../../Controllers/QuizController.dart';
import '../../widgets/HtmlWidget.dart';
import '../../widgets/Notify/notify.dart';

class TakeQuizScreen extends StatefulWidget {
  final List<dynamic> Questions;
  final int quiz_index;
  final String QuizTitle;
  const TakeQuizScreen(this.Questions, this.quiz_index, this.QuizTitle);
  @override
  _TakeQuizScreenState createState() => _TakeQuizScreenState();
}

class _TakeQuizScreenState extends State<TakeQuizScreen> {
  final Quizcontroller _quizcontroller = Get.put(Quizcontroller());
  @override
  Widget build(BuildContext context) {
    var currentQuestion = widget.Questions[widget.quiz_index];
    int questionIndex = _quizcontroller.get_question_position(currentQuestion, widget.Questions);
    int totalQuestions = widget.Questions.length;
    return WillPopScope(
        onWillPop: () async {
          return _promptconfirmation();
        },
        child: Scaffold(
          backgroundColor: Constants.primary_color,
          appBar: AppBar(
            elevation: 0,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                  onPressed: () {
                    _promptconfirmation();
                  },
                  icon: const Icon(
                    Icons.exit_to_app,
                    color: Colors.white,
                  ))
            ],
            title: Text(
              widget.QuizTitle,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          body: ListView(
            children: [
              give_padding(Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        "Question".tr + " " + questionIndex.toString(),
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20.sp),
                      ),
                      Text(
                        "/" + totalQuestions.toString(),
                        style: TextStyle(color: Colors.white70, fontSize: 17.sp),
                      ),
                    ],
                  ),
                  Obx(() {
                    return Text(
                      (_quizcontroller.quizTimer.value ~/ 60).toString().padLeft(2, '0') +
                          ":" +
                          (_quizcontroller.quizTimer.value % 60).toString().padLeft(2, '0'),
                      style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
                    );
                  }),
                ],
              )),
              give_padding(
                LinearPercentIndicator(
                  animation: false,
                  lineHeight: 16.h,
                  animationDuration: 2000,
                  percent: questionIndex / totalQuestions,
                  barRadius: Radius.circular(20.r),
                  progressColor: Colors.white,
                ),
              ),
              give_padding(Center(
                child: Container(
                  padding: EdgeInsets.all(20.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.r),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      Text(
                        currentQuestion.title,
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                      ),
                      html_content.html_widget(currentQuestion.content),
                      if (currentQuestion.type == "single_choice" || currentQuestion.type == "true_or_false")
                        build_radio(currentQuestion),
                      if (currentQuestion.type == "multi_choice") build_checkbox(currentQuestion),
                      if (currentQuestion.type == "fill_in_blanks") build_fill_in_the_blanks(currentQuestion),
                    ],
                  ),
                ),
              )),
              give_padding(Center(
                child: Row(
                  children: [
                    if (questionIndex != 1)
                      theme_buttons.material_button("Previous".tr, 0.4,
                          background_color: Colors.white, textColor: Constants.primary_color, onTap: () {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, a1, a2) =>
                                TakeQuizScreen(widget.Questions, widget.quiz_index - 1, widget.QuizTitle),
                            transitionsBuilder: (c, anim, a2, child) => SlideTransition(
                              position: Tween(begin: const Offset(-1, 0), end: const Offset(0, 0.0)).animate(anim),
                              child: child,
                            ),
                            transitionDuration: const Duration(milliseconds: 400),
                          ),
                        );
                      }),
                    const Spacer(),
                    if (questionIndex != totalQuestions)
                      theme_buttons.material_button("Next".tr, 0.4,
                          background_color: Colors.white, textColor: Constants.primary_color, onTap: () {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, a1, a2) =>
                                TakeQuizScreen(widget.Questions, widget.quiz_index + 1, widget.QuizTitle),
                            transitionsBuilder: (c, anim, a2, child) => SlideTransition(
                              position: Tween(begin: const Offset(1.0, 0.0), end: const Offset(0.0, 0.0)).animate(anim),
                              child: child,
                            ),
                            transitionDuration: const Duration(milliseconds: 400),
                          ),
                        );
                      }),
                    if (questionIndex == totalQuestions)
                      theme_buttons.material_button("Finish Quiz".tr, 0.4,
                          background_color: Colors.white, textColor: Constants.primary_color, onTap: () {
                        _promptconfirmation();
                      }),
                  ],
                ),
              ))
            ],
          ),
        ));
  }

  Widget build_fill_in_the_blanks(var question) {
    int fillupscount = 0;
    List fillupsIds = [];
    Map fillupsFilled = _quizcontroller.answered_array[question.id.toString()] ?? {};
    List fillup = question.options[0].title.split(RegExp('[}{]+'));
    return Column(
      children: [
        Text.rich(TextSpan(
            style: TextStyle(
              fontSize: 20.sp,
              height: 1.2.h,
            ),
            children: [
              for (String text in fillup)
                TextSpan(children: [
                  if (text.contains("FIB_"))
                    WidgetSpan(
                        child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(5.h),
                      child: Text(
                        (() {
                          fillupsIds.add(text.replaceAll("FIB_", ""));
                          fillupscount++;
                          return fillupscount.toString();
                        }()),
                        style: const TextStyle(color: Colors.white),
                      ),
                    )),
                  if (!text.contains("FIB_")) TextSpan(text: text)
                ]),
            ])),
        for (int i = 0; i < fillupscount; i++)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(5.h),
                    child: Text(
                      (i + 1).toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  const Text("------>")
                ],
              ),
              SizedBox(
                width: 150.w,
                child: TextFormField(
                  onChanged: (value) {
                    Map tempMap = _quizcontroller.answered_array[question.id.toString()] ?? {};
                    tempMap[fillupsIds[i]] = value;
                    _quizcontroller.answered_array[question.id.toString()] = tempMap;
                  },
                  initialValue: fillupsFilled[fillupsIds[i]] ?? "",
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      )),
                ),
              )
            ],
          )
      ],
    );
  }

  Widget build_radio(var questions) {
    String currentSelected = _quizcontroller.answered_array[questions.id.toString()] ?? "";
    var radioSelected = currentSelected.obs;
    return Column(
      children: [
        for (var option in questions.options)
          Obx(() {
            return Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.r),
                    color: Colors.grey.withOpacity(0.1),
                  ),
                  child: RadioListTile<String>(
                    controlAffinity: ListTileControlAffinity.trailing,
                    activeColor: Constants.primary_color,
                    value: option.value,
                    groupValue: radioSelected.value,
                    onChanged: (value) {
                      _quizcontroller.answered_array[questions.id.toString()] = option.value;
                      radioSelected.value = value ?? "";
                    },
                    title: Text(
                      option.title,
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.h,
                )
              ],
            );
          })
      ],
    );
  }

  Map checkbox_selected = {};

  Widget build_checkbox(var questions) {
    if (_quizcontroller.answered_array[questions.id.toString()] != null) {
      for (String value in _quizcontroller.answered_array[questions.id.toString()]) {
        checkbox_selected[value] = true;
      }
    }

    return Column(
      children: [
        for (var option in questions.options)
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.r),
                  color: Colors.grey.withOpacity(0.1),
                ),
                child: CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.trailing,
                  activeColor: Constants.primary_color,
                  value: checkbox_selected[option.value] ?? false,
                  onChanged: (value) {
                    setState(() {
                      checkbox_selected[option.value] = value;
                    });
                    List tempList = [];
                    for (var key in checkbox_selected.keys.toList()) {
                      if (checkbox_selected[key] == true) {
                        tempList.add(key);
                      }
                    }
                    _quizcontroller.answered_array[questions.id.toString()] = tempList;
                  },
                  title: Text(
                    option.title,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
              ),
              SizedBox(
                height: 10.h,
              )
            ],
          )
      ],
    );
  }

  Widget give_padding(Widget childWidget) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: childWidget,
    );
  }

  Future<bool> _promptconfirmation() async {
    return await notify.showDialog("End Quiz".tr, "Are you sure, do you want to end this quiz?".tr,
        confirm_text: "Yes".tr, cancel_text: "cancel".tr, on_confirm: () {
      Get.back();
      _quizcontroller.finishQuiz(widget.Questions);
    });
  }
}

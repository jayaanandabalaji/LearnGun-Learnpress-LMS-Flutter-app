import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/HtmlWidget.dart';
import '../../utils/constants.dart';

class QuizReview extends StatefulWidget {
  final questions;
  final answered;
  const QuizReview(this.questions, this.answered);
  @override
  _QuizReviewState createState() => _QuizReviewState();
}

class _QuizReviewState extends State<QuizReview> {
  @override
  Widget build(BuildContext context) {
    List answeredList = widget.answered.keys.toList();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("Review answers".tr),
      ),
      body: Container(
        color: Constants.primary_color,
        child: ListView(
          padding: EdgeInsets.all(15.h),
          children: [
            for (String answerID in answeredList) build_question(int.parse(answerID)),
          ],
        ),
      ),
    );
  }

  Widget build_question(int answerID) {
    return Padding(
        padding: EdgeInsets.fromLTRB(0, 10.h, 0, 10.h),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.r),
            color: Colors.white,
          ),
          padding: EdgeInsets.all(15.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                get_title(answerID),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              html_content.html_widget(get_content(answerID)),
              if (get_type(answerID) == "single_choice" || get_type(answerID) == "true_or_false")
                Column(
                  children: [
                    for (Map option in widget.answered[answerID.toString()]["options"])
                      Build_radio(option, widget.answered[answerID.toString()]["answered"]),
                  ],
                ),
              if (get_type(answerID) == "multi_choice")
                Column(
                  children: [
                    for (Map option in widget.answered[answerID.toString()]["options"])
                      build_check(option, widget.answered[answerID.toString()]["answered"]),
                  ],
                ),
              if (get_type(answerID) == "fill_in_blanks") build_fillup(widget.answered[answerID.toString()])
            ],
          ),
        ));
  }

  Widget build_fillup(Map answered) {
    List fillup = answered["options"][0]["title"].split(RegExp('[}{]+'));
    return Text.rich(TextSpan(
        style: TextStyle(
          fontSize: 20.sp,
          height: 1.2.h,
        ),
        children: [
          for (String text in fillup)
            TextSpan(children: [
              if (text.contains("FIB_"))
                TextSpan(children: [
                  if (!answered["options"][0]["answers"][text.replaceAll("FIB_", "")]["is_correct"])
                    TextSpan(children: [
                      TextSpan(
                        text: answered["options"][0]["answers"][text.replaceAll("FIB_", "")]["answer"],
                        style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.red),
                      ),
                      const TextSpan(text: " ")
                    ]),
                  TextSpan(
                      text: answered["options"][0]["answers"][text.replaceAll("FIB_", "")]["correct"] + " ",
                      style: const TextStyle(color: Colors.green))
                ]),
              if (!text.contains("FIB_")) TextSpan(text: text)
            ]),
        ]));
  }

  Widget build_check(Map option, var Answered) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 5.h, 0, 5.h),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.r),
          border: Border.all(
              color: (option["is_true"] == "yes")
                  ? Colors.green
                  : (Answered.contains(option["value"]))
                      ? Colors.red
                      : Colors.white,
              width: 2.w)),
      child: CheckboxListTile(
        controlAffinity: ListTileControlAffinity.trailing,
        activeColor: Constants.primary_color,
        value: Answered.contains(option["value"]),
        onChanged: (value) {},
        title: Text(
          option["title"],
          style: TextStyle(fontSize: 14.sp),
        ),
      ),
    );
  }

  Widget Build_radio(Map option, var Answered) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 5.h, 0, 5.h),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.r),
          border: Border.all(
              color: (option["is_true"] == "yes")
                  ? Colors.green
                  : (Answered == option["value"])
                      ? Colors.red
                      : Colors.white,
              width: 2.w)),
      child: RadioListTile<String>(
        controlAffinity: ListTileControlAffinity.trailing,
        activeColor: Constants.primary_color,
        value: option["title"],
        groupValue: (Answered == option["value"]) ? option["title"] : null,
        onChanged: (value) {},
        title: Text(
          option["title"],
          style: TextStyle(fontSize: 14.sp),
        ),
      ),
    );
  }

  get_title(answerID) {
    for (var question in widget.questions) {
      if (question.id == answerID) {
        return question.title;
      }
    }
  }

  get_content(answerID) {
    for (var question in widget.questions) {
      if (question.id == answerID) {
        return question.content;
      }
    }
  }

  get_type(answerID) {
    for (var question in widget.questions) {
      if (question.id == answerID) {
        return question.type;
      }
    }
  }
}

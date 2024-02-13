import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../Models/FinishQuiz.dart';
import 'QuizResultsWidget.dart';

class QuizResultScreen extends StatefulWidget {
  final FinishQuiz response;
  final Questions;
  const QuizResultScreen(this.response, this.Questions);
  @override
  _QuizResultScreenState createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Quiz Result".tr),
        ),
        body: ListView(
          children: [
            Padding(
              padding: EdgeInsets.all(20.h),
              child: QuizResultsWidget(widget.response, widget.Questions),
            ),
          ],
        ));
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../screens/takeCourse.dart';
import '../../screens/curriculumPreview.dart';
import '../../services/CoursesAPI.dart';

class CourseLoading extends StatefulWidget {
  final courseid;
  final isStartCourseScreen;
  const CourseLoading(this.courseid, {this.isStartCourseScreen = false});
  @override
  _CourseLoadingState createState() => _CourseLoadingState();
}

class _CourseLoadingState extends State<CourseLoading> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: CoursesApi().GetCourse(widget.courseid),
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          Future.microtask(() {
            if (widget.isStartCourseScreen) {
              Get.off(TakeCourseScreen(
                Course: snapshot.data as dynamic,
              ));
            } else {
              Get.off(CurriculumScreen(
                Course: snapshot.data,
              ));
            }
          });
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

import 'package:get/get.dart';

import '../services/CoursesAPI.dart';
import '../widgets/Notify/notify.dart';
import '../Models/Courses.dart';
import 'HomeController.dart';

class MyCoursesController extends GetxController {
  var enrolledCoursesList = [].obs;
  var enrolledCoursescount = 0.obs;
  var completedCoursesList = [].obs;
  var completedCoursescount = 0.obs;
  final HomeController _homeController = Get.put(HomeController());
  localCompltecourse(Courses course) {
    for (Courses singleCourse in _homeController.courseslist) {
      if (singleCourse.id == course.id) {
        singleCourse.course_data.status = "enrolled";
        singleCourse.course_data.graduation = "in-progress";
      }
    }
    enrolledCoursesList.refresh();
  }

  addtoEnrolledCourses(Courses course) {
    if (!isInEnrolledCourses(course)) {
      enrolledCoursesList.add(course);
      enrolledCoursescount.value++;
    }
  }

  isInEnrolledCourses(Courses course) {
    for (Courses singleCourse in enrolledCoursesList) {
      if (singleCourse.id == course.id) {
        return true;
      }
    }
    return false;
  }

  retakeCourse(Courses course) async {
    notify.showLoadingDialog("Trying to retake".tr);
    var response = await CoursesApi.EnrollCourse(course.id);
    Get.back();
    if (response["status"] == "error") {
      notify.show_snackbar("Enroll failed".tr, response["message"]);
    } else {
      notify.show_snackbar("Enrolled Successfully", response["message"]);
      refreshMyCourses();
    }
  }

  refreshMyCourses() async {
    var mycourses = await CoursesApi.MyCourses();
    var enrolled = filterCourses("enrolled", mycourses);
    enrolledCoursesList.value = enrolled;
    enrolledCoursescount.value = enrolled.length;
    var completed = filterCourses("finished", mycourses);
    completedCoursesList.value = completed;
    completedCoursescount.value = completed.length;
  }

  filterCourses(String status, var courses) {
    List<Courses> tempReturnList = [];
    for (Courses course in courses) {
      if (course.course_data.status == status) {
        tempReturnList.add(course);
      }
    }
    return tempReturnList;
  }
}

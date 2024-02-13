import 'package:LearnGun/services/CoursesAPI.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/SharedPrefs.dart';
import '../screens/register.dart';
import '../utils/constants.dart';
import 'AuthController.dart';
import 'CartController.dart';
import 'HomeController.dart';
import 'MyCoursesController.dart';
import 'Previewcontroller.dart';
import 'QuizController.dart';
import 'SearchController.dart';
import 'TakeCourseController.dart';

class ProfileController extends GetxController {
  String currentLocale = Constants.defaultLanguage;

  final HomeController _homeController = Get.put(HomeController());
  logout() async {
    var primarycolor = await prefs.getString("primary_color");
    var secondaryColor = await prefs.getString("secondary_color");
    await prefs.Removeall();
    if (primarycolor != null) {
      prefs.setString("primary_color", primarycolor);
    }
    if (secondaryColor != null) {
      prefs.setString("secondary_color", secondaryColor);
    }
    Get.delete<AuthController>();
    Get.delete<cartController>();
    Get.delete<MyCoursesController>();
    Get.delete<previewController>();
    Get.delete<Quizcontroller>();
    Get.delete<SearchController>();
    Get.delete<TakeCourseController>();
    _homeController.isLoggedIn.value = false;
    Get.off(() => LoginRegisterScreen());
    _homeController.courseslist.value = await CoursesApi().GetCourses({});
  }

  changeLocale(String locale) async {
    Get.updateLocale(Locale(locale));
    await prefs.setString("locale", locale);
  }
}

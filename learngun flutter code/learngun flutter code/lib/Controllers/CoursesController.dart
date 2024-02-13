import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/SharedPrefs.dart';
import '../Controllers/HomeController.dart';
import '../Models/Courses.dart';
import '../services/CoursesAPI.dart';

class coursesController extends GetxController {
  final HomeController _homeController = Get.put(HomeController());
  var wishlistedCourses = [].obs;
  var wishlistedCoursesCount = 0.obs;
  changeWishlist(var course) {
    if (isInWishlist(course)) {
      removeFromWishlist(course);
      ScaffoldMessenger.of(Get.context!).showSnackBar(const SnackBar(
        content: Text(
          "Course removed from wishlist",
        ),
        duration: Duration(seconds: 2),
      ));
    } else {
      wishlistedCourses.insert(0, course);
      wishlistedCoursesCount.value++;
      ScaffoldMessenger.of(Get.context!)
          .showSnackBar(SnackBar(content: Text("Course added to wishlist".tr), duration: const Duration(seconds: 2)));
    }
    storeWishlist();
  }

  removeFromWishlist(var course) {
    for (int i = 0; i < wishlistedCourses.length; i++) {
      if (wishlistedCourses[i].id == course.id) {
        wishlistedCourses.removeAt(i);
        wishlistedCoursesCount.value--;
        break;
      }
    }
  }

  getWishlist() async {
    var tempWishlistList = [];
    List<String> getWishlist = await prefs.getStringList("wishlists") ?? [];
    for (String wishlistItem in getWishlist) {
      tempWishlistList.add(Courses.fromJson(jsonDecode(wishlistItem)));
    }
    wishlistedCourses.value = tempWishlistList;
    wishlistedCoursesCount.value = wishlistedCourses.length;
  }

  storeWishlist() async {
    List<String> tempWishlistList = [];
    for (var course in wishlistedCourses) {
      tempWishlistList.add(jsonEncode(course));
    }
    prefs.setStringList("wishlists", tempWishlistList);
  }

  isInWishlist<bool>(var course) {
    for (var singleCourse in wishlistedCourses) {
      if (singleCourse.id == course.id) {
        return true;
      }
    }
    return false;
  }

  removeAllWishlist() {
    wishlistedCourses.value = [];
    wishlistedCoursesCount.value = 0;
    storeWishlist();
  }

  get_origin_price(var courses) {
    num tempOriginPrice = 0;
    for (Courses course in courses) {
      tempOriginPrice += course.origin_price;
    }
    return tempOriginPrice;
  }

  get_sale_price(var courses) {
    num tempSalePrice = 0;
    for (Courses course in courses) {
      tempSalePrice += course.price;
    }
    return tempSalePrice;
  }

  get_lessons_count(Courses course) {
    int tempLessonsCount = 0;
    for (var sections in course.sections) {
      for (var items in sections.items) {
        if (items.type == "lp_lesson") {
          tempLessonsCount++;
        }
      }
    }
    return tempLessonsCount;
  }

  get_Quiz_count(Courses course) {
    int tempQuizCount = 0;
    for (var sections in course.sections) {
      for (var items in sections.items) {
        if (items.type == "lp_quiz") {
          tempQuizCount++;
        }
      }
    }
    return tempQuizCount;
  }

  get_related_courses(Courses course, {int count = 0}) async {
    List tempReturnList = [];
    if (course.categories.isEmpty && course.tags.isEmpty) {
      tempReturnList = (return_new_courseslist(_homeController.courseslist));
    } else {
      if (course.categories.isNotEmpty) {
        tempReturnList = (await CoursesApi().GetCourses({"cats": course.categories[0].id}));
      } else if (course.tags.isNotEmpty) {
        tempReturnList = (await CoursesApi().GetCourses({"tag": course.tags[0].id}));
      }
      if (count != 0) {
        tempReturnList = (tempReturnList + return_new_courseslist(_homeController.courseslist));
      }
      final jsonList = tempReturnList.map((item) => jsonEncode(item)).toList();
      final uniqueJsonList = jsonList.toSet().toList();
      final result = uniqueJsonList.map((item) => jsonDecode(item)).toList();
      tempReturnList = result.map((value) => Courses.fromJson(value)).toList();
    }
    for (Courses singleCourse in tempReturnList) {
      if (course.id == singleCourse.id) {
        tempReturnList.remove(singleCourse);
        break;
      }
    }
    tempReturnList = ((tempReturnList).sublist(0, (tempReturnList.length > 3) ? 3 : tempReturnList.length));
    return tempReturnList.toList();
  }

  return_new_courseslist(var courses) {
    var coursesList = jsonDecode(jsonEncode(courses));
    return coursesList.map((value) => Courses.fromJson(value)).toList();
  }

  return_new_categorieslist(var categories) {
    var categoriesList = jsonDecode(jsonEncode(categories));
    return categoriesList;
  }
}

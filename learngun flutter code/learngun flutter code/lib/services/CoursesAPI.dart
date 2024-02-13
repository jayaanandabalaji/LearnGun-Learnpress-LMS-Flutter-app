
import 'package:get/get.dart';

import '../../Models/Courses.dart';
import '../Controllers/HomeController.dart';
import 'BaseAPI.dart';
import '../../Models/Reviews.dart';

class CoursesApi {
  final HomeController _homeController = Get.put(HomeController());

  GetCourses(var sortarrs) async {
    var response = await baseAPI().getAsync(
        "courses" + getQueryParams(sortarrs),
        data: (_homeController.isLoggedIn.value)
            ? {"requirestoken": "true"}
            : {});
    try {
      response.map((value) => Courses.fromJson(value)).toList();
    } catch (error) {
      
    }
    return response.map((value) => Courses.fromJson(value)).toList();
  }

  static getCourseReviews(int CourseId) async {
    var response = await baseAPI().postAsync(
        "learnpressapp/v1/get-review", {"course_id": CourseId},
        customUrl: true);
    return response.map((value) => reviews.fromJson(value)).toList();
  }

  static addCourseReview(
      int CourseId, int rate, String title, String content) async {
    var response = await baseAPI().postAsync(
        "learnpressapp/v1/add-review",
        {
          "requirestoken": "true",
          "course_id": CourseId,
          "rate": rate,
          "title": title,
          "content": content
        },
        customUrl: true);
    return response;
  }

  GetCourse(String courseid) async {
    var response = await baseAPI().getAsync("courses/" + courseid,
        data: (_homeController.isLoggedIn.value)
            ? {"requirestoken": "true"}
            : {});
    return Courses.fromJson(response);
  }

  static MyCourses() async {
    var response = await baseAPI()
        .getAsync("courses?learned=true", data: {"requirestoken": "true"});
    return response.map((value) => Courses.fromJson(value)).toList();
  }

  static EnrollCourse(var CourseID) async {
    var response = await baseAPI().postAsync(
        "courses/enroll?id=" + CourseID.toString(), {"requirestoken": "true"});
    return response;
  }

  static GetCourseTags() async {
    var response = await baseAPI()
        .getAsync("wp/v2/course_tag?per_page=30&page=1", customUrl: true);
    return response;
  }

  GetCourseCategories() async {
    var response =
        await baseAPI().getAsync("course_category?per_page=30&page=1");
    return response;
  }

  static completeCourse(int courseId) async {
    var response = await baseAPI()
        .postAsync("courses/finish", {"requirestoken": "true", "id": courseId});
    return response;
  }

  getQueryParams(var sortarrs) {
    var Queryparams = "";
    var appendstring = "?";
    if (sortarrs["search"] != null) {
      Queryparams += appendstring + "search=" + sortarrs["search"];
      appendstring = "&";
    }

    if (sortarrs["slug"] != null) {
      Queryparams += appendstring + "slug=" + sortarrs["slug"];
      appendstring = "&";
    }
    if (sortarrs["include"] != null) {
      Queryparams += appendstring + "include=" + sortarrs["include"];
      appendstring = "&";
    }
    if (sortarrs["cats"] != null) {
      Queryparams += appendstring + "category=" + sortarrs["cats"].toString();
      appendstring = "&";
    }
    if (sortarrs["orderby"] != null) {
      Queryparams += appendstring + "orderby=" + sortarrs["orderby"];
      appendstring = "&";
    }
    if (sortarrs["order"] != null) {
      Queryparams += appendstring + "order=" + sortarrs["order"];
      appendstring = "&";
    }
    if (sortarrs["page"] != null) {
      Queryparams += appendstring + "page=" + sortarrs["page"].toString();
      appendstring = "&";
    }
    if (sortarrs["author"] != null) {
      Queryparams += appendstring + "author=" + sortarrs["author"].toString();
      appendstring = "&";
    }
    if (sortarrs["tag"] != null) {
      Queryparams += appendstring + "tag=" + sortarrs["tag"].toString();
      appendstring = "&";
    }

    return Queryparams;
  }
}

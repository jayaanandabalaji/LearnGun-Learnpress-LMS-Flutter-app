import 'dart:convert';
import 'package:get/get.dart';

import '../Models/Courses.dart';
import '../Controllers/HomeController.dart';
import '../screens/categories.dart';
import '../services/CoursesAPI.dart';
import '../services/SharedPrefs.dart';

class SearchController extends GetxController {
  var recentSearches = [].obs;
  var recentSearchescount = 0.obs;
  var sort_arrs = {}.obs;
  var page = 1.obs;
  var search_courses = [].obs;
  var is_search_loading = true.obs;
  var category_name = "".obs;
  var search_tag = "".obs;
  final HomeController _homeController = Get.put(HomeController());

  getRecentSearches() async {
    var tempSearchesList = [];
    List<dynamic> getSearches = await prefs.getStringList("searches") ?? [];
    for (String search in getSearches) {
      tempSearchesList.insert(0, Courses.fromJson(jsonDecode(search)));
    }
    recentSearches.value = tempSearchesList;
    recentSearchescount.value = tempSearchesList.length;
  }

  storeRecentSearches() async {
    List<String> tempSearchesList = [];
    for (Courses course in recentSearches.toList(growable: false)) {
      tempSearchesList.add(jsonEncode(course));
    }
    prefs.setStringList("searches", tempSearchesList);
  }

  AddtorecentSearch(Courses course) {
    if (!IsInRecentSearches(course)) {
      recentSearches.toList(growable: false).add(course);
      storeRecentSearches();
    }
    recentSearchescount++;
  }

  IsInRecentSearches(Courses course) {
    for (Courses singleCourse in recentSearches) {
      if (course.id == singleCourse.id) {
        return true;
      }
    }
    return false;
  }

  removeAllRecentSearches() {
    recentSearches.value = [];
    storeRecentSearches();
    recentSearchescount.value = 0;
  }

  fetchSearchCourses() async {
    var response = await CoursesApi().GetCourses(sort_arrs);
    return response;
  }

  get_category_from_name(String name) {
    if (name == "All Categories".tr) {
      return {"name": "All Categories".tr, "id": 0};
    } else {
      for (var category in _homeController.course_category_list.toList(growable: false)) {
        if (category["name"] == name) {
          return category;
        }
      }
    }
  }

  gotoCategory(var category, {bool openSearch = false}) async {
    page.value = 1;
    sort_arrs["page"] = 1;

    if (category["id"] != 0) {
      sort_arrs.value = {"cats": category["id"]};
    } else {
      sort_arrs.value = {};
    }
    search_tag.value = "";
    category_name.value = category["name"];
    if (openSearch) {
      Get.to(const CourseCategories(
        openSearch: true,
      ));
    } else {
      Get.to(const CourseCategories());
    }
    is_search_loading.value = true;
    var response = await fetchSearchCourses();
    search_courses.value = response;
    is_search_loading.value = false;
  }

  goToTag(var tag) async {
    page.value = 1;
    sort_arrs["page"] = 1;
    sort_arrs.value = {"tag": tag["id"]};
    category_name.value = "All Categories".tr;
    search_tag.value = "Tag : " + tag["name"];
    Get.to(const CourseCategories());
    is_search_loading.value = true;
    var response = await fetchSearchCourses();
    search_courses.value = response;
    is_search_loading.value = false;
  }

  search(String tag) async {
    page.value = 1;
    sort_arrs["page"] = 1;
    search_tag.value = tag;
    sort_arrs["search"] = tag;
    is_search_loading.value = true;
    var response = await fetchSearchCourses();
    search_courses.value = response;
    is_search_loading.value = false;
  }

  nextPage() async {
    page.value++;
    sort_arrs["page"] = page.value;
    var response = await fetchSearchCourses();
    search_courses.value = search_courses.toList(growable: false) + response;
  }

  sort(String query) async {
    page.value = 1;
    sort_arrs["page"] = 1;

    if (query == "Ascending".tr) {
      sort_arrs["order"] = "asc";
      sort_arrs["orderby"] = "title";
    }
    if (query == "Descending".tr) {
      sort_arrs["order"] = "desc";
      sort_arrs["orderby"] = "title";
    }
    if (query == "Oldest".tr) {
      sort_arrs["order"] = "asc";
      sort_arrs["orderby"] = "date";
    }
    if (query == "Newest".tr) {
      sort_arrs["order"] = "desc";
      sort_arrs["orderby"] = "date";
    }
    is_search_loading.value = true;
    var response = await fetchSearchCourses();
    search_courses.value = response;
    is_search_loading.value = false;
  }
}

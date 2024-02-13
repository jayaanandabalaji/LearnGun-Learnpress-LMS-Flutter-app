import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:html_unescape/html_unescape.dart';

import '../../Controllers/SearchController.dart';
import '../../Controllers/HomeController.dart';
import '../../widgets/Button.dart';
import '../../services/CoursesAPI.dart';
import '../../widgets/grids/grid_4.dart';

var tagslist;

class SearchScreen extends StatefulWidget {
  @override
  _searchscreenstate createState() => _searchscreenstate();
}

class _searchscreenstate extends State<SearchScreen> {
  final HomeController _homeController = Get.put(HomeController());
  final SearchController _searchController = Get.put(SearchController());
  late Future _gettags;
  var unescape = HtmlUnescape();
  @override
  void initState() {
    super.initState();
    _gettags = CoursesApi.GetCourseTags();
  }

  @override
  Widget build(BuildContext Context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
              "Search".tr,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20.sp),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(40.0.h), // here the desired height
              child: Padding(
                padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 10.h),
                child: GestureDetector(
                  onTap: () {
                    _searchController.gotoCategory({"id": 0, "name": "All Categories".tr}, openSearch: true);
                  },
                  child: Card(
                      child: Padding(
                    padding: EdgeInsets.all(10.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Search Courses".tr, style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w500)),
                        const Icon(Icons.search)
                      ],
                    ),
                  )),
                ),
              ),
            )),
        body: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder(
                  future: _gettags,
                  builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.data != null) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          build_title("Search Tags".tr),
                          give_padding(Wrap(
                              spacing: 8,
                              children: List.generate(
                                snapshot.data!.length,
                                (index) {
                                  return theme_buttons.TagsButton(snapshot.data[index]["name"], onTap: () {
                                    _searchController.goToTag(snapshot.data[index]);
                                  });
                                },
                              )))
                        ],
                      );
                    }
                    return SizedBox(
                      height: 100.h,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                ),
                Obx(() {
                  if (_searchController.recentSearchescount.value > 0) {
                    return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              build_title("Recent Searches".tr),
                              Flexible(
                                child: GestureDetector(
                                  onTap: () {
                                    _searchController.removeAllRecentSearches();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(0, 0, 10.w, 0),
                                    child: Text(
                                      "Remove All".tr,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              height: 215.h,
                              child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  children:
                                      List.generate((_searchController.recentSearches as dynamic).length + 2, (index) {
                                    return Padding(
                                        padding: EdgeInsets.all(5.h),
                                        child: (index != 0 &&
                                                index != (_searchController.recentSearches as dynamic).length + 1)
                                            ? BuildGrid4((_searchController.recentSearches as dynamic)[index - 1])
                                            : SizedBox(
                                                width: 10.w,
                                              ));
                                  }))),
                        ]);
                  }
                  return Container();
                }),
                Obx(() {
                  if (_homeController.course_category_list.isNotEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        build_title("Browse Categories".tr),
                        SizedBox(
                          height: 10.h,
                        ),
                        for (var Category in _homeController.course_category_list) build_categories(Category)
                      ],
                    );
                  }
                  return Container();
                }),
                SizedBox(height: 15.h)
              ]),
        ));
  }

  Widget give_padding(Widget childWidget) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 0),
      child: childWidget,
    );
  }

  Widget build_title(String title) {
    return give_padding(Text(
      title,
      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
    ));
  }

  Widget build_categories(var category) {
    return InkWell(
      onTap: () {
        _searchController.gotoCategory(category);
      },
      child: Container(
          width: Get.width * 1.0,
          padding: EdgeInsets.all(10.h),
          margin: EdgeInsets.fromLTRB(10.w, 0, 10.w, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                unescape.convert(category["name"]),
                style: TextStyle(fontSize: 16.sp),
              ),
              const Icon(Icons.navigate_next)
            ],
          )),
    );
  }
}

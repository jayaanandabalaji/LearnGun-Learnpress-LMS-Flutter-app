import 'dart:async';
import 'package:get/get.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../Controllers/CoursesController.dart';
import '../../Controllers/HomeController.dart';
import '../../utils/constants.dart';
import '../../widgets/NoData.dart';
import '../../Controllers/SearchController.dart';
import '../../widgets/grids/grid3.dart';

class CourseCategories extends StatefulWidget {
  final openSearch;
  const CourseCategories({this.openSearch = false});
  @override
  _CourseCategoriesState createState() => _CourseCategoriesState();
}

class _CourseCategoriesState extends State<CourseCategories> {
  final SortList = ["Ascending".tr, "Descending".tr, "Oldest".tr, "Newest".tr];
  var dropdownSelected = "".obs;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (widget.openSearch) {
        floatingSearchBarController.open();
      }
    });
  }

  final SearchController _searchController = Get.put(SearchController());
  final HomeController _homeController = Get.put(HomeController());
  RefreshController refreshController = RefreshController(initialRefresh: false);
  FloatingSearchBarController floatingSearchBarController = FloatingSearchBarController();
  final coursesController _coursesController = Get.put(coursesController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        floatingSearchBarController.query = _searchController.search_tag.value;
        return FloatingSearchBar(
            actions: [
              FloatingSearchBarAction(
                showIfOpened: false,
                child: CircularButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    Get.bottomSheet(bottomSheet());
                  },
                ),
              ),
              FloatingSearchBarAction.searchToClear(
                showIfClosed: false,
              ),
            ],
            controller: (floatingSearchBarController),
            title: (_searchController.search_tag.value != "") ? Text(_searchController.search_tag.value) : null,
            hint: "Search".tr + "...",
            scrollPadding: EdgeInsets.only(top: 16.h, bottom: 56.h),
            builder: (BuildContext context, Animation<double> transition) {
              return Container();
            },
            onSubmitted: (String tag) {
              refreshController.resetNoData();
              floatingSearchBarController.close();
              floatingSearchBarController.query = tag;
              _searchController.search(tag);
            },
            body: (!_searchController.is_search_loading.value)
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 90.h,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(25, 0, 0, 0),
                        child: Dropdown(),
                      ),
                      if (_searchController.search_courses.isEmpty)
                        Expanded(
                            child: Center(
                          child: NoData.noData("no-courses", "No courses Available".tr, imageHeight: 100),
                        )),
                      if (_searchController.search_courses.isNotEmpty)
                        Expanded(
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                              child: StatefulBuilder(builder: (BuildContext _, setter) {
                                return SmartRefresher(
                                    enablePullDown: false,
                                    enablePullUp: true,
                                    footer: const ClassicFooter(noMoreIcon: Icon(Icons.error, color: Colors.grey)),
                                    onLoading: () async {
                                      if (_searchController.search_courses.length % 10 != 0) {
                                        refreshController.loadNoData();
                                      } else {
                                        await _searchController.nextPage();
                                        setter(() {});
                                        refreshController.loadComplete();
                                      }
                                    },
                                    header: const WaterDropHeader(),
                                    controller: refreshController,
                                    child: ListView(
                                        scrollDirection: Axis.vertical,
                                        children: List.generate(_searchController.search_courses.length, (index) {
                                          return BuildGrid3(_searchController.search_courses[index]);
                                        })));
                              })),
                        )
                    ],
                  )
                : const Center(child: CircularProgressIndicator()));
      }),
    );
  }

  Widget Dropdown() {
    List dropdownList = _coursesController.return_new_categorieslist(_homeController.course_category_list);
    dropdownList.insert(0, {"name": "All Categories".tr, "id": 0});
    return DropdownButtonHideUnderline(
        child: DropdownButton(
      value: _searchController.category_name.value,
      icon: const Icon(
        // Add this
        Icons.arrow_drop_down, // Add this
        color: Colors.black, // Add this
      ),
      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 17.sp),
      items: <String>[
        for (var index = 0; index < dropdownList.length; index++) dropdownList[index]["name"],
      ].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (selecteditem) {
        refreshController.resetNoData();
        dropdownSelected.value = "";
        _searchController.gotoCategory(_searchController.get_category_from_name(selecteditem as dynamic));
      },
    ));
  }

  Widget bottomSheet() {
    return Container(
      height: 270.h,
      width: Get.width,
      color: Colors.white,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          SizedBox(
            height: 15.h,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 0, 0, 0),
            child: Text("Sort By".tr, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
          ),
          Obx(() {
            return Column(
              children: [
                for (String sort in SortList)
                  RadioListTile(
                    activeColor: Constants.primary_color,
                    value: sort,
                    groupValue: (dropdownSelected.value != "") ? dropdownSelected.value : null,
                    onChanged: (selected) async {
                      refreshController.resetNoData();

                      _searchController.sort(selected as dynamic);
                      dropdownSelected.value = selected as dynamic;
                      Get.back();
                    },
                    title: Text(sort),
                  )
              ],
            );
          })
        ],
      ),
    );
  }
}

// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:LearnGun/screens/register.dart';
import 'package:LearnGun/screens/resources.dart';
import 'package:LearnGun/widgets/Notify/notify.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../screens/AuthorProfile.dart';
import '../../screens/Coursesloading.dart';
import '../../Models/Instructor.dart';
import '../../services/SharedPrefs.dart';
import '../../utils/constants.dart';
import '../../Controllers/CartController.dart';
import '../../Controllers/HomeController.dart';
import '../../services/CoursesAPI.dart';
import '../../services/ProfileAPI.dart';
import '../../widgets/Card.dart';
import '../../widgets/CoursesAppBarActions.dart';
import '../../widgets/grids/grid_2.dart';
import '../../Controllers/SearchController.dart';
import '../../Controllers/CoursesController.dart';
import 'curriculumPreview.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  var unescape = HtmlUnescape();
  final coursesController _coursesController = Get.put(coursesController());
  final HomeController _homeController = Get.put(HomeController());
  final cartController _cartController = Get.put(cartController());
  final SearchController _searchController = Get.put(SearchController());
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  late Future _getCourses;
  late Future _getCategories;
  late Future _getInstructors;
  final List<dynamic> _getFeaturedCoursesList = [];
  @override
  void initState() {
    initUniLinks();

    super.initState();
    _getCourses = CoursesApi().GetCourses({});
    _getCategories = CoursesApi().GetCourseCategories();
    _getInstructors = ProfileApi.get_instructors();

    for (var category in _homeController.featured_categories) {
      _getFeaturedCoursesList.add({
        'id': category['id'],
        'name': category['name'],
        'course': CoursesApi().GetCourses({'cats': category['id']})
      });
    }
    Future.delayed(Duration.zero, () {
      _cartController.getCart();
      _coursesController.getWishlist();
      _searchController.getRecentSearches();
    });
  }

  Future<void> initUniLinks() async {
     linkStream.listen((String? link) async {
      List<String> pathSeg = Uri.parse(link ?? "").pathSegments;
      String slug =
          (pathSeg.last == "") ? pathSeg[pathSeg.length - 2] : pathSeg.last;

      notify.showLoadingDialog("Loading course");
      var courses = await CoursesApi().GetCourses({"slug": slug});
      if (courses.length == 0) {
        Get.back();
        notify.showDialog("Error", "Course not found", on_confirm: () {
          Get.back();
        });
      } else {
        Get.back();
        Get.to(CurriculumScreen(Course: courses[0]));
      }
      // Parse the link and warn the user, if it is not correct
    }, onError: (err) {
      // Handle exception by warning the user their action did not succeed
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Center(
      child: FutureBuilder<dynamic>(
        future: _getCourses,
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            if (_homeController.courseslist.isEmpty) {
              _homeController.courseslist.value = snapshot.data;
            }
            return SmartRefresher(
                enablePullDown: true,
                enablePullUp: false,
                header: WaterDropHeader(),
                controller: _refreshController,
                onRefresh: () async {
                  _homeController.courseslist.value =
                      await CoursesApi().GetCourses({});
                  _refreshController.refreshCompleted();
                },
                child: SingleChildScrollView(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(25.r),
                              bottomRight: Radius.circular(25.r)),
                          color: Constants.primary_color,
                          image: DecorationImage(
                            image: AssetImage("assets/pattern.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        padding: EdgeInsets.all(20),
                        width: Get.width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Obx(() {
                                  if (_homeController.isLoggedIn.value) {
                                    return FutureBuilder(
                                        future: prefs.getString(
                                            'sensitive_user_meta_username'),
                                        builder: (context, shapshot) {
                                          if (shapshot.data != null) {
                                            return Text(
                                                "Hi".tr +
                                                    ", " +
                                                    (shapshot.data as dynamic)
                                                        .replaceAll(
                                                            "@gmail.com", "") +
                                                    "👋",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 22.sp,
                                                    fontWeight:
                                                        FontWeight.bold));
                                          }
                                          return Container();
                                        });
                                  }
                                  return GestureDetector(
                                    onTap: () {
                                      Get.to(LoginRegisterScreen());
                                    },
                                    child: Text("Login/Register",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.bold)),
                                  );
                                }),
                                CoursesAppBarActions()
                                    .cart_widget(widget_color: Colors.white),
                              ],
                            ),
                            Text("Let's start learning!".tr,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18)),
                            SizedBox(height: 25.h),
                            GestureDetector(
                                onTap: () {
                                  _searchController.gotoCategory(
                                      {"id": 0, "name": "All Categories".tr},
                                      openSearch: true);
                                },
                                child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.r),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(10.h),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.search),
                                          SizedBox(width: 15.w),
                                          Text("Search for anything".tr,
                                              style: TextStyle(
                                                  fontSize: 17.sp,
                                                  fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                                    )))
                          ],
                        ),
                      ),
                      if (_homeController.banner_list.isNotEmpty)
                        CarouselSlider(
                          options: CarouselOptions(
                            height: 200.h,
                            viewportFraction: 1,
                            enableInfiniteScroll:
                                (_homeController.banner_list.length < 2)
                                    ? false
                                    : true,
                          ),
                          items: _homeController.banner_list.map((i) {
                            return Builder(
                              builder: (BuildContext context) {
                                return GestureDetector(
                                    onTap: () async {
                                      if (i["type"] == "url") {
                                        await launchUrl(Uri.parse(i["value"]));
                                      }
                                      if (i["type"] == "Course") {
                                        Get.to(CourseLoading(i["value"]));
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                          child: Stack(children: <Widget>[
                                            (i["image"] != "")
                                                ? ExtendedImage.network(
                                                    i["image"],
                                                    width: Get.width * 1,
                                                    height: 200.h,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Container(),
                                            Padding(
                                              padding: EdgeInsets.all(20.h),
                                              child: Align(
                                                  alignment:
                                                      Alignment.bottomLeft,
                                                  child: Text(
                                                    i["title"],
                                                    style: TextStyle(
                                                        fontSize: 20.sp,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )),
                                            )
                                          ])),
                                    ));
                              },
                            );
                          }).toList(),
                        ),
                      build_title("Recent Courses".tr + ":"),
                      SizedBox(
                          height: 310.h,
                          child: Obx(() {
                            return ListView(
                                physics: BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                children: List.generate(
                                    _homeController.courseslist.length + 2,
                                    (index) {
                                  return Padding(
                                      padding: EdgeInsets.all(5.h),
                                      child: (index != 0 &&
                                              index !=
                                                  _homeController
                                                          .courseslist.length +
                                                      1)
                                          ? BuildGrid2(_homeController
                                              .courseslist[index - 1])
                                          : SizedBox(
                                              width: 10.w,
                                            ));
                                }));
                          })),
                      FutureBuilder(
                        future: _getCategories,
                        builder: (context, snapshot) {
                          if (snapshot.data != null) {
                            if (_homeController.course_category_list.isEmpty) {
                              Future.delayed(Duration.zero, () {
                                _homeController.course_category_list.value =
                                    snapshot.data as dynamic;
                              });
                            }
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                build_title("Categories".tr + ":"),
                                Obx(() {
                                  return SizedBox(
                                      height: 150.h,
                                      child: ListView(
                                          physics: BouncingScrollPhysics(),
                                          scrollDirection: Axis.horizontal,
                                          shrinkWrap: true,
                                          children: List.generate(
                                              _homeController
                                                      .course_category_list
                                                      .length +
                                                  2, (index) {
                                            return (index != 0 &&
                                                    index !=
                                                        _homeController
                                                                .course_category_list
                                                                .length +
                                                            1)
                                                ? build_category(_homeController
                                                        .course_category_list[
                                                    index - 1])
                                                : SizedBox(width: 20.w);
                                          })));
                                })
                              ],
                            );
                          }
                          return SizedBox(
                              height: 250.h,
                              child: const Center(
                                  child: CircularProgressIndicator()));
                        },
                      ),
                      FutureBuilder(
                        future: _getInstructors,
                        builder: (context, snapshot) {
                          if (snapshot.data != null) {
                            if (_homeController.instructors_list.isEmpty) {
                              _homeController.instructors_list.value =
                                  snapshot.data as dynamic;
                            }
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                build_title("Instructors".tr + ":"),
                                SizedBox(
                                    height: 200.h,
                                    child: ListView(
                                        physics: BouncingScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        children: List.generate(
                                            _homeController
                                                    .instructors_list.length +
                                                2, (index) {
                                          return (index != 0 &&
                                                  index !=
                                                      _homeController
                                                              .instructors_list
                                                              .length +
                                                          1)
                                              ? build_instructor(_homeController
                                                  .instructors_list[index - 1])
                                              : SizedBox(width: 20.w);
                                        }))),
                              ],
                            );
                          }
                          return SizedBox(
                              height: 250.h,
                              child: const Center(
                                  child: CircularProgressIndicator()));
                        },
                      ),
                      if (Constants.resourcesSection.length > 0)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            build_title("Resources".tr),
                            SizedBox(
                                height: 220.h,
                                child: ListView(
                                    padding: EdgeInsets.only(
                                        left: 20.w, right: 20.w),
                                    physics: BouncingScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    children: [
                                      if (Constants.resourcesSection
                                          .contains("blogs"))
                                        resourceGrid("blogs"),
                                      if (Constants.resourcesSection
                                          .contains("webinar"))
                                        resourceGrid("webinar",
                                            initialIndex: 1),
                                      if (Constants.resourcesSection
                                          .contains("others"))
                                        resourceGrid("others", initialIndex: 2)
                                    ])),
                            SizedBox(height: 20.h),
                            Center(
                                child: FlatButton(
                              height: Get.height * 0.06,
                              minWidth: Get.width - 70.w,
                              onPressed: () {
                                Get.to(resourcesScreen());
                              },
                              child: Text('View all resources'.tr,
                                  style: TextStyle(fontSize: 18.sp)),
                              textColor: Constants.primary_color,
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: Constants.primary_color,
                                      width: 1,
                                      style: BorderStyle.solid),
                                  borderRadius: BorderRadius.circular(5.r)),
                            ))
                          ],
                        ),
                      for (var categoryCourse in _getFeaturedCoursesList)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            give_padding(Row(
                              children: [
                                Text(
                                  "Top courses in".tr + " ",
                                  style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  categoryCourse["name"],
                                  style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Constants.primary_color),
                                ),
                              ],
                            )),
                            SizedBox(
                                height: 310.h,
                                child: FutureBuilder(
                                  future: categoryCourse["course"],
                                  builder: (context, snapshot1) {
                                    if (snapshot1.data != null) {
                                      return ListView(
                                          physics: BouncingScrollPhysics(),
                                          scrollDirection: Axis.horizontal,
                                          shrinkWrap: true,
                                          children: List.generate(
                                              (snapshot1.data as dynamic)
                                                      .length +
                                                  2, (index) {
                                            return Padding(
                                                padding: EdgeInsets.all(5.h),
                                                child: (index != 0 &&
                                                        index !=
                                                            (snapshot1.data
                                                                        as dynamic)
                                                                    .length +
                                                                1)
                                                    ? BuildGrid2((snapshot1.data
                                                        as dynamic)[index - 1])
                                                    : SizedBox(
                                                        width: 10.w,
                                                      ));
                                          }));
                                    }
                                    return SizedBox(
                                        height: 250.h,
                                        child: const Center(
                                            child:
                                                CircularProgressIndicator()));
                                  },
                                ))
                          ],
                        ),
                      SizedBox(height: 20.h),
                    ])));
          }

          return const CircularProgressIndicator();
        },
      ),
    )));
  }

  Widget give_padding(Widget childWidget) {
    return Padding(
      padding: EdgeInsets.fromLTRB(30.w, 10.h, 10.w, 10.h),
      child: childWidget,
    );
  }

  Widget build_title(String title) {
    return give_padding(Text(
      title,
      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
    ));
  }

  Widget build_category(var category) {
    return GestureDetector(
        onTap: () {
          _searchController.gotoCategory(category);
        },
        child: SizedBox(
            width: (ScreenUtil().orientation == Orientation.portrait)
                ? 150.w
                : 80.w,
            child: Card(
                color: (category["color"] != "" && category["color"] != null)
                    ? HexColor(category["color"])
                    : Constants.primary_color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Padding(
                    padding: EdgeInsets.all(5.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        (category["image"] != false)
                            ? ExtendedImage.network(category["image"][0],
                                height: 80.h)
                            : Container(),
                        (category["image"] != false)
                            ? SizedBox(height: 5.h)
                            : Container(),
                        Text(
                          unescape.convert(category["name"]),
                          style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                        )
                      ],
                    )))));
  }

  Widget build_instructor(Instructor Instructor) {
    return GestureDetector(
        onTap: () {
          Get.to(AuthorProfile(Instructor));
        },
        child: card.shadow_card(SizedBox(
            width: (ScreenUtil().orientation == Orientation.portrait)
                ? 150.w
                : 85.w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                (Instructor.avatar_url != "")
                    ? ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(50.r)),
                        child: ExtendedImage.network(Instructor.avatar_url,
                            height: 80.h))
                    : ExtendedImage.asset("assets/user.png", height: 80.h),
                SizedBox(height: 10.h),
                Text(Instructor.name.replaceAll("@gmail.com", ""),
                    style: TextStyle(
                        fontSize: 20.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.people,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 5.w,
                        ),
                        Text(Instructor.instructor_data.students.toString(),
                            style:
                                TextStyle(color: Colors.grey, fontSize: 20.sp)),
                      ],
                    ),
                    SizedBox(width: 25.w),
                    Row(
                      children: [
                        const Icon(
                          Icons.menu_book,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 5.w,
                        ),
                        Text(Instructor.instructor_data.courses.toString(),
                            style:
                                TextStyle(color: Colors.grey, fontSize: 20.sp)),
                      ],
                    ),
                  ],
                )
              ],
            ))));
  }
}

Map resourceDetails = {
  "blogs": {
    "color": [Color(0xff1973D1), Color(0xff135CC5)],
    "name": "Articles".tr,
    "description": "for comprehensive learning experience".tr
  },
  "webinar": {
    "color": [Color(0xffEA4C46), Color(0xffDC1C13)],
    "name": "Webinars".tr,
    "description": "organized by top industry experts".tr
  },
  "others": {
    "color": [Color(0xff2EB62C), Color(0xff57C84D)],
    "name": "Other resources".tr,
    "description": "pdf documents, images, Zip or any downloadable files".tr
  }
};

Widget resourceGrid(String resource, {int initialIndex = 0}) {
  return InkWell(
    onTap: () {
      Get.to(resourcesScreen(
        initalIndex: initialIndex,
      ));
    },
    child: Container(
      margin: EdgeInsets.only(right: 20),
      width: Get.width * 0.75,
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: resourceDetails[resource]["color"]),
          borderRadius: BorderRadius.circular(20.r)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
              child: Container(
                  width: Get.width * 0.75,
                  child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.r),
                          topRight: Radius.circular(20.r),
                          bottomLeft: Radius.elliptical(Get.width * 0.35, 75),
                          bottomRight:
                              Radius.elliptical(Get.width * 0.65, 150)),
                      child: Image.asset("assets/${resource}.jpg",
                          fit: BoxFit.cover)))),
          Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(resourceDetails[resource]["name"],
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 23.sp)),
                  Text(resourceDetails[resource]["description"],
                      style: TextStyle(color: Colors.white))
                ],
              ))
        ],
      ),
    ),
  );
}

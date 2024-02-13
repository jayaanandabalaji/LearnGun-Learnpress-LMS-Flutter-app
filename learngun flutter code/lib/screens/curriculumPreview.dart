import 'package:LearnGun/screens/memberships.dart';
import 'package:LearnGun/screens/register.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../widgets/HtmlWidget.dart';
import '../../widgets/Notify/notify.dart';
import '../../Controllers/MyCoursesController.dart';
import '../../Controllers/HomeController.dart';
import '../../widgets/custom_expansion_tile.dart';
import '../../Controllers/CoursesController.dart';
import '../../widgets/Card.dart';
import '../../utils/MeasureSize.dart';
import '../../Controllers/CartController.dart';
import '../../Models/Courses.dart';
import '../../utils/constants.dart';
import '../../widgets/Button.dart';
import '../../services/CoursesAPI.dart';
import '../../widgets/CoursesAppBarActions.dart';
import '../../widgets/grids/grid3.dart';
import '../Controllers/TakeCourseController.dart';
import 'CartScreen.dart';
import '../../Controllers/SearchController.dart';
import '../../widgets/preview.dart';
import '../../Controllers/Previewcontroller.dart';
import '../../Models/Reviews.dart';

class CurriculumScreen extends StatefulWidget {
  final dynamic Course;
  static const routeName = '/curriculum';
  const CurriculumScreen({required this.Course});
  @override
  _CurriculumScreenState createState() => _CurriculumScreenState();
}

class _CurriculumScreenState extends State<CurriculumScreen> {
  final HomeController _homeController = Get.put(HomeController());
  final MyCoursesController _myCoursesController =
      Get.put(MyCoursesController());
  final cartController _cartController = Get.put(cartController());
  final coursesController _coursesController = Get.put(coursesController());
  final TakeCourseController _takeCourseController =
      Get.put(TakeCourseController());
  final previewController _previewController = Get.put(previewController());
  final SearchController _searchController = Get.put(SearchController());
  var IsShowMore = true.obs;
  var Isoverflow = false.obs;
  static int count = 0;
  var _getReviews;
  @override
  void initState() {
    super.initState();
    if (widget.Course.rating != false) {
      _getReviews = CoursesApi.getCourseReviews(widget.Course.id);
    }
    Future.delayed(Duration.zero, () {
      _searchController.AddtorecentSearch(widget.Course);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          count = 0;
          return true;
        },
        child: Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                  icon: Icon(Icons.favorite,
                      color: (_coursesController.isInWishlist(widget.Course)
                          ? Colors.red
                          : Colors.white)),
                  onPressed: () {
                    _coursesController.changeWishlist(widget.Course);
                    setState(() {});
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () {
                    Share.share(widget.Course.permalink);
                  },
                ),
                SizedBox(width: 10.w),
                CoursesAppBarActions().cart_widget(widget_color: Colors.white)
              ],
            ),
            body: OrientationBuilder(builder: (context, orientation) {
              return Column(
                children: [
                  Expanded(
                      flex: (ScreenUtil().orientation == Orientation.portrait)
                          ? 9
                          : 8,
                      child: ListView(children: [
                        Hero(
                          tag: "image${widget.Course.id}",
                          child: ExtendedImage.network(
                            widget.Course.image,
                            height: 200.h,
                            width: Get.width * 1,
                            cache: true,
                            fit: BoxFit.cover,
                          ),
                        ),
                        give_paddings(Row(
                          children: [
                            (widget.Course.instructor.avatar != "")
                                ? ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(40.r)),
                                    child: ExtendedImage.network(
                                      widget.Course.instructor.avatar,
                                      height: 40.h,
                                    ))
                                : ExtendedImage.asset(
                                    "assets/user.png",
                                    height: 30.h,
                                  ),
                            SizedBox(width: 7.w),
                            Text(widget.Course.instructor.name,
                                style: TextStyle(fontSize: 16.sp))
                          ],
                        )),
                        give_paddings(Text(widget.Course.name,
                            style: TextStyle(
                                fontSize: 25.sp, fontWeight: FontWeight.bold))),
                        if (widget.Course.rating != false)
                          give_paddings(buildRating(widget.Course.rating)),
                        buildTitle("Description".tr),
                        MeasureSize(onChange: (size) {
                          if (size.height > 250.h) {
                            if (IsShowMore.value) {
                              Isoverflow.value = true;
                            }
                          }
                        }, child: Container(child: Obx(() {
                          if (IsShowMore.value && !Isoverflow.value) {
                            return give_paddings(html_content
                                .html_widget(widget.Course.content));
                          }
                          if (IsShowMore.value) {
                            return Container(
                              constraints: BoxConstraints(
                                maxHeight: 250.h,
                              ),
                              child: ClipRect(
                                clipBehavior: Clip.antiAlias,
                                child: give_paddings(html_content
                                    .html_widget(widget.Course.content)),
                              ),
                            );
                          } else {
                            return give_paddings(html_content
                                .html_widget(widget.Course.content));
                          }
                        }))),
                        GestureDetector(
                          onTap: () {
                            IsShowMore.value = !IsShowMore.value;
                          },
                          child: Center(
                              child: Obx(() => (Isoverflow.value)
                                  ? Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(0, 6.h, 0, 0),
                                      child: Text(
                                        (IsShowMore.value)
                                            ? "Show More".tr
                                            : "Show Less".tr,
                                        style: TextStyle(
                                            color: Constants.primary_color,
                                            fontSize: 15.sp),
                                      ))
                                  : Container())),
                        ),
                        if (widget.Course.membership != "" &&
                            widget.Course.price != 0 &&
                            widget.Course.course_data.status != "enrolled" &&
                            widget.Course.course_data.graduation !=
                                "in-progress")
                          InkWell(
                            onTap: () {
                              showMembershipDialog(
                                  context, widget.Course.membership);
                            },
                            child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 5),
                                child: Ink(
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                      Image.asset("assets/membership.png",
                                          height: 30),
                                      SizedBox(width: 10),
                                      Text(
                                        "Available in membership",
                                        style: TextStyle(
                                            color: Constants.primary_color,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(width: 5),
                                      Icon(Icons.arrow_drop_down,
                                          color: Constants.primary_color)
                                    ]))),
                          ),
                        give_paddings(
                          card.shadow_card(Container(
                              child: Column(children: [
                            single_detail(
                                Icons.payments,
                                "Price".tr,
                                (widget.Course.price == 0)
                                    ? "Free".tr
                                    : (Constants.currency +
                                        widget.Course.price.toString())),
                            single_detail(Icons.access_time_filled,
                                "Duration".tr, widget.Course.duration),
                            single_detail(
                                Icons.people,
                                "Enrolled".tr,
                                widget.Course.count_students.toString() +
                                    " " +
                                    "students".tr),
                            single_detail(
                                Icons.date_range,
                                "Last Modified".tr,
                                widget.Course.date_modified_gmt
                                    .substring(0, 10)),
                            single_detail(
                                Icons.file_copy,
                                "Lessons".tr,
                                _coursesController
                                    .get_lessons_count(widget.Course)
                                    .toString()),
                            if (_coursesController
                                    .get_Quiz_count(widget.Course) !=
                                0)
                              single_detail(
                                  Icons.quiz,
                                  "Quizzes".tr,
                                  _coursesController
                                      .get_Quiz_count(widget.Course)
                                      .toString()),
                            single_detail(
                                Icons.signal_cellular_alt,
                                "Level".tr,
                                (widget.Course.meta_data.lp_level.isEmpty ||
                                        widget.Course.meta_data.lp_level == "")
                                    ? "All levels".tr
                                    : widget.Course.meta_data.lp_level,
                                showDivider: true),
                            if (widget.Course.certificate != "")
                              single_detail(FontAwesomeIcons.certificate,
                                  "Certificate".tr, "Yes".tr,
                                  showDivider: false, isFA: true),
                          ]))),
                        ),
                        buildTitle("Curriculum".tr),
                        build_curriculum(widget.Course),
                        if ((widget.Course.meta_data.lp_requirements) != "" &&
                            (widget.Course.meta_data.lp_requirements).length !=
                                0)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildTitle("Requirements".tr),
                              give_paddings(build_list(
                                  widget.Course.meta_data.lp_requirements))
                            ],
                          ),
                        if ((widget.Course.meta_data.lp_target_audiences) !=
                                "" &&
                            (widget.Course.meta_data.lp_target_audiences)
                                    .length !=
                                0)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildTitle("Target Audiences".tr),
                              give_paddings(build_list(
                                  widget.Course.meta_data.lp_target_audiences))
                            ],
                          ),
                        if ((widget.Course.meta_data.lp_key_features) != "" &&
                            (widget.Course.meta_data.lp_key_features).length !=
                                0)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildTitle("Key Features".tr),
                              give_paddings(build_list(
                                  widget.Course.meta_data.lp_key_features))
                            ],
                          ),
                        if ((widget.Course.meta_data.lp_faqs) != "" &&
                            (widget.Course.meta_data.lp_faqs).length != 0)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildTitle("FAQs".tr),
                              give_paddings(
                                  BuildFAQ(widget.Course.meta_data.lp_faqs)),
                            ],
                          ),
                        if ((_homeController.courseslist.length > 1))
                          Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildTitle("Related courses".tr),
                                give_paddings(
                                    build_related_courses(widget.Course))
                              ]),
                        if (widget.Course.rating != false)
                          Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildTitle("Reviews".tr),
                                give_paddings(build_reviews(widget.Course))
                              ])
                      ])),
                  Expanded(
                    flex: (ScreenUtil().orientation == Orientation.portrait)
                        ? 1
                        : 2,
                    child: Obx(() {
                      // ignore: unused_local_variable
                      var coursescontroller =
                          // ignore: invalid_use_of_protected_member
                          _myCoursesController.enrolledCoursesList.value;
                      if (_homeController.isLoggedIn.value) {
                        return Padding(
                            padding: EdgeInsets.all(10.h),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (widget.Course.price == 0 &&
                                      widget.Course.course_data.status == "")
                                    SizedBox(
                                      width: Get.width * 1 - (20.w),
                                      child: Center(
                                        child: theme_buttons.material_button(
                                            "Enroll Now".tr, 0.6,
                                            onTap: () async {
                                          notify.showLoadingDialog(
                                              "Trying to enroll".tr);
                                          final enrollcourse =
                                              await CoursesApi.EnrollCourse(
                                                  widget.Course.id);
                                          Get.back();
                                          final snackBar = SnackBar(
                                              content: Text(
                                                  (enrollcourse)["message"]));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackBar);
                                          _myCoursesController
                                              .addtoEnrolledCourses(
                                                  widget.Course);
                                          await Future.delayed(
                                              const Duration(seconds: 3));
                                          _takeCourseController
                                              .open_take_course(widget.Course);
                                        }),
                                      ),
                                    ),
                                  if (widget.Course.price != 0 &&
                                      widget.Course.course_data.status == "" &&
                                      !GetPlatform.isIOS)
                                    Obx(() {
                                      if (!_cartController
                                          .isInCart(widget.Course)) {
                                        return theme_buttons.material_button(
                                            "Add to cart".tr,
                                            (GetPlatform.isIOS) ? 0.8 : 0.45,
                                            onTap: () async {
                                          await _cartController
                                              .addtocart(widget.Course);
                                          setState(() {});
                                          var snackBar = SnackBar(
                                            content: Text(
                                              "Course added to cart successfully."
                                                  .tr,
                                            ),
                                            duration:
                                                const Duration(seconds: 2),
                                          );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackBar);
                                        });
                                      }
                                      return theme_buttons
                                          .material_button("View cart".tr, 0.45,
                                              onTap: () async {
                                        Get.to(BuyNowScreen(
                                            _cartController.cart_items,
                                            "Your Cart".tr));
                                      });
                                    }),
                                  const Spacer(),
                                  if (widget.Course.price != 0 &&
                                      widget.Course.course_data.status == "")
                                    theme_buttons.material_button(
                                        "Buy Now".tr, 0.45, onTap: () {
                                      Get.to(BuyNowScreen(
                                          [widget.Course], "Buy Now".tr));
                                    },
                                        background_color: Colors.white,
                                        textColor: Constants.primary_color),
                                  if (widget.Course.course_data.status ==
                                          "enrolled" &&
                                      widget.Course.course_data.graduation ==
                                          "in-progress")
                                    SizedBox(
                                        width: Get.width - (20.w),
                                        child: Center(
                                            child: theme_buttons
                                                .material_button(
                                                    "Continue Course".tr, 0.8,
                                                    onTap: () {
                                          _takeCourseController
                                              .open_take_course(widget.Course);
                                        }))),
                                ]));
                      }
                      return Padding(
                          padding: EdgeInsets.all(10.h),
                          child: theme_buttons.material_button("Login".tr, 0.35,
                              onTap: () {
                            Get.to(LoginRegisterScreen());
                          }));
                    }),
                  )
                ],
              );
            })));
  }

  showMembershipDialog(context, var membership) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              child: Container(
                  height: 300.h,
                  width: 450.w,
                  child: ListView(
                    physics: BouncingScrollPhysics(),
                    children: [
                      Container(
                          color: Constants.primary_color.withOpacity(0.7),
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text(
                                "\"" +
                                    (widget.Course as Courses).name +
                                    "\" course is available in the following membership plans",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                            ],
                          )),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            for (var single in membership)
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(single["name"],
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 19)),
                                      Text(
                                          Constants.currency +
                                              single["cost"].toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 19,
                                              color: Constants.primary_color))
                                    ]),
                              ),
                            SizedBox(height: 20),
                            (_homeController.isLoggedIn.value)
                                ? Container(
                                    height: 50,
                                    child: theme_buttons.material_button(
                                        "Get Membership Now", 0.7, onTap: () {
                                      Get.back();
                                      Get.to(membershipsScreen());
                                    }))
                                : theme_buttons.material_button("Login", 0.3,
                                    onTap: () {
                                    Get.to(LoginRegisterScreen());
                                  })
                          ],
                        ),
                      )
                    ],
                  )));
        });
  }

  Widget build_curriculum(Courses course) {
    if (count ==
        (_coursesController.get_lessons_count(course) +
            _coursesController.get_Quiz_count(course))) {
      count = 0;
    }
    return give_paddings(Column(
      children: [
        for (var section in course.sections)
          Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ListTileTheme(
                  contentPadding: const EdgeInsets.all(0),
                  child: CustomExpansionTile(
                    expandedAlignment: Alignment.bottomCenter,
                    title: Text(
                      section.title +
                          ((section.description != "") ? " - " : "") +
                          section.description,
                      maxLines: 2,
                      style: const TextStyle(color: Color(0xff3E3E3E)),
                    ),
                    children: [
                      for (var item in section.items)
                        Container(
                            padding: EdgeInsets.fromLTRB(20.w, 7.h, 0, 7.h),
                            child: build_row(item))
                    ],
                  )))
      ],
    ));
  }

  Widget build_row(var item) {
    count++;
    return Row(
      children: [
        Text(count.toString(), style: TextStyle(fontSize: 16.sp)),
        SizedBox(width: 20.w),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: Get.width * 0.5,
                child: Text(
                  item.title,
                  style: TextStyle(fontSize: 16.sp),
                  maxLines: 5,
                )),
            SizedBox(height: 5.h),
            Row(
              children: [
                Text(
                  get_type_text(item.type),
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.start,
                ),
                (item.duration != "")
                    ? Text(" - " + item.duration,
                        style: const TextStyle(color: Colors.grey))
                    : Container()
              ],
            )
          ],
        ),
        const Spacer(),
        (item.preview)
            ? theme_buttons.text_button("Preview".tr, onTap: () {
                _previewController.getItem(item);
                Navigator.of(context).push(PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (BuildContext context, _, __) =>
                        preview(item)));
              })
            : Container()
      ],
    );
  }

  static get_type_text(var type) {
    if (type == "lp_quiz") {
      return "Quiz".tr;
    }
    if (type == "lp_lesson") {
      return "Lesson".tr;
    }
    if (type == "lp_h5p") {
      return "H5P".tr;
    }
  }

  static build_list(List list) {
    return Column(
      children: [
        for (var values in list)
          Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 10.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.fromLTRB(0, 4.h, 0, 0),
                    child: const Icon(
                      Icons.fiber_manual_record,
                      size: 8,
                      color: Colors.black,
                    )),
                SizedBox(width: 8.w),
                Flexible(
                    child: Text(
                  values,
                  style: TextStyle(fontSize: 16.sp),
                  maxLines: 3,
                ))
              ],
            ),
          )
      ],
    );
  }

  BuildFAQ(var faq) {
    return Column(children: <Widget>[
      for (var singleFaq in faq)
        Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: Padding(
                padding: EdgeInsets.fromLTRB(0, 5.h, 0, 5.h),
                child: ExpansionTile(
                  collapsedIconColor: Constants.primary_color,
                  iconColor: Constants.primary_color,
                  tilePadding: const EdgeInsets.all(0),
                  childrenPadding: EdgeInsets.fromLTRB(20.w, 2.h, 0, 2.h),
                  title: Text(singleFaq[0]),
                  children: [html_content.html_widget(singleFaq[1])],
                )))
    ]);
  }

  Widget build_related_courses(Courses course) {
    return FutureBuilder(
      future: _coursesController.get_related_courses(course, count: 3),
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          return Column(
            children: [
              for (Courses singleCourse in snapshot.data as dynamic)
                BuildGrid3(singleCourse, push_replace: true)
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget build_reviews(Courses course) {
    return FutureBuilder(
        future: _getReviews,
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors
                                  .grey, //                   <--- border color
                              width: 1.0.w,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(5
                                    .r) //                 <--- border radius here
                                ),
                          ),
                          padding: EdgeInsets.all(10.h),
                          child: Column(children: [
                            Text(course.rating.toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 40)),
                            RatingBarIndicator(
                              rating: course.rating.toDouble(),
                              itemBuilder: (context, index) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              itemCount: 5,
                              itemSize: 15,
                              direction: Axis.horizontal,
                            ),
                            SizedBox(height: 5.h),
                            Text((snapshot.data as dynamic).length.toString() +
                                " " +
                                "Total".tr),
                          ])),
                      SizedBox(width: 10.w),
                      Column(
                        children: [
                          for (int i = 5; i >= 1; i--)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 7),
                              child: Row(
                                children: [
                                  Text(i.toString()),
                                  LinearPercentIndicator(
                                    width: 180.w,
                                    lineHeight: 10.0.h,
                                    percent: GetRatedcount(
                                            i, (snapshot.data as dynamic)) /
                                        (snapshot.data as dynamic).length,
                                    backgroundColor: Colors.grey,
                                    progressColor: Colors.amber,
                                    barRadius: Radius.circular(5.r),
                                  ),
                                  Text(GetRatedcount(
                                          i, (snapshot.data as dynamic))
                                      .toString())
                                ],
                              ),
                            )
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 5.h),
                  for (reviews review in snapshot.data as dynamic)
                    Padding(
                        padding: EdgeInsets.symmetric(vertical: 7.h),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (review.avatar != "")
                                    ExtendedImage.network(
                                      review.avatar,
                                      height: 30.h,
                                      width: 30.w,
                                      shape: BoxShape.circle,
                                    ),
                                  if (review.avatar == "")
                                    ExtendedImage.asset(
                                      "assets/user.png",
                                      height: 30.h,
                                      width: 30.w,
                                      shape: BoxShape.circle,
                                    ),
                                  SizedBox(width: 15.w),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(review.display_name,
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(height: 3.h),
                                      Row(
                                        children: [
                                          RatingBarIndicator(
                                            rating: double.parse(review.rate),
                                            itemBuilder: (context, index) =>
                                                const Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                            itemCount: 5,
                                            itemSize: 15,
                                            direction: Axis.horizontal,
                                          ),
                                          SizedBox(width: 5.w),
                                          Text(review.time,
                                              style: const TextStyle(
                                                  color: Colors.grey))
                                        ],
                                      ),
                                    ],
                                  )
                                ]),
                            SizedBox(height: 3.h),
                            Text(review.content)
                          ],
                        ))
                ]);
          }
          return const Center(child: CircularProgressIndicator());
        });
  }

  GetRatedcount(int rate, List<dynamic> Reviews) {
    int count = 0;
    for (var review in Reviews) {
      if (review.rate.toString() == rate.toString()) {
        count++;
      }
    }
    return count;
  }

  addtorecentsearch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> recentcourses = [];
    if (prefs.getStringList("recent_searches") != null) {
      recentcourses = prefs.getStringList("recent_searches") ?? [];
      for (var course in recentcourses) {
        if (json.decode(course)["id"] == widget.Course.id) {
          recentcourses.remove(course);
        }
      }
    }
    recentcourses.insert(0, json.encode(widget.Course));
    prefs.setStringList("recent_searches", recentcourses);
  }

  static Widget give_paddings(Widget childWidgets) {
    return Container(
        padding: EdgeInsets.fromLTRB(25.w, 10.h, 25.w, 0), child: childWidgets);
  }

  static Widget single_detail(var icon, String title, String text,
      {showDivider = true, isFA = false}) {
    return Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color:
                        (showDivider) ? const Color(0xffD3D3D3) : Colors.white,
                    width: 1.w))),
        padding: EdgeInsets.fromLTRB(20.w, 13.h, 20.w, 13.h),
        child: Row(children: [
          (isFA)
              ? FaIcon(icon, color: Constants.primary_color)
              : Icon(icon, color: Constants.primary_color),
          SizedBox(width: 8.w),
          Text(title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
          const Spacer(),
          Text(text,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: (title == "Price".tr) ? Colors.red : Colors.grey,
                  fontSize: 16.sp)),
        ]));
  }

  static Widget buildRating(num Rating) {
    return Row(children: [
      Text(Rating.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold)),
      SizedBox(width: 3.w),
      RatingBarIndicator(
        rating: Rating.toDouble(),
        itemBuilder: (context, index) => const Icon(
          Icons.star,
          color: Colors.amber,
        ),
        itemCount: 5,
        itemSize: 15,
        direction: Axis.horizontal,
      )
    ]);
  }

  static Widget buildTitle(String title) {
    return give_paddings(Text(title,
        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)));
  }
}

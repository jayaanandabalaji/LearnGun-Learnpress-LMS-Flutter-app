import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:LearnGun/widgets/PleaseLogin.dart';
import 'package:android_path_provider/android_path_provider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Controllers/TakeCourseController.dart';
import '../../Models/Courses.dart';
import '../../utils/constants.dart';
import '../../widgets/Button.dart';
import '../../services/CoursesAPI.dart';
import '../../Controllers/MyCoursesController.dart';
import '../../widgets/NoData.dart';
import '../Controllers/HomeController.dart';
import '../services/SharedPrefs.dart';
import '../utils/constants.dart';

class CoursesScreen extends StatefulWidget {
  final IsOffline;
  const CoursesScreen({this.IsOffline = false});
  static const routeName = '/courses';
  @override
  _CoursesScreenState createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final HomeController _homeController = Get.put(HomeController());

  late Future _fetchMyCourses;
  final MyCoursesController _myCoursesController =
      Get.put(MyCoursesController());
  final TakeCourseController _takeCourseController =
      Get.put(TakeCourseController());
  var certLoaded = false;
  String certImage = "";
  final scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    _fetchMyCourses =
        (_homeController.isLoggedIn.value) ? CoursesApi.MyCourses() : dummy();
  }

  Future dummy() async {}
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_homeController.isLoggedIn.value) {
        return Scaffold(
          body: DefaultTabController(
            length: 2,
            child: Scaffold(
              key: scaffoldKey,
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Constants.primary_color,
                title: Text((widget.IsOffline)
                    ? 'Downloaded Courses'.tr
                    : 'Your course'.tr),
                bottom: PreferredSize(
                    preferredSize:
                        Size.fromHeight(50.h), // here the desired height
                    child: Column(
                      children: [
                        TabBar(
                            labelColor: Constants.primary_color,
                            unselectedLabelColor: Colors.white,
                            indicatorSize: TabBarIndicatorSize.label,
                            indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(50.r),
                                color: Colors.white),
                            tabs: [
                              Tab(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text("Enrolled".tr),
                                ),
                              ),
                              Tab(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text("Completed".tr),
                                ),
                              ),
                            ]),
                        SizedBox(
                          height: 7.h,
                        ),
                      ],
                    )),
              ),
              body: TabBarView(
                children: [
                  FutureBuilder(
                    future: _fetchMyCourses,
                    builder: (context, dynamic snapshot) {
                      if (snapshot.data != null) {
                        if (_myCoursesController.enrolledCoursescount.value ==
                            0) {
                          _myCoursesController.enrolledCoursesList.value =
                              _myCoursesController.enrolledCoursesList
                                      .toList(growable: false) +
                                  _myCoursesController.filterCourses(
                                      "enrolled", snapshot.data);
                          _myCoursesController.enrolledCoursescount.value =
                              _myCoursesController.enrolledCoursesList
                                  .toList(growable: false)
                                  .length;
                        }
                        return Obx(() {
                          if (_myCoursesController.enrolledCoursescount.value ==
                              0) {
                            return NoData.noData("not-enrolled",
                                "You have not enrolled in any courses yet".tr);
                          }
                          return ListView(
                            padding: EdgeInsets.symmetric(
                                horizontal: 30.h, vertical: 10.h),
                            children: [
                              for (var course in _myCoursesController
                                  .enrolledCoursesList
                                  .toList(growable: false))
                                Column(children: [
                                  EnrolledCoursesGrid(course),
                                  SizedBox(
                                    height: 10.h,
                                  ),
                                ])
                            ],
                          );
                        });
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                  FutureBuilder(
                    future: _fetchMyCourses,
                    builder: (context, dynamic snapshot) {
                      if (snapshot.data != null) {
                        if (_myCoursesController.completedCoursescount.value ==
                            0) {
                          _myCoursesController.completedCoursesList.value =
                              _myCoursesController.filterCourses(
                                  "finished", snapshot.data);
                          _myCoursesController.completedCoursescount.value =
                              _myCoursesController.completedCoursesList
                                  .toList(growable: false)
                                  .length;
                        }
                        return Obx(() {
                          if (_myCoursesController
                                  .completedCoursescount.value ==
                              0) {
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 20.h),
                              child: NoData.noData("not-enrolled",
                                  "You have not completed any courses yet".tr,
                                  imageHeight: 200),
                            );
                          }
                          return ListView(
                            padding: EdgeInsets.symmetric(
                                horizontal: 30.h, vertical: 10.h),
                            children: [
                              for (var course in _myCoursesController
                                  .completedCoursesList
                                  .toList(growable: false))
                                Column(children: [
                                  CompletedCourseGrid(course),
                                  SizedBox(
                                    height: 10.h,
                                  ),
                                ])
                            ],
                          );
                        });
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        );
      }
      return pleaseLogin();
    });
  }

  EnrolledCoursesGrid(Courses course) {
    return SizedBox(
      height: 290.h,
      width: (ScreenUtil().orientation == Orientation.portrait)
          ? Get.width
          : 200.w,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15.r),
                    topRight: Radius.circular(15.r),
                    bottomLeft: Radius.zero,
                    bottomRight: Radius.zero),
                child: ExtendedImage.network(
                  course.image,
                  height: 140.h,
                  width: Get.width,
                  fit: BoxFit.cover,
                  cache: true,
                )),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 5.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.name,
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.bold),
                      maxLines: 2,
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 10.h,
                    ),
                    LinearProgressIndicator(
                      value:
                          (course.course_data.result.result / 100).toDouble(),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(course.duration),
                        Text(
                          course.course_data.result.result.toString() +
                              "% " +
                              "complete".tr,
                          style: const TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                    const Spacer(),
                    Center(
                      child: theme_buttons.material_button(
                          "Continue Course".tr, 0.6,
                          background_color: Colors.black54, onTap: () {
                        _takeCourseController.open_take_course(course,
                            isOffline: widget.IsOffline);
                      }),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget CompletedCourseGrid(Courses course) {
    return SizedBox(
      height: 290.h,
      width: (ScreenUtil().orientation == Orientation.portrait)
          ? Get.width
          : 200.w,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15.r),
                    topRight: Radius.circular(15.r),
                    bottomLeft: Radius.zero,
                    bottomRight: Radius.zero),
                child: ExtendedImage.network(
                  course.image,
                  height: 140.h,
                  width: Get.width,
                  fit: BoxFit.cover,
                  cache: true,
                )),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 5.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.name,
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.bold),
                      maxLines: 2,
                    ),
                    const Spacer(),
                    if (!course.can_retake)
                      Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                "You started on".tr + ": ",
                                style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(course.course_data.start_time
                                  .substring(0, 10))
                            ],
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Row(
                            children: [
                              Text(
                                "You finished on".tr + ": ",
                                style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(course.course_data.end_time.substring(0, 10))
                            ],
                          )
                        ],
                      ),
                    SizedBox(
                      height: 10.h,
                    ),
                    LinearProgressIndicator(
                      value:
                          (course.course_data.result.result / 100).toDouble(),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(course.course_data.graduation),
                        Text(
                          course.course_data.result.result.toString() +
                              "% " +
                              "complete".tr,
                          style: const TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                    const Spacer(),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          (course.can_retake)
                              ? Center(
                                  child: theme_buttons.material_button(
                                      "Retake".tr, 0.3,
                                      background_color: Colors.black54,
                                      onTap: () {
                                    _myCoursesController.retakeCourse(course);
                                  }),
                                )
                              : Container(),
                          (course.certificate != "")
                              ? Center(
                                  child: theme_buttons.material_button(
                                      "Certificate".tr, 0.3,
                                      background_color: Colors.black54,
                                      onTap: () {
                                    certLoaded = false;
                                    certImage = "";
                                    OpenCertificateDialog(course);
                                  }),
                                )
                              : Container(),
                        ])
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  OpenCertificateDialog(var course) {
    showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(child: StatefulBuilder(
              builder: (context, setstate) {
                return Container(
                    height: 300.h,
                    width: 300.w,
                    child: FutureBuilder(
                      future: GetImageUrl(course),
                      builder: (context, snapshot) {
                        if (snapshot.data != null) {
                          return Column(
                            children: [
                              Container(
                                  height: 210.h,
                                  width: 300.w,
                                  child: (!certLoaded)
                                      ? Stack(
                                          children: [
                                            InAppWebView(
                                              initialOptions:
                                                  InAppWebViewGroupOptions(
                                                      crossPlatform:
                                                          InAppWebViewOptions(
                                                              cacheEnabled:
                                                                  false,
                                                              clearCache:
                                                                  true)),
                                              initialUrlRequest: URLRequest(
                                                  url: Uri.parse(snapshot.data
                                                      as dynamic)),
                                              onConsoleMessage:
                                                  (InAppWebViewController
                                                          controller,
                                                      ConsoleMessage
                                                          consoleMessage) {
                                                if (consoleMessage.message
                                                    .contains("data:image")) {
                                                  setstate(() {
                                                    certLoaded = true;
                                                    certImage =
                                                        consoleMessage.message;
                                                  });
                                                }
                                              },
                                            ),
                                            Center(
                                                child:
                                                    CircularProgressIndicator())
                                          ],
                                        )
                                      : ExtendedImage.memory(base64Decode(
                                          certImage.replaceAll(
                                              "data:image/png;base64,", "")))),
                              if (certLoaded)
                                Expanded(
                                  child: Center(
                                      child: theme_buttons.material_button(
                                          "Download".tr, 0.5, onTap: () async {
                                    await [
                                      Permission.storage,
                                    ].request();
                                    Uint8List bytes = base64.decode(
                                        certImage.replaceAll(
                                            "data:image/png;base64,", ""));
                                    var downloadsPath = "";
                                    if (Platform.isAndroid) {
                                      downloadsPath = await AndroidPathProvider
                                          .downloadsPath;
                                    } else {
                                      downloadsPath =
                                          (await getApplicationDocumentsDirectory())
                                              .path;
                                    }
                                    File file = File("$downloadsPath/" +
                                        DateTime.now()
                                            .millisecondsSinceEpoch
                                            .toString() +
                                        ".png");
                                    await file.writeAsBytes(bytes);
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "Certificate downloaded to gallery successfully!!!")));
                                  })),
                                )
                            ],
                          );
                        }
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ));
              },
            )));
  }

  Future GetImageUrl(var course) async {
    var user_id = await prefs.getString('user_info_id');

    return Constants.base_url +
        "/wp-content/plugins/learnpress%20app%20options/includes/certificate.php?course=" +
        course.id.toString() +
        "&user=" +
        user_id +
        "&license=" +
        Constants.purchase_code;
  }
}

import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../utils/constants.dart';
import '../../widgets/CoursesAppBarActions.dart';
import '../Models/Instructor.dart';
import '../../widgets/HtmlWidget.dart';
import '../../services/CoursesAPI.dart';
import '../../widgets/grids/grid3.dart';

// ignore: must_be_immutable
class AuthorProfile extends StatefulWidget {
  Instructor instructor;
  AuthorProfile(this.instructor);
  @override
  _AuthorProfileState createState() => _AuthorProfileState();
}

class _AuthorProfileState extends State<AuthorProfile> {
  RefreshController refreshController = RefreshController(initialRefresh: false);
  final _enablePullDown = false.obs;
  final _authorCourses = [].obs;
  int page = 1;

  @override
  void initState() {
    super.initState();
    CoursesApi().GetCourses({"author": widget.instructor.id}).then((data) {
      _enablePullDown.value = true;
      _authorCourses.value = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          actions: [
            IconButton(
                onPressed: () {
                  Share.share(widget.instructor.link);
                },
                icon: const Icon(
                  Icons.share,
                  color: Colors.white,
                )),
            CoursesAppBarActions().search(),
          ],
        ),
        body: Obx(() {
          return SmartRefresher(
              enablePullDown: false,
              enablePullUp: _enablePullDown.value,
              footer: const ClassicFooter(noMoreIcon: Icon(Icons.error, color: Colors.grey)),
              onLoading: () async {
                if (_authorCourses.length % 10 != 0) {
                  refreshController.loadNoData();
                } else {
                  page++;
                  var response = await CoursesApi().GetCourses({"author": widget.instructor.id, "page": page});
                  // ignore: invalid_use_of_protected_member
                  _authorCourses.value = _authorCourses.value + response;
                  refreshController.loadComplete();
                }
              },
              controller: refreshController,
              child: ListView(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(35.h, 0, 15.h, 0),
                    height: Get.height * 0.3,
                    width: Get.width,
                    color: Constants.primary_color,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            (widget.instructor.avatar_url != "")
                                ? ClipRRect(
                                    borderRadius: BorderRadius.all(Radius.circular(65.r)),
                                    child: ExtendedImage.network(widget.instructor.avatar_url, height: 90.h))
                                : ExtendedImage.asset("assets/user.png", height: 100.h),
                            SizedBox(
                              width: 10.w,
                            ),
                            Text(
                              widget.instructor.name,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.sp, color: Colors.white),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 10.w,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "students".tr,
                                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 18.sp),
                                ),
                                SizedBox(
                                  height: 7.h,
                                ),
                                Text(
                                  widget.instructor.instructor_data.students.toString(),
                                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 20.sp),
                                )
                              ],
                            ),
                            SizedBox(
                              width: 50.w,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Courses".tr,
                                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 18.sp),
                                ),
                                SizedBox(
                                  height: 7.h,
                                ),
                                Text(
                                  widget.instructor.instructor_data.courses.toString(),
                                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 20.sp),
                                )
                              ],
                            )
                          ],
                        ),
                        const Spacer(),
                        if (widget.instructor.social.linkedin != "" ||
                            widget.instructor.social.youtube != "" ||
                            widget.instructor.social.twitter != "" ||
                            widget.instructor.social.facebook != "")
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              (widget.instructor.social.linkedin != "")
                                  ? IconButton(
                                      onPressed: () {
                                        _launchURL(widget.instructor.social.linkedin);
                                      },
                                      icon: const FaIcon(
                                        FontAwesomeIcons.linkedin,
                                        color: Colors.white,
                                        size: 22,
                                      ))
                                  : Container(),
                              (widget.instructor.social.youtube != "")
                                  ? IconButton(
                                      onPressed: () {
                                        _launchURL(widget.instructor.social.youtube);
                                      },
                                      icon: const FaIcon(
                                        FontAwesomeIcons.youtube,
                                        color: Colors.white,
                                        size: 22,
                                      ))
                                  : Container(),
                              (widget.instructor.social.facebook != "")
                                  ? IconButton(
                                      onPressed: () {
                                        _launchURL(widget.instructor.social.facebook);
                                      },
                                      icon: const FaIcon(
                                        FontAwesomeIcons.facebook,
                                        color: Colors.white,
                                        size: 22,
                                      ))
                                  : Container(),
                              (widget.instructor.social.twitter != "")
                                  ? IconButton(
                                      onPressed: () {
                                        _launchURL(widget.instructor.social.twitter);
                                      },
                                      icon: const FaIcon(
                                        FontAwesomeIcons.twitter,
                                        color: Colors.white,
                                        size: 22,
                                      ))
                                  : Container(),
                            ],
                          )
                      ],
                    ),
                  ),
                  if (widget.instructor.description != "")
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        build_title("Bio".tr + ":"),
                        Padding(
                          padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 0),
                          child: html_content.html_widget(widget.instructor.description),
                        )
                      ],
                    ),
                  build_title("Courses".tr + ":"),
                  if (_authorCourses.isNotEmpty)
                    give_padding(Column(
                      children: [
                        for (var course in _authorCourses) BuildGrid3(course),
                      ],
                    )),
                  if (_authorCourses.isEmpty)
                    SizedBox(
                      height: Get.height * 0.3,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                ],
              ));
        }));
  }

  Widget build_title(String text) {
    return give_padding(Text(
      text,
      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
    ));
  }

  Widget give_padding(Widget childWidget) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0.h),
      child: childWidget,
    );
  }

  void _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url))) throw 'Could not launch $url';
  }
}

import 'package:intl/intl.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../Models/Blogs.dart';
import '../services/BlogsAPI.dart';
import '../utils/constants.dart';
import 'blogDetails.dart';
import 'singleWebinar.dart';

class resourcesScreen extends StatefulWidget {
  final int initalIndex;
  const resourcesScreen({this.initalIndex = 0});

  @override
  State<resourcesScreen> createState() => _resourcesScreenState();
}

class _resourcesScreenState extends State<resourcesScreen> {
  int page = 1;
  var unescape = HtmlUnescape();
  RefreshController refreshController = RefreshController(initialRefresh: false);
  RefreshController othersRefreshController = RefreshController(initialRefresh: false);
  var blogsList = [];
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        initialIndex: widget.initalIndex,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Resources".tr),
            bottom: TabBar(
              tabs: [
                Tab(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text("Blogs".tr),
                  ),
                ),
                Tab(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text("Webinars".tr),
                  ),
                ),
                Tab(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text("others".tr),
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              FutureBuilder(
                  future: BlogsApi().GetBlogs(),
                  builder: ((context, snapshot) {
                    if (snapshot.data != null) {
                      blogsList = snapshot.data as List<dynamic>;
                      return StatefulBuilder(builder: (BuildContext _, setter) {
                        return SmartRefresher(
                            enablePullDown: false,
                            enablePullUp: true,
                            footer: const ClassicFooter(noMoreIcon: Icon(Icons.error, color: Colors.grey)),
                            onLoading: () async {
                              if (blogsList.length % 10 != 0) {
                                refreshController.loadNoData();
                              } else {
                                blogsList = blogsList + (await BlogsApi().GetBlogs(page: ++page));
                                setter(() {});
                                refreshController.loadComplete();
                              }
                            },
                            controller: refreshController,
                            child: ListView(
                              children: [for (blogs blog in blogsList) buildBlog(blog)],
                            ));
                      });
                    }
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  })),
              ListView(
                padding: EdgeInsets.only(top: 15, bottom: 15),
                children: [
                  FutureBuilder(
                      future: BlogsApi().GetWebinars(),
                      builder: ((context, snapshot) {
                        if (snapshot.data != null) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding: EdgeInsets.only(
                                    left: 20.w,
                                  ),
                                  child: Text(
                                    "Upcoming Webinars".tr,
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                              Container(
                                height: 340.h,
                                child: ListView(
                                  physics: BouncingScrollPhysics(),
                                  padding: EdgeInsets.all(15.h),
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    for (blogs blog in snapshot.data as List<dynamic>)
                                      if (DateTime.now().isBefore(DateTime.parse(blog.details["start_time"])))
                                        buildLiveWebinar(blog)
                                  ],
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(
                                    left: 20.w,
                                  ),
                                  child: Text(
                                    "Ended Webinars".tr,
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                              Container(
                                height: 300.h,
                                child: ListView(
                                  physics: BouncingScrollPhysics(),
                                  padding: EdgeInsets.all(15.h),
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    for (blogs blog in snapshot.data as List<dynamic>)
                                      if (DateTime.now().isAfter(DateTime.parse(blog.details["start_time"])))
                                        buildLiveWebinar(blog, isEnded: true)
                                  ],
                                ),
                              )
                            ],
                          );
                        }
                        return Center(
                          child: Container(
                              height: Get.height * 0.3,
                              child: Center(
                                child: CircularProgressIndicator(),
                              )),
                        );
                      })),
                ],
              ),
              FutureBuilder(
                  future: BlogsApi().GetOtherResources(),
                  builder: ((context, snapshot) {
                    if (snapshot.data != null) {
                      blogsList = snapshot.data as List<dynamic>;
                      return StatefulBuilder(builder: (BuildContext _, setter) {
                        return SmartRefresher(
                            enablePullDown: false,
                            enablePullUp: true,
                            footer: const ClassicFooter(noMoreIcon: Icon(Icons.error, color: Colors.grey)),
                            onLoading: () async {
                              if (blogsList.length % 10 != 0) {
                                othersRefreshController.loadNoData();
                              } else {
                                blogsList = blogsList + (await BlogsApi().GetBlogs(page: ++page));
                                setter(() {});
                                othersRefreshController.loadComplete();
                              }
                            },
                            controller: othersRefreshController,
                            child: ListView(
                              children: [for (blogs blog in blogsList) buildBlog(blog, isOthers: true)],
                            ));
                      });
                    }
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  })),
            ],
          ),
        ));
  }

  Widget buildLiveWebinar(blogs blog, {bool isEnded = false}) {
    return GestureDetector(
      onTap: () {
        if (!(isEnded)) {
          Get.to(singleWebinar(blog: blog));
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Container(
          width: 290.w,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                        borderRadius:
                            BorderRadius.only(topLeft: Radius.circular(15.r), topRight: Radius.circular(15.r)),
                        child: (blog.embedded["wp:featuredmedia"] != null &&
                                blog.embedded["wp:featuredmedia"][0]["source_url"] != null)
                            ? ExtendedImage.network(
                                blog.embedded["wp:featuredmedia"][0]["source_url"],
                                height: 150.h,
                                width: 300.w,
                                fit: BoxFit.cover,
                              )
                            : ExtendedImage.asset(
                                "assets/placeholder.jpg",
                                height: 150.h,
                                width: 300.w,
                                fit: BoxFit.cover,
                              )),
                    Container(
                      height: 150.h,
                      width: 300.w,
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                          padding: EdgeInsets.only(left: 10.w, bottom: 10.h),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.r),
                                color: (isEnded) ? Colors.redAccent : Constants.primary_color),
                            padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                            child: Text(
                              (isEnded) ? "ENDED".tr : "UPCOMING".tr,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          )),
                    )
                  ],
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 10.h),
                  child: Text(
                    unescape.convert(blog.title.rendered),
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                    maxLines: 2,
                  ),
                ),
                Padding(
                    padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 5.h),
                    child: Text(
                      DateFormat('EEEE, MMM dd, yyyy').format(DateTime.parse(blog.details["start_time"])),
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey, fontWeight: FontWeight.w500),
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 5.h),
                    child: Text(
                      DateFormat('jm').format(DateTime.parse(blog.details["start_time"])) +
                          " - " +
                          DateFormat('jm').format(DateTime.parse(blog.details["start_time"])
                              .add(Duration(minutes: blog.details["duration"]))),
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey, fontWeight: FontWeight.w500),
                    )),
                SizedBox(
                  width: 10.w,
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 10.w),
                    child: (isEnded)
                        ? Container()
                        : Text("Join webinar".tr + " →",
                            style: TextStyle(
                                fontSize: 18.sp, fontWeight: FontWeight.bold, color: Constants.primary_color)),
                  ),
                ),
              ]),
        ),
      ),
    );
  }

  Widget buildBlog(blogs blog, {bool isOthers: false}) {
    return InkWell(
      onTap: () {
        Get.to(blogdetail(
          blog: blog,
          isOthers: isOthers,
        ));
      },
      child: Container(
        width: Get.width,
        padding: EdgeInsets.all(20.h),
        child: Row(children: [
          Expanded(
            flex: 65,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    unescape.convert(blog.title.rendered),
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    ((blog.embedded["author"] != null)
                            ? blog.embedded["author"][0]["name"].replaceAll("@gmail.com", "")
                            : "") +
                        " . " +
                        blog.modified.substring(0, 10),
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey, fontWeight: FontWeight.w500),
                  )
                ]),
          ),
          SizedBox(
            width: 10.w,
          ),
          Expanded(
            flex: 35,
            child: (blog.embedded["wp:featuredmedia"] != null &&
                    blog.embedded["wp:featuredmedia"][0]["source_url"] != null)
                ? ExtendedImage.network(blog.embedded["wp:featuredmedia"][0]["source_url"],
                    height: 80.h, fit: BoxFit.cover)
                : ExtendedImage.asset("assets/placeholder.jpg", height: 80.h, fit: BoxFit.cover),
          )
        ]),
      ),
    );
  }
}

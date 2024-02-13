import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Models/OrderComplete.dart';
import '../../services/OrderAPI.dart';
import '../../utils/Extensions.dart';
import '../../utils/constants.dart';
import '../../widgets/BottomNav.dart';
import '../../widgets/Button.dart';
import '../../widgets/Card.dart';
import '../Controllers/CartController.dart';
import '../Controllers/CoursesController.dart';
import '../Controllers/MyCoursesController.dart';
import 'Coursesloading.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final courses;
  final payment_method;
  final titleText;
  PaymentSuccessScreen(this.payment_method, this.courses, {this.titleText = "payment success"});
  @override
  _PaymentSuccessScreenstate createState() => _PaymentSuccessScreenstate();
}

class _PaymentSuccessScreenstate extends State<PaymentSuccessScreen> {
  final coursesController _coursesController = Get.put(coursesController());
  final cartController _cartController = Get.put(cartController());
  final MyCoursesController _myCoursesController = Get.put(MyCoursesController());

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      var coursesList = _coursesController.return_new_courseslist(widget.courses);
      for (var singleCourse in coursesList) {
        _cartController.remove_with_id(singleCourse.id);
      }
      for (var singleCourse in widget.courses) {
        _myCoursesController.addtoEnrolledCourses(singleCourse);
        _myCoursesController.localCompltecourse(singleCourse);
      }
      // ignore: invalid_use_of_protected_member
      _myCoursesController.refresh();
      // ignore: invalid_use_of_protected_member
      _cartController.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.titleText}".tr),
      ),
      body: WillPopScope(
        onWillPop: go_to_home,
        child: FutureBuilder(
          future: OrderApi.GetSettings(widget.payment_method, get_courses_id_list(widget.courses)),
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              complete_order orderResponse = snapshot.data as dynamic;
              return Padding(
                padding: EdgeInsets.all(20.h),
                child: ListView(
                  children: [
                    card.shadow_card(Container(
                      padding: EdgeInsets.all(20.h),
                      width: Get.width * 1.0,
                      child: Column(
                        children: [
                          ExtendedImage.asset(
                            "assets/order_success.png",
                            height: 100.h,
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Date".tr,
                                style: TextStyle(fontSize: 17.sp, color: Colors.grey),
                              ),
                              Text(orderResponse.order_date.split(" ")[0],
                                  style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold))
                            ],
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Order Id".tr,
                                style: TextStyle(fontSize: 17.sp, color: Colors.grey),
                              ),
                              Text(orderResponse.order_id.toString(),
                                  style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold))
                            ],
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Payment method".tr,
                                style: TextStyle(fontSize: 17.sp, color: Colors.grey),
                              ),
                              Text(orderResponse.payment_method.toCapitalized(),
                                  style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold))
                            ],
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total".tr,
                                style: TextStyle(fontSize: 17.sp, color: Colors.grey),
                              ),
                              Text(Constants.currency + orderResponse.total.toString(),
                                  style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold))
                            ],
                          ),
                        ],
                      ),
                    )),
                    SizedBox(
                      height: 20.h,
                    ),
                    Row(
                      children: [
                        theme_buttons.material_button("Start course".tr, 0.40, onTap: () {
                          Get.off(CourseLoading(get_courses_id_list(widget.courses)[0].toString(),
                              isStartCourseScreen: true));
                        }),
                        const Spacer(),
                        theme_buttons.material_button("Go Home".tr, 0.40,
                            background_color: Colors.white, textColor: Constants.primary_color, onTap: () {
                          Get.offAll(BottomNav());
                        }),
                      ],
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Text(
                      "Purchased courses".tr,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
                    ),
                    SizedBox(height: 20.h),
                    card.shadow_card(Container(
                        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 10.h),
                        child: Column(
                          children: [
                            for (coursesBean course in orderResponse.courses)
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 10.h, 0, 10.h),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: Get.width * 0.7,
                                      child: Text(
                                        course.title,
                                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                    Text(
                                      Constants.currency + course.price.toString(),
                                      style:
                                          TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.green),
                                    )
                                  ],
                                ),
                              )
                          ],
                        )))
                  ],
                ),
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  get_courses_id_list(var courses) {
    var tempCoursesIdList = [];
    for (var course in courses) {
      tempCoursesIdList.add(course.id);
    }
    return tempCoursesIdList;
  }

  Future<bool> go_to_home() async {
    await Get.offAll(BottomNav());
    return true;
  }
}

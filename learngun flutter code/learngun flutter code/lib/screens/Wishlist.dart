import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../widgets/NoData.dart';
import '../../Controllers/CoursesController.dart';
import '../Models/Courses.dart';
import '../widgets/grids/grid1.dart';

class WishlistScreen extends StatefulWidget {
  @override
  _wishlistscreenstate createState() => _wishlistscreenstate();
}

class _wishlistscreenstate extends State<WishlistScreen> {
  final coursesController _coursesController = Get.put(coursesController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Wishlists".tr),
          actions: [
            IconButton(
                onPressed: () {
                  showAlertDialog(context);
                },
                icon: const Icon(Icons.delete_forever_rounded))
          ],
        ),
        body: Obx(() {
          if (_coursesController.wishlistedCoursesCount.value == 0) {
            return NoData.noData("wishlist", "Nothing in wishlist".tr, imageHeight: 160);
          }
          return GridView.count(
              padding: EdgeInsets.all(10.h),
              childAspectRatio: (Get.width * 0.2 / 100.h),
              crossAxisCount: 2,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              children: List.generate(_coursesController.wishlistedCourses.length, (index) {
                Courses course = _coursesController.wishlistedCourses[index];
                return BuildGrid1(course);
              }));
        }));
  }

  showAlertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Text("Clear wishlist".tr),
      content: Text("Are you sure, Do you want to clear all your wishlists?".tr),
      actions: [
        TextButton(
          child: Text("Cancel".tr),
          onPressed: () {
            Get.back();
          },
        ),
        TextButton(
          child: Text("Yes".tr),
          onPressed: () {
            _coursesController.removeAllWishlist();
            Get.back();
          },
        )
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

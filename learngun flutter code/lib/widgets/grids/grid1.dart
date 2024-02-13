import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../Models/Courses.dart';
import '../../Controllers/CoursesController.dart';
import '../../screens/Coursesloading.dart';

class BuildGrid1 extends StatelessWidget {
  final coursesController _coursesController = Get.put(coursesController());

  final Courses course;
  BuildGrid1(this.course);
  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: Get.width * 0.4,
        child: Column(
          children: [
            GestureDetector(
                onTap: () {
                  Get.to(CourseLoading(course.id.toString()));
                },
                child: ExtendedImage.network(
                  course.image,
                  height: 100.h,
                  width: Get.width,
                  fit: BoxFit.cover,
                )),
            Container(
              padding: EdgeInsets.fromLTRB(5.w, 5.h, 5.w, 5.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                      onTap: () {
                        Get.to(CourseLoading(course.id.toString()));
                      },
                      child: Text(
                        course.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 2,
                      )),
                  SizedBox(
                    height: 5.h,
                  ),
                  if (course.instructor.name != "")
                    Text(
                      course.instructor.name.replaceAll("@gmail.com", ""),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  SizedBox(
                    height: 5.h,
                  ),
                  if (course.rating != false) (buildRating(course.rating)),
                  SizedBox(
                    height: 5.h,
                  ),
                  GestureDetector(
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline, color: Colors.red),
                        Text(
                          "Remove".tr,
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                    onTap: () {
                      _coursesController.changeWishlist(course);
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  static Widget buildRating(num Rating) {
    return Row(children: [
      Text(Rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
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
}

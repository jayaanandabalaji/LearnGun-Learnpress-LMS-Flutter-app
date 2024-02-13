import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../Controllers/CoursesController.dart';
import '../../Models/Courses.dart';
import '../../screens/curriculumPreview.dart';
import '../../utils/constants.dart';

// ignore: must_be_immutable
class BuildGrid3 extends StatelessWidget {
  final Courses course;
  bool push_replace;
  BuildGrid3(this.course, {this.push_replace = false});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (push_replace) {
            Navigator.of(context)
                .pushReplacement(MaterialPageRoute(builder: (context) => CurriculumScreen(Course: course)));
          } else {
            Get.to(CurriculumScreen(Course: course));
          }
        },
        child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0.r),
            ),
            child: Row(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.r),
                        topRight: Radius.zero,
                        bottomLeft: Radius.circular(15.r),
                        bottomRight: Radius.zero),
                    child: ExtendedImage.network(
                      course.image,
                      height: 133.h,
                      width: 120.h,
                      fit: BoxFit.cover,
                      cache: true,
                    )),
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.all(10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course.name, maxLines: 2, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.sp)),
                      SizedBox(
                        height: 5.h,
                      ),
                      Row(
                        children: [
                          Icon(Icons.people, color: Constants.primary_color),
                          SizedBox(
                            width: 5.w,
                          ),
                          Text(
                            course.count_students.toString(),
                            style: TextStyle(color: Constants.primary_color),
                          ),
                          SizedBox(
                            width: 20.w,
                          ),
                          Icon(Icons.menu_book, color: Constants.primary_color),
                          SizedBox(
                            width: 5.w,
                          ),
                          Text(
                            coursesController().get_lessons_count(course).toString(),
                            style: TextStyle(color: Constants.primary_color),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      if (course.rating != false) (buildRating(course.rating)),
                      SizedBox(
                        height: 5.h,
                      ),
                      (course.price == 0)
                          ? Text("Free".tr, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold))
                          : Text(Constants.currency + course.price.toString(),
                              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ))
              ],
            )));
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

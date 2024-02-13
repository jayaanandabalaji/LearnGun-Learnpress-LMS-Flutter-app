import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';

import '../../Controllers/CoursesController.dart';
import '../../Models/Courses.dart';
import '../../screens/curriculumPreview.dart';
import '../../utils/constants.dart';

class BuildGrid2 extends StatelessWidget {
  final coursesController _coursesController = Get.put(coursesController());
  final Courses course;
  BuildGrid2(this.course);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          pushNewScreen(
            context,
            screen: CurriculumScreen(Course: course),
            withNavBar: false, // OPTIONAL VALUE. True by default.
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        },
        child: SizedBox(
            height: 280.h,
            width: (ScreenUtil().orientation == Orientation.portrait) ? 300.w : 150.w,
            child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                  ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15.r),
                          topRight: Radius.circular(15.r),
                          bottomLeft: Radius.zero,
                          bottomRight: Radius.zero),
                      child: Stack(
                        children: [
                          Hero(
                            tag: "image${course.id}",
                            child: ExtendedImage.network(
                              course.image,
                              height: 150.h,
                              width: 300.w,
                              fit: BoxFit.cover,
                              cache: true,
                            ),
                          ),
                          Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: EdgeInsets.all(5.h),
                                child: Obx(() {
                                  _coursesController.wishlistedCoursesCount.value;
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(15)),
                                      color: Colors.white,
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.all(8),
                                      constraints: BoxConstraints(),
                                      icon: Icon(Icons.favorite,
                                          color: (_coursesController.isInWishlist(course)) ? Colors.red : Colors.grey),
                                      onPressed: () {
                                        _coursesController.changeWishlist(course);
                                        (context as Element).markNeedsBuild();
                                      },
                                    ),
                                  );
                                }),
                              ))
                        ],
                      )),
                  Expanded(
                      child: Padding(
                    padding: EdgeInsets.all(10.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(course.name, maxLines: 2, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp)),
                        SizedBox(
                          height: 6.h,
                        ),
                        const Spacer(),
                        if (course.rating != false) (buildRating(course.rating)),
                        SizedBox(
                          height: 6.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.people, color: Colors.grey),
                                SizedBox(
                                  width: 5.w,
                                ),
                                Text(
                                  course.count_students.toString(),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                SizedBox(
                                  width: 20.w,
                                ),
                                const Icon(Icons.menu_book, color: Colors.grey),
                                SizedBox(
                                  width: 5.w,
                                ),
                                Text(
                                  _coursesController.get_lessons_count(course).toString(),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            (course.price == 0)
                                ? Text("Free".tr, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold))
                                : Text(Constants.currency + course.price.toString(),
                                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                          ],
                        )
                      ],
                    ),
                  )),
                ]))));
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

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../Models/Courses.dart';
import '../../screens/curriculumPreview.dart';
import '../../utils/constants.dart';

class BuildGrid4 extends StatelessWidget {
  final Courses course;
  const BuildGrid4(this.course);
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
            height: 170.h,
            width: (ScreenUtil().orientation == Orientation.portrait) ? 200.w : 120.w,
            child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0.r),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.r),
                        topRight: Radius.circular(15.r),
                        bottomLeft: Radius.zero,
                        bottomRight: Radius.zero),
                    child: Hero(
                      tag: "image${course.id}",
                      child: ExtendedImage.network(
                        course.image,
                        height: 100.h,
                        width: 200.w,
                        fit: BoxFit.cover,
                        cache: true,
                      ),
                    ),
                  ),
                  Expanded(
                      child: Padding(
                    padding: EdgeInsets.all(10.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(course.name, maxLines: 2, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                        SizedBox(
                          height: 6.h,
                        ),
                        const Spacer(),
                        SizedBox(
                          height: 6.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (course.rating != false) buildRating(course.rating),
                            (course.price == 0)
                                ? Text("Free".tr, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold))
                                : Text(Constants.currency + course.price.toString(),
                                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
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

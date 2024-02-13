import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NoData {
  static Widget noData(String image, String text, {int imageHeight = 200}) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ExtendedImage.asset(
              "assets/" + image + ".png",
              height: imageHeight.toDouble().h,
            ),
            SizedBox(height: 15.h),
            Text(
              text,
              style: TextStyle(
                fontSize: 25.sp,
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

class card {
  static Widget shadow_card(Widget childWidget,
      {Color shadow_color = const Color(
        0xffE9E9E9,
      ),
      int ContainerBorderRadius = 10}) {
    return Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: shadow_color,
              blurRadius: 10.r,
            ),
          ],
        ),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ContainerBorderRadius.r),
          ),
          child: childWidget,
        ));
  }
}

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/constants.dart';

class theme_buttons {
  final Function onTap = () {};
  static Widget material_button(String name, num width,
      {onTap, var background_color, var textColor, is_circular = false}) {
    return SizedBox(
        width: Get.width * width,
        child: MaterialButton(
            color: (background_color == null) ? Constants.primary_color : background_color,
            textColor: (textColor == null) ? Colors.white : textColor,
            padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            onPressed: () async {
              onTap();
            },
            child: (is_circular)
                ? SizedBox(
                    height: 25.h,
                    width: 25.w,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3.w,
                    ),
                  )
                : Text(
                    name,
                    style: TextStyle(fontSize: 17.sp),
                  )));
  }

  static Widget text_button(String name, {onTap}) {
    return TextButton(
      onPressed: () async {
        onTap();
      },
      child: Text(name),
    );
  }

  static TagsButton(String Title, {onTap}) {
    return TextButton(
      style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0.r), side: const BorderSide(color: Colors.black)))),
      child: Text(
        Title,
        style: TextStyle(color: Colors.black, fontSize: 15.sp),
      ),
      onPressed: () {
        onTap();
      },
    );
  }

  static Widget outlined_button(String Title, {onTap}) {
    return OutlinedButton(
      onPressed: () {
        onTap();
      },
      style: OutlinedButton.styleFrom(
        side: BorderSide(width: 1.w, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.r)),
      ),
      child: Text(Title, style: TextStyle(color: Colors.white, fontSize: 16.sp)),
    );
  }
}

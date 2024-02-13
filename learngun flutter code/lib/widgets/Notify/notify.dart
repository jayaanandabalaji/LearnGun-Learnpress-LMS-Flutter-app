import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/constants.dart';

class notify {
  static show_snackbar(String Title, String Message) {
    Get.snackbar(
      Title,
      Message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Constants.primary_color,
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
      duration: const Duration(seconds: 3),
      margin: EdgeInsets.all(15.h),
      colorText: Colors.white,
      icon: const Icon(Icons.info, color: Colors.white),
    );
  }

  static showDialog(String Title, String Message, {var confirm_text, var cancel_text, var on_confirm}) {
    Get.defaultDialog(
        title: Title,
        middleText: Message,
        textConfirm: confirm_text,
        textCancel: cancel_text,
        cancelTextColor: Constants.primary_color,
        confirmTextColor: Colors.white,
        buttonColor: Constants.primary_color,
        onConfirm: () {
          on_confirm();
        });
  }

  static showLoadingDialog(String text) {
    Get.dialog(
      Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(20.r)),
              child: Container(
                color: Colors.white,
                height: 80.h,
                width: 300.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: Colors.black,
                    ),
                    SizedBox(
                      width: 30.w,
                    ),
                    Text(
                      text,
                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500),
                    )
                  ],
                ),
              )),
        ),
      ),
    );
  }
}

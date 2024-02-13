import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Models/Courses.dart';
import '../../Controllers/Previewcontroller.dart';
import '../../widgets/HtmlWidget.dart';
import 'VideoPlayers/EmbeddedVideo.dart';
import 'VideoPlayers/LocalVideo.dart';
import 'VideoPlayers/youtube.dart';

// ignore: must_be_immutable
class preview extends StatelessWidget {
  final previewController _previewController = Get.put(previewController());
  ItemsBean item;
  preview(this.item);
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        backgroundColor: _previewController.scaffoldColor,
        body: ListView(
          children: [
            Container(
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.expand_more,
                    size: 25,
                    color: (_previewController.scaffoldColor == Colors.white) ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ),
            if (_previewController.is_loading.value)
              Column(
                children: [
                  SizedBox(
                    height: Get.height * 0.4,
                  ),
                  const CircularProgressIndicator(
                    color: Colors.white,
                  )
                ],
              ),
            if (_previewController.content != "")
              Padding(
                padding: EdgeInsets.all(10.h),
                child: html_content.html_widget(_previewController.content),
              ),
            if (_previewController.youtube_video_id != "")
              Column(
                children: [
                  SizedBox(height: Get.height * 0.3),
                  SizedBox(
                    height: Get.height * 0.3,
                    child: youtube(_previewController.youtube_video_id),
                  )
                ],
              ),
            if (_previewController.mp4_video_url != "")
              Column(
                children: [
                  SizedBox(height: Get.height * 0.3),
                  SizedBox(
                    height: Get.height * 0.3,
                    child: localVideo(_previewController.mp4_video_url),
                  )
                ],
              ),
            if (_previewController.embedded_url != "")
              Column(
                children: [
                  SizedBox(height: Get.height * 0.3),
                  SizedBox(
                    height: Get.height * 0.3,
                    child: embeddedVideo(_previewController.embedded_url),
                  )
                ],
              )
          ],
        ),
      );
    });
  }
}

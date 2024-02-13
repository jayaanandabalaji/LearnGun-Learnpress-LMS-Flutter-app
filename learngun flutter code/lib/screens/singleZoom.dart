import 'dart:io';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zoom/zoom.dart'; //delete this line if zoom sdk is not needed

import '../services/BlogsAPI.dart';
import '../utils/constants.dart';
import '../widgets/Button.dart';
import '../widgets/HtmlWidget.dart';

class singleMeet extends StatefulWidget {
  final postId;
  const singleMeet(this.postId);

  @override
  State<singleMeet> createState() => _singleMeetState();
}

class _singleMeetState extends State<singleMeet> {
  var timer;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Zoom meeting".tr)),
        body: ListView(padding: EdgeInsets.all(20.w), children: [
          Center(
              child: FutureBuilder(
                  future: BlogsApi().GetMeeting(widget.postId),
                  builder: ((context, snapshot) {
                    if (snapshot.data != null) {
                      var blog = snapshot.data as dynamic;
                      return Center(
                          child: Card(
                              child: Container(
                                  width: Get.width * 0.9,
                                  padding: EdgeInsets.all(20.w),
                                  child: Column(children: [
                                    Text(blog.title.rendered,
                                        style: TextStyle(
                                            fontSize: 25.sp,
                                            color: Constants.primary_color,
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(height: 20.h),
                                    Row(
                                      children: [
                                        Text("Session date".tr+": ",
                                            style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                          DateFormat('EEEE, MMM dd, yyyy')
                                              .format(DateTime.parse(
                                                  blog.details["start_time"])),
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 20.h),
                                    Row(
                                      children: [
                                        Text("Session Time".tr+": ",
                                            style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                          DateFormat('jm').format(
                                              DateTime.parse(
                                                  blog.details["start_time"])),
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 20.h),
                                    Row(
                                      children: [
                                        Text("Session Duration".tr+": ",
                                            style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                          blog.details["duration"].toString() +
                                              " minutes",
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 20.h),
                                    Row(
                                      children: [
                                        Text("Host".tr+": ",
                                            style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                          blog.details["host_name"],
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500),
                                        )
                                      ],
                                    ),
                                    html_content
                                        .html_widget(blog.content.rendered),
                                    SizedBox(height: 10.h),
                                    theme_buttons.material_button(
                                      "Join Now".tr,
                                      0.7,
                                      onTap: () {
                                        joinMeeting(
                                            context,
                                            blog.details["id"].toString(),
                                            blog.details["password"]);
                                      },
                                    )
                                  ]))));
                    }
                    return CircularProgressIndicator();
                  })))
        ]));
  }

  joinMeeting(BuildContext context, String zoomId, String zoomPass) {
    //delete from this line to delete zoom sdk
    bool _isMeetingEnded(String status) {
      var result = false;

      if (Platform.isAndroid)
        result = status == "MEETING_STATUS_DISCONNECTING" ||
            status == "MEETING_STATUS_FAILED";
      else
        result = status == "MEETING_STATUS_IDLE";

      return result;
    }

    ZoomOptions zoomOptions = new ZoomOptions(
      domain: "zoom.us",
      appKey: Constants.zoomSdkKey, //API KEY FROM ZOOM - Sdk API Key
      appSecret:
          Constants.zoomSdkSecret, //API SECRET FROM ZOOM - Sdk API Secret
    );

    var meetingOptions = new ZoomMeetingOptions(
        userId: 'example',
        meetingId: zoomId,
        meetingPassword: zoomPass,
        disableDialIn: "true",
        disableDrive: "true",
        disableInvite: "true",
        disableShare: "true",
        noAudio: "false",
        noDisconnectAudio: "false",
        meetingViewOptions: ZoomMeetingOptions.NO_TEXT_PASSWORD +
            ZoomMeetingOptions.NO_TEXT_MEETING_ID +
            ZoomMeetingOptions.NO_BUTTON_PARTICIPANTS);
    var zoom = Zoom();
    zoom.init(zoomOptions).then((results) {
      if (results[0] == 0) {
        zoom.onMeetingStateChanged.listen((status) {
          if (_isMeetingEnded(status[0])) {
            timer?.cancel();
          }
        });
        zoom.joinMeeting(meetingOptions).then((joinMeetingResult) {
          timer = Timer.periodic(new Duration(seconds: 2), (timer) {
            zoom.meetingStatus(meetingOptions.meetingId).then((status) {});
          });
        });
      }
    });
    //delete upto this line
  }
}

import 'dart:async';
import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:zoom/zoom.dart'; //delete this line if zoom sdk is not needed
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:share_plus/share_plus.dart';

import '../Models/Blogs.dart';
import '../utils/constants.dart';
import '../widgets/Button.dart';
import '../widgets/HtmlWidget.dart';

class singleWebinar extends StatefulWidget {
  final blogs blog;

  const singleWebinar({required this.blog});

  @override
  State<singleWebinar> createState() => _singleWebinarState();
}

class _singleWebinarState extends State<singleWebinar> {
  var unescape = HtmlUnescape();
  var timer;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                Share.share(widget.blog.link);
              },
              icon: Icon(Icons.share),
            )
          ],
        ),
        body: Column(
          children: [
            Container(
                height: Get.height * 0.78,
                child: ListView(
                  padding: EdgeInsets.all(20.w),
                  children: [
                    Text(
                      unescape.convert(widget.blog.title.rendered),
                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    (widget.blog.embedded["wp:featuredmedia"] != null)
                        ? ExtendedImage.network(widget.blog.embedded["wp:featuredmedia"][0]["source_url"],
                            fit: BoxFit.cover)
                        : ExtendedImage.asset("assets/placeholder.jpg", fit: BoxFit.cover),
                    SizedBox(
                      height: 15.h,
                    ),
                    Text("About webinar".tr, style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold)),
                    SizedBox(
                      height: 10.h,
                    ),
                    Container(
                      padding: EdgeInsets.all(20.w),
                      color: Color(0xffDEDEDE),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.date_range),
                                SizedBox(
                                  width: 10.w,
                                ),
                                Text(DateFormat('EEEE, MMM dd, yyyy')
                                        .format(DateTime.parse(widget.blog.details["start_time"])) +
                                    " " +
                                    DateFormat('jm').format(DateTime.parse(widget.blog.details["start_time"])))
                              ],
                            ),
                            SizedBox(height: 15.h),
                            Row(
                              children: [
                                Icon(Icons.access_time),
                                SizedBox(
                                  width: 10.w,
                                ),
                                Text(widget.blog.details["duration"].toString() + " minutes")
                              ],
                            ),
                            SizedBox(height: 15.h),
                            Row(
                              children: [
                                SizedBox(
                                  width: 10.w,
                                ),
                                Text(
                                  "Host".tr+" : " + widget.blog.details["host_name"],
                                  style: TextStyle(
                                      color: Constants.primary_color, fontWeight: FontWeight.bold, fontSize: 17.sp),
                                )
                              ],
                            ),
                          ]),
                    ),
                    html_content.html_widget(widget.blog.content.rendered),
                  ],
                )),
            Expanded(
              child: Center(
                child: theme_buttons.material_button("Join webinar".tr, 0.8, onTap: () {
                  joinMeeting(context, widget.blog.details["id"].toString(), widget.blog.details["password"]);
                }),
              ),
            )
          ],
        ));
  }

  joinMeeting(BuildContext context, String zoomId, String zoomPass) {
    //delete from this line to delete zoom sdk
    bool _isMeetingEnded(String status) {
      var result = false;

      if (Platform.isAndroid)
        result = status == "MEETING_STATUS_DISCONNECTING" || status == "MEETING_STATUS_FAILED";
      else
        result = status == "MEETING_STATUS_IDLE";

      return result;
    }

    ZoomOptions zoomOptions = new ZoomOptions(
      domain: "zoom.us",
      appKey: Constants.zoomSdkKey, //API KEY FROM ZOOM - Sdk API Key
      appSecret: Constants.zoomSdkSecret, //API SECRET FROM ZOOM - Sdk API Secret
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
            zoom.meetingStatus(meetingOptions.meetingId).then((status) {
            });
          });
        });
      }
    });
    //delete upto this line
  }
}

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:LearnGun/screens/H5Plesson.dart';
import 'package:android_path_provider/android_path_provider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:get/get.dart';

import '../../widgets/Button.dart';
import '../Controllers/MyCoursesController.dart';
import '../Models/Courses.dart';
import '../screens/completeLesson.dart';
import '../screens/singleZoom.dart';
import '../screens/takeCourse.dart';
import '../services/LessonsAPI.dart';
import '../services/CoursesAPI.dart';
import '../widgets/Notify/notify.dart';
import '../services/QuizAPI.dart';
import '../widgets/pdfViewer.dart';
import 'QuizController.dart';
import '../services/SharedPrefs.dart';
import '../utils/constants.dart';

class TakeCourseController extends GetxController {
  var current_lesson = [0, ""].obs;
  var top_bar_loading = false.obs;
  var youtube_video_id = "".obs;
  var mp4_video_url = "".obs;
  var embedded_url = "".obs;
  var audio_mp3_url = "".obs;
  var pdf_url = "".obs;
  var courseName = "";
  var lesson_content = "";
  var completed_lessons = [].obs;
  var is_quiz = false.obs;
  var is_h5p = false.obs;
  var QuizResponse;
  var certLoaded = false;
  var zoomId = "".obs;
  var h5pID = "".obs;
  String certImage = "";
  final MyCoursesController _myCoursesController =
      Get.put(MyCoursesController());
  final Quizcontroller _quizcontroller = Get.put(Quizcontroller());
  openLesson(var Lesson,
      {bool OpenScreen = true, bool isOffline = false}) async {
    current_lesson.value = [Lesson[0], Lesson[1]];
    youtube_video_id.value = "";
    mp4_video_url.value = "";
    embedded_url.value = "";
    audio_mp3_url.value = "";
    pdf_url.value = "";
    lesson_content = "";
    top_bar_loading.value = true;
    zoomId.value = "";
    h5pID.value = "";
    if (is_quiz.value) {
      QuizResponse = await QuizApi.GetQuiz(current_lesson[0] as dynamic);
      if (!mapEquals(
          (QuizResponse.runtimeType.toString() == "FetchQuiz")
              ? {"quiz": 0}
              : QuizResponse,
          {})) {
        if (OpenScreen) {
          _quizcontroller.openQuiz(QuizResponse);
        }
      } else {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
            SnackBar(content: Text("Quiz can't be taken offline".tr)));
      }
    } else if (is_h5p.value) {
      var response = await LessonsApi.GetH5P(Lesson[0]);
      if (!completed_lessons.contains(current_lesson[0]) && OpenScreen) {
        complete_lesson(current_lesson[0] as dynamic);
      }
      Get.to(H5Plesson(response[0], current_lesson[1]));
    } else {
      var response = await LessonsApi.GetLesson(Lesson[0]);
      if (!mapEquals(response, {})) {
        lesson_content = response["content"];
        if (!await is_video(response["content"]) &&
            !await is_audio(response["content"]) &&
            !await isZoom(response["content"]) &&
            !await isH5P(response["content"]) &&
            !await isPDF(response["content"], isOffline)) {
          if (OpenScreen) {
            open_article();
          }
        }
        if (!completed_lessons.contains(current_lesson[0]) && OpenScreen) {
          complete_lesson(response["id"]);
        }
      } else {
        ScaffoldMessenger.of(Get.context!)
            .showSnackBar(SnackBar(content: Text("Lesson not downloaded".tr)));
      }
    }
    top_bar_loading.value = false;
  }

  isH5P(var content) async {
    if (content.contains("h5p id")) {
      h5pID.value = content
          .replaceAll(new RegExp(r'[^0-9]'), '')
          .substring(1, content.replaceAll(new RegExp(r'[^0-9]'), '').length);
      Get.to(H5Plesson(h5pID.value, current_lesson[1]));
      return true;
    }
    return false;
  }

  isZoom(var content) async {
    if (content.contains("zoom_meeting_post")) {
      zoomId.value = content.replaceAll(new RegExp(r'[^0-9]'), '');

      Get.to(singleMeet(zoomId.value));
      return true;
    }
    return false;
  }

  isPDF(var content, bool IsOffline) async {
    List<dynamic> links = await _urlinString(content);
    for (String link in links) {
      if (link.contains(".pdf")) {
        pdf_url.value = link;
        Get.to(PdfViewer(
          (IsOffline) ? current_lesson[0] : pdf_url.value,
          courseName,
          IsOffline: IsOffline,
        ));
        return true;
      }
    }
    return false;
  }

  is_audio(var content) async {
    List<dynamic> links = await _urlinString(content);
    for (String link in links) {
      if (link.contains(".mp3")) {
        audio_mp3_url.value = link;
        return true;
      }
    }
    return false;
  }

  is_video(var content) async {
    List<dynamic> links = await _urlinString(content);
    for (String link in links) {
      if (await is_youtube_video(link)) {
        return true;
      }
      if (await is_mp4_video(link)) {
        return true;
      }
      if (await is_embedded(link)) {
        return true;
      }
    }
    return false;
  }

  is_embedded(String link) async {
    if (link.contains("https://iframe.mediadelivery.net")) {
      embedded_url.value = link;
      return true;
    }
    return false;
  }

  is_mp4_video(String link) async {
    if (link.contains(".mp4")) {
      mp4_video_url.value = link;
      return true;
    } else {
      return false;
    }
  }

  is_youtube_video(String link) async {
    try {
      youtube_video_id.value = YoutubePlayer.convertUrlToId(link)!;
      return true;
    } catch (e) {
      return false;
    }
  }

  _urlinString(String htmlString) {
    List tempReturnList = [];
    final text = htmlString;
    RegExp exp = RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
    Iterable<RegExpMatch> matches = exp.allMatches(text);
    for (var match in matches) {
      tempReturnList.add(text.substring(match.start, match.end));
    }
    return tempReturnList;
  }

  open_take_course(Courses course, {bool isOffline = false}) {
    lesson_content = "";
    current_lesson.value = [0, ""];
    top_bar_loading.value = false;
    youtube_video_id.value = "";
    mp4_video_url.value = "";
    embedded_url.value = "";
    audio_mp3_url.value = "";
    pdf_url.value = "";
    zoomId.value = "";
    h5pID.value = "";
    completed_lessons.value = [];
    is_quiz.value = false;
    is_h5p.value = false;
    courseName = course.name;
    sectionsloop:
    for (var sections in course.sections) {
      for (var item in sections.items) {
        if (item.status != "completed") {
          current_lesson.value = [item.id, item.title];
          if (item.type == "lp_quiz") {
            is_quiz.value = true;
          }
          if (item.type == "lp_h5p") {
            is_h5p.value = true;
          }
          break sectionsloop;
        }
      }
    }
    for (var sections in course.sections) {
      for (var item in sections.items) {
        if (item.status == "completed") {
          completed_lessons.add(item.id);
        }
      }
    }
    Get.to(TakeCourseScreen(
      Course: course,
      IsOffline: isOffline,
    ));
    if (current_lesson[0] != 0) {
      openLesson(current_lesson, OpenScreen: false);
    }
  }

  get_item_number(var item, Courses course) {
    int count = 0;
    for (var sections in course.sections) {
      for (var singleItem in sections.items) {
        count++;
        if (singleItem.id == item.id) {
          return count;
        }
      }
    }
  }

  open_article() {
    Get.to(() => completelesson(
          Lessoncontent: lesson_content,
        ));
    if (!completed_lessons.contains(current_lesson[0])) {
      complete_lesson(current_lesson[0] as dynamic);
    }
  }

  complete_lesson(int lessonId) async {
    completed_lessons.add(lessonId);
    await LessonsApi.CompleteLesson(lessonId);
  }

  complete_course(int courseId, var course, BuildContext context) async {
    notify.showLoadingDialog("Trying to complete".tr);
    var response = await CoursesApi.completeCourse(courseId);
    Get.back();
    if (response["status"] == "error") {
      notify.show_snackbar("Failed to complete", response["message"]);
    } else {
      notify.show_snackbar("Completed successfully", response["message"]);
      _myCoursesController.refreshMyCourses();
      certLoaded = false;
      certImage = "";
      if (course.certificate != "") {
        await OpenCertificateDialog(course, context);
        Navigator.pop(context);
      } else {
        await Future.delayed(const Duration(seconds: 2));
        Navigator.pop(context);
      }
    }
  }

  OpenCertificateDialog(var course, var context) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(child: StatefulBuilder(
              builder: (context, setstate) {
                return Container(
                    height: 300.h,
                    width: 300.w,
                    child: FutureBuilder(
                      future: GetImageUrl(course),
                      builder: (context, snapshot) {
                        if (snapshot.data != null) {
                          return Column(
                            children: [
                              Container(
                                  height: 210.h,
                                  width: 300.w,
                                  child: (!certLoaded)
                                      ? Stack(
                                          children: [
                                            InAppWebView(
                                              initialOptions:
                                                  InAppWebViewGroupOptions(
                                                      crossPlatform:
                                                          InAppWebViewOptions(
                                                              cacheEnabled:
                                                                  false,
                                                              clearCache:
                                                                  true)),
                                              initialUrlRequest: URLRequest(
                                                  url: Uri.parse(snapshot.data
                                                      as dynamic)),
                                              onConsoleMessage:
                                                  (InAppWebViewController
                                                          controller,
                                                      ConsoleMessage
                                                          consoleMessage) {
                                                if (consoleMessage.message
                                                    .contains("data:image")) {
                                                  setstate(() {
                                                    certLoaded = true;
                                                    certImage =
                                                        consoleMessage.message;
                                                  });
                                                }
                                              },
                                            ),
                                            Center(
                                                child:
                                                    CircularProgressIndicator())
                                          ],
                                        )
                                      : ExtendedImage.memory(base64Decode(
                                          certImage.replaceAll(
                                              "data:image/png;base64,", "")))),
                              if (certLoaded)
                                Expanded(
                                  child: Center(
                                      child: theme_buttons.material_button(
                                          "Download".tr, 0.5, onTap: () async {
                                    await [
                                      Permission.storage,
                                    ].request();
                                    Uint8List bytes = base64.decode(
                                        certImage.replaceAll(
                                            "data:image/png;base64,", ""));
                                    var downloadsPath = "";
                                    if (Platform.isAndroid) {
                                      downloadsPath = await AndroidPathProvider
                                          .downloadsPath;
                                    } else {
                                      downloadsPath =
                                          (await getApplicationDocumentsDirectory())
                                              .path;
                                    }
                                    File file = File("$downloadsPath/" +
                                        DateTime.now()
                                            .millisecondsSinceEpoch
                                            .toString() +
                                        ".png");
                                    await file.writeAsBytes(bytes);
                                    Navigator.pop(context);
                                    notify.show_snackbar(
                                        "Downloaded successfully", "");
                                  })),
                                )
                            ],
                          );
                        }
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ));
              },
            )));
  }

  Future GetImageUrl(var course) async {
    var user_id = await prefs.getString('user_info_id');

    return Constants.base_url +
        "/wp-content/plugins/learnpress%20app%20options/includes/certificate.php?course=" +
        course.id.toString() +
        "&user=" +
        user_id +
        "&license=" +
        Constants.purchase_code;
  }
}

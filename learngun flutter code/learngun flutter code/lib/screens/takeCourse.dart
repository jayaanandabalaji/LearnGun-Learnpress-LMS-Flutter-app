import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'H5Plesson.dart';
import 'singleZoom.dart';
import '../services/LessonsAPI.dart';
import '../../services/SharedPrefs.dart';
import '../../widgets/VideoPlayers/LocalVideo.dart';
import '../../widgets/VideoPlayers/youtube.dart';
import '../../Controllers/TakeCourseController.dart';
import '../../utils/constants.dart';
import '../../widgets/Button.dart';
import '../../widgets/VideoPlayers/EmbeddedVideo.dart';
import '../../Models/Courses.dart';
import '../Controllers/QuizController.dart';
import '../services/CoursesAPI.dart';
import '../widgets/pdfViewer.dart';

class TakeCourseScreen extends StatefulWidget {
  final Courses Course;
  final IsOffline;
  static const routeName = '/curriculum';
  const TakeCourseScreen(
      {Key? key, required this.Course, this.IsOffline = false})
      : super(key: key);
  @override
  _TakeCourseScreenState createState() => _TakeCourseScreenState();
}

class _TakeCourseScreenState extends State<TakeCourseScreen>
    with TickerProviderStateMixin {
  AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = true;
  late AnimationController _animationController;
  bool playAudio = true;
  var audioBuffering = false.obs;
  var audioDuration = 0.obs;
  var currentDuration = 0.obs;
  var downloadedLessons = {}.obs;
  var downloadingIconMode = {}.obs;
  var downloadingItems = {};
  var downloadProgress = {}.obs;
  CancelToken cancelToken = CancelToken();

  final TakeCourseController _takeCourseController =
      Get.put(TakeCourseController());
  final Quizcontroller _quizcontroller = Get.put(Quizcontroller());
  final ReviewFormKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  var AddReviewButtonLoading = false.obs;
  var NotRatedErrorVisible = false.obs;
  int currentRating = 0;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    cancelToken.cancel();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: WillPopScope(
            onWillPop: () {
              Get.back();
              return Future.value(true);
            },
            child: Scaffold(
                body: DefaultTabController(
                    length: 2,
                    child: Column(children: [
                      GestureDetector(
                          child: Row(children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios,
                                  color: Colors.black, size: 20),
                              onPressed: () {
                                Get.back();
                              },
                            ),
                            const Text("My Courses",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ]),
                          onTap: () {
                            Get.back();
                          }),
                      Expanded(
                        child: top_widget(),
                      ),
                      OrientationBuilder(builder: (context, orientation) {
                        if (MediaQuery.of(context).orientation ==
                            Orientation.portrait) {
                          return SizedBox(
                            height: Get.height * 0.6,
                            child: NestedScrollView(
                              headerSliverBuilder: (BuildContext context,
                                  bool innerBoxIsScrolled) {
                                return [
                                  SliverToBoxAdapter(
                                    child: give_padding(Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          child: Text(
                                            widget.Course.name,
                                            style: TextStyle(fontSize: 23.sp),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5.h,
                                        ),
                                        Text(widget.Course.instructor.name,
                                            style: TextStyle(
                                                fontSize: 18.sp,
                                                color: Colors.grey))
                                      ],
                                    )),
                                  ),
                                  MediaQuery.removePadding(
                                      context: context,
                                      removeTop: true,
                                      child: SliverAppBar(
                                          elevation: 0,
                                          automaticallyImplyLeading: false,
                                          titleSpacing: 0,
                                          backgroundColor: Colors.white,
                                          pinned: true,
                                          title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              TabBar(
                                                indicatorColor: Colors.black,
                                                isScrollable: true,
                                                indicator:
                                                    UnderlineTabIndicator(
                                                  borderSide:
                                                      BorderSide(width: 1.w),
                                                ),
                                                tabs: [
                                                  Tab(
                                                      child: Text(
                                                    "Lectures".tr,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16.sp),
                                                  )),
                                                  Tab(
                                                      child: Text(
                                                    "More".tr,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16.sp),
                                                  )),
                                                ],
                                              ),
                                              Obx(() {
                                                downloadedLessons;
                                                return IconButton(
                                                  icon: (IsAllCoursesDownloaded(
                                                          widget.Course))
                                                      ? Icon(
                                                          Icons
                                                              .download_for_offline,
                                                          color: Constants
                                                              .primary_color,
                                                        )
                                                      : const Icon(
                                                          Icons
                                                              .download_for_offline_outlined,
                                                          color: Colors.black),
                                                  onPressed: () async {
                                                    if (IsAllCoursesDownloaded(
                                                        widget.Course)) {
                                                      AlertDialog alert =
                                                          AlertDialog(
                                                        title: Text(
                                                            "Delete downloaded course"
                                                                .tr),
                                                        content: Text(
                                                            "Are you sure, do you want to delete all lessons in this course?"
                                                                .tr),
                                                        actions: [
                                                          TextButton(
                                                            child:
                                                                Text("No".tr),
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                          ),
                                                          TextButton(
                                                            child:
                                                                Text("Yes".tr),
                                                            onPressed:
                                                                () async {
                                                              for (var sections
                                                                  in widget
                                                                      .Course
                                                                      .sections) {
                                                                for (var item
                                                                    in sections
                                                                        .items) {
                                                                  if (item.type !=
                                                                      "lp_quiz") {
                                                                    await DeleteLesson(
                                                                        item);
                                                                  }
                                                                }
                                                              }
                                                              Navigator.pop(
                                                                  context);
                                                              ScaffoldMessenger
                                                                      .of(
                                                                          context)
                                                                  .showSnackBar(SnackBar(
                                                                      content: Text(
                                                                          "Deleted successfully".tr +
                                                                              "!!!")));
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return alert;
                                                        },
                                                      );
                                                    } else {
                                                      for (var section in widget
                                                          .Course.sections) {
                                                        for (var item
                                                            in section.items) {
                                                          if (item.type !=
                                                              "lp_quiz") {
                                                            if (!downloadedLessons[
                                                                item.id]) {
                                                              Downloadlesson(
                                                                  item);
                                                            }
                                                          }
                                                        }
                                                      }
                                                    }
                                                  },
                                                );
                                              })
                                            ],
                                          ))),
                                ];
                              },
                              body: TabBarView(
                                children: [
                                  SingleChildScrollView(
                                      child: build_curriculum()),
                                  SingleChildScrollView(
                                      child: Column(
                                    children: [
                                      if (widget.Course.rating != false)
                                        more_menu("Write a review".tr,
                                            Icons.rate_review_outlined, () {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) =>
                                                  writeReviewDialog());
                                        }),
                                      more_menu("Complete this course".tr,
                                          Icons.keyboard_control_outlined, () {
                                        _takeCourseController.complete_course(
                                            widget.Course.id as dynamic,
                                            widget.Course,
                                            context);
                                      }),
                                      more_menu(
                                          "Share this course".tr, Icons.share,
                                          () {
                                        Share.share(widget.Course.permalink);
                                      }),
                                    ],
                                  )),
                                ],
                              ),
                            ),
                          );
                        }
                        return Container();
                      }),
                    ])))));
  }

  Widget writeReviewDialog() {
    return Dialog(
      child: Container(
        height: 400.h,
        width: 300.w,
        padding: EdgeInsets.all(20.h),
        child: Form(
          key: ReviewFormKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Write a review".tr,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 5.h),
              TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter some text'.tr;
                    }
                    return null;
                  },
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'.tr)),
              SizedBox(height: 5.h),
              TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter some text'.tr;
                  }
                  return null;
                },
                controller: contentController,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(labelText: 'Content'.tr),
                maxLines: 10,
                minLines: 2,
              ),
              SizedBox(height: 10.h),
              Text("Rating".tr, style: TextStyle(fontSize: 16.sp)),
              SizedBox(height: 5.h),
              RatingBar.builder(
                initialRating: currentRating.toDouble(),
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 2.5),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  NotRatedErrorVisible.value = false;
                  currentRating = rating.toInt();
                },
              ),
              Obx(() {
                return Visibility(
                    visible: NotRatedErrorVisible.value,
                    child: Text("Please select a rating".tr,
                        style: const TextStyle(color: Colors.red)));
              }),
              SizedBox(height: 10.h),
              Obx(() {
                if (AddReviewButtonLoading.value) {
                  return theme_buttons.material_button("", 0.6,
                      is_circular: true);
                }
                return theme_buttons.material_button("Add review".tr, 0.6,
                    onTap: () async {
                  if (currentRating == 0) {
                    NotRatedErrorVisible.value = true;
                  }
                  if (ReviewFormKey.currentState!.validate() &&
                      currentRating > 0) {
                    AddReviewButtonLoading.value = true;
                    var response = await CoursesApi.addCourseReview(
                        widget.Course.id as dynamic,
                        currentRating,
                        titleController.text,
                        contentController.text);
                    AddReviewButtonLoading.value = false;
                    Get.back();
                    if (response["comment"] != 0) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Review submitted for moderation".tr)));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "You have already reviewed this course.".tr)));
                    }
                  }
                });
              })
            ],
          ),
        ),
      ),
    );
  }

  Widget more_menu(String title, var icon, Function OnTap) {
    return InkWell(
      onTap: () {
        OnTap();
      },
      child: Container(
          padding: EdgeInsets.fromLTRB(15.w, 10.h, 10.w, 10.h),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.black,
              ),
              SizedBox(
                width: 20.w,
              ),
              Text(title,
                  style: TextStyle(color: Colors.black, fontSize: 18.sp))
            ],
          )),
    );
  }

  Widget give_padding(Widget childWidget) {
    return Padding(
      padding: EdgeInsets.fromLTRB(15.w, 5.h, 15.w, 5.h),
      child: childWidget,
    );
  }

  IsAllSectionsDownloaded(SectionBean sections) {
    for (var item in sections.items) {
      if (item.type != "lp_quiz") {
        if (downloadedLessons[item.id] == null ||
            downloadedLessons[item.id] == false) {
          return false;
        }
      }
    }
    return true;
  }

  IsAllCoursesDownloaded(Courses course) {
    for (var sections in course.sections) {
      for (var item in sections.items) {
        if (item.type != "lp_quiz") {
          if (downloadedLessons[item.id] == null ||
              downloadedLessons[item.id] == false) {
            return false;
          }
        }
      }
    }
    return true;
  }

  Widget build_curriculum() {
    return Column(
      children: [
        for (var section in widget.Course.sections)
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              give_padding(Text(
                section.title +
                    ((section.description != "") ? " - " : "") +
                    section.description,
                maxLines: 2,
                style: TextStyle(
                    color: const Color(0xff3E3E3E),
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp),
              )),
              SizedBox(
                height: 7.h,
              ),
              give_padding(Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                      height: 8.h,
                      width: 100.w,
                      child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(10.r)),
                          child: LinearProgressIndicator(
                            value: (section.percent / 100).toDouble(),
                          ))),
                  Obx(() {
                    downloadedLessons;

                    return IconButton(
                      icon: (IsAllSectionsDownloaded(section))
                          ? Icon(
                              Icons.download_for_offline,
                              color: Constants.primary_color,
                            )
                          : const Icon(Icons.download_for_offline_outlined,
                              color: Colors.black),
                      onPressed: () async {
                        if (IsAllSectionsDownloaded(section)) {
                          AlertDialog alert = AlertDialog(
                            title: Text("Delete Lessons".tr),
                            content: Text(
                                "Are you sure, do you want to delete all lessons in this section?"
                                    .tr),
                            actions: [
                              TextButton(
                                child: Text("No".tr),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              TextButton(
                                child: Text("Yes".tr),
                                onPressed: () async {
                                  for (var item in section.items) {
                                    await DeleteLesson(item);
                                  }
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Deleted successfully".tr +
                                                  "!!!")));
                                },
                              ),
                            ],
                          );
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return alert;
                            },
                          );
                        } else {
                          for (var item in section.items) {
                            if (!downloadedLessons[item.id]) {
                              Downloadlesson(item);
                            }
                          }
                        }
                      },
                    );
                  })
                ],
              )),
              SizedBox(
                height: 10.h,
              ),
              for (var item in section.items)
                Obx(() {
                  return build_items(item);
                }),
              SizedBox(
                height: 10.h,
              ),
            ],
          )
      ],
    );
  }

  Widget build_items(ItemsBean item) {
    bool isCurrentLesson = (_takeCourseController.current_lesson[0] == item.id);
    return GestureDetector(
      onTap: () async {
        if (item.type == "lp_quiz") {
          _takeCourseController.is_quiz.value = true;
          _takeCourseController.is_h5p.value = false;
        } else if (item.type == "lp_h5p") {
          _takeCourseController.is_h5p.value = true;
          _takeCourseController.is_quiz.value = false;
        } else {
          _takeCourseController.is_quiz.value = false;
          _takeCourseController.is_h5p.value = false;
        }
        if (!playAudio) {
          audioPlayer.stop();
          playAudio = true;
          isPlaying = false;
          audioDuration.value = 0;
        }
        await _takeCourseController
            .openLesson([item.id, item.title], isOffline: widget.IsOffline);
        setState(() {});
      },
      child: Container(
          color: (isCurrentLesson)
              ? Constants.primary_color.withOpacity(0.05)
              : Colors.white,
          child: give_padding(Row(
            children: [
              Text(
                  _takeCourseController
                      .get_item_number(item, widget.Course)
                      .toString(),
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: (isCurrentLesson)
                          ? FontWeight.bold
                          : FontWeight.w500)),
              SizedBox(width: 20.w),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      width: Get.width * 0.58,
                      child: Text(
                        item.title,
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: (isCurrentLesson)
                                ? FontWeight.bold
                                : FontWeight.w500),
                        maxLines: 5,
                      )),
                  SizedBox(height: 5.h),
                  Row(
                    children: [
                      Text(
                        get_type_text(item.type),
                        style: const TextStyle(color: Colors.grey),
                        textAlign: TextAlign.start,
                      ),
                      (item.duration != "")
                          ? Text(" - " + item.duration,
                              style: const TextStyle(color: Colors.grey))
                          : Container()
                    ],
                  )
                ],
              ),
              const Spacer(),
              if (item.type != "lp_quiz")
                FutureBuilder(
                  future: isDownloaded(item.id),
                  builder: (context, snapshot) {
                    if (snapshot.data != null) {
                      if (snapshot.data == true &&
                          // ignore: invalid_use_of_protected_member
                          downloadedLessons.value[item.id] == null) {
                        // ignore: invalid_use_of_protected_member
                        downloadedLessons.value[item.id] = true;
                      }
                      if (snapshot.data == false &&
                          // ignore: invalid_use_of_protected_member
                          downloadedLessons.value[item.id] == null) {
                        // ignore: invalid_use_of_protected_member
                        downloadedLessons.value[item.id] = false;
                      }
                      if (item.id == getLastItemCount(widget.Course)) {
                        Future.delayed(Duration.zero, () {
                          downloadedLessons.refresh();
                        });
                      }
                      return Obx(() {
                        if (downloadedLessons[item.id] == false) {
                          if (downloadingIconMode[item.id] == 1 &&
                              (downloadingItems[item.id] == true)) {
                            return Stack(children: [
                              if (downloadProgress[item.id] != null &&
                                  downloadProgress[item.id] != 0)
                                CircularProgressIndicator(
                                    value: downloadProgress[item.id] / 100),
                              Center(
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.square),
                                  onPressed: () async {
                                    Downloadlesson(item);
                                  },
                                ),
                              )
                            ]);
                          } else {
                            return IconButton(
                                icon: const Icon(
                                  Icons.download_for_offline_outlined,
                                  color: Colors.black,
                                ),
                                onPressed: () async {
                                  Downloadlesson(item);
                                });
                          }
                        }
                        if (downloadedLessons[item.id] == true) {
                          return downloadedButton(item);
                        }
                        return Container();
                      });
                    }
                    return Container();
                  },
                ),
              SizedBox(width: 15.w),
              (_takeCourseController.completed_lessons.contains(item.id))
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.green,
                      size: 26,
                    )
                  : const Icon(Icons.check_rounded,
                      color: Colors.grey, size: 26)
            ],
          ))),
    );
  }

  static getLastItemCount(Courses course) {
    int LastItemId = 0;
    for (var sections in course.sections) {
      for (var item in sections.items) {
        if (item.type == "lp_lesson") {
          LastItemId = item.id.toInt();
        }
      }
    }
    return LastItemId;
  }

  static get_type_text(var type) {
    if (type == "lp_quiz") {
      return "Quiz".tr;
    }
    if (type == "lp_lesson") {
      return "Lesson".tr;
    }
    if (type == "lp_h5p") {
      return "H5P".tr;
    }
  }

  Future playaudio(String url) async {
    audioDuration.value = 0;
    Duration? duration;
    if (widget.IsOffline) {
      var response = (await prefs.getJson(Constants.base_url +
          "/wp-json/learnpress/v1/lessons/" +
          _takeCourseController.current_lesson[0].toString()));
      Directory? appDocDir = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();
      String path = appDocDir!.path +
          "/" +
          ((await get_audio(response["content"])).split('?')[0].split('#')[0])
              .split('/')
              .last;
      duration = await audioPlayer.setFilePath(path);
    } else {
      duration =
          await audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(url)));
    }
    audioDuration.value = duration!.inSeconds;
    audioBuffering.value = false;
    await audioPlayer.play();
  }

  Widget top_widget() {
    return Obx(() {
      if (_takeCourseController.top_bar_loading.value == true) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      if (_takeCourseController.youtube_video_id.value != "") {
        return youtube(_takeCourseController.youtube_video_id.value);
      }
      if (_takeCourseController.mp4_video_url.value != "") {
        return localVideo(
            (widget.IsOffline)
                ? _takeCourseController.current_lesson[0]
                : _takeCourseController.mp4_video_url.value,
            isOffline: widget.IsOffline);
      }
      if (_takeCourseController.embedded_url.value != "") {
        return embeddedVideo(_takeCourseController.embedded_url.value);
      }
      if (_takeCourseController.audio_mp3_url.value != "") {
        if (playAudio) {
          audioBuffering.value = true;
          playaudio(_takeCourseController.audio_mp3_url.value);
          _animationController.reverse();
          isPlaying = true;
          playAudio = false;
        }
        audioPlayer.positionStream.listen((duration) {
          currentDuration.value = duration.inSeconds;
        });
        return audioController();
      }

      if (_takeCourseController.current_lesson[0] != 0) {
        return Stack(
          children: [
            ExtendedImage.network(
              widget.Course.image,
              height: Get.height * 0.3,
              fit: BoxFit.cover,
              width: Get.width,
            ),
            Container(
              color: Colors.black.withOpacity(0.4),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.all(10.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    (_takeCourseController.is_quiz.value)
                        ? theme_buttons.outlined_button("Start Quiz".tr,
                            onTap: () {
                            _quizcontroller
                                .openQuiz(_takeCourseController.QuizResponse);
                          })
                        : (_takeCourseController.pdf_url.value != "")
                            ? theme_buttons.outlined_button("Open Pdf".tr,
                                onTap: () {
                                Get.to(PdfViewer(
                                    _takeCourseController.pdf_url.value,
                                    widget.Course.name));
                              })
                            : (_takeCourseController.zoomId.value != "")
                                ? theme_buttons.outlined_button(
                                    "Open Zoom meeting".tr, onTap: () {
                                    Get.to(singleMeet(
                                        _takeCourseController.zoomId.value));
                                  })
                                : (_takeCourseController.h5pID.value != "" ||
                                        _takeCourseController.is_h5p.value)
                                    ? theme_buttons.outlined_button(
                                        "Open H5P lesson".tr, onTap: () {
                                        Get.to(H5Plesson(
                                            _takeCourseController.h5pID.value,
                                            _takeCourseController
                                                .current_lesson[1]));
                                      })
                                    : theme_buttons.outlined_button(
                                        "Open document".tr, onTap: () {
                                        _takeCourseController.open_article();
                                      }),
                    SizedBox(
                      height: 5.h,
                    ),
                    Text(
                      (_takeCourseController.current_lesson as dynamic)[1],
                      style: TextStyle(color: Colors.white, fontSize: 20.sp),
                    ),
                  ],
                ),
              ),
            )
          ],
        );
      }
      return ExtendedImage.network(
        widget.Course.image,
        height: Get.height * 0.3,
        fit: BoxFit.cover,
        width: Get.width,
      );
    });
  }

  Widget audioController() {
    return Stack(
      children: [
        Container(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Obx(() {
              return Container(
                  padding: EdgeInsets.symmetric(horizontal: 30.w),
                  child: Column(
                    children: [
                      SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            overlayShape: SliderComponentShape.noOverlay,
                            trackShape: CustomTrackShape(),
                          ),
                          child: Slider(
                            value: (audioDuration.value > 0)
                                ? currentDuration.value.toDouble()
                                : 0,
                            max: audioDuration.value.toDouble(),
                            onChangeEnd: (double value) async {
                              audioBuffering.value = true;
                              await audioPlayer
                                  .seek(Duration(seconds: value.toInt()));
                              _animationController.reverse();
                              audioPlayer.play();
                              audioBuffering.value = false;
                              currentDuration.value = value.toInt();
                            },
                            onChanged: (double value) {
                              if (value != currentDuration.value) {
                                audioPlayer.pause();
                                currentDuration.value = value.toInt();
                              }
                            },
                          )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text((currentDuration.value ~/ 60)
                                  .toString()
                                  .padLeft(2, '0') +
                              ":" +
                              (currentDuration.value % 60)
                                  .toString()
                                  .padLeft(2, '0')),
                          if (audioDuration.value != 0)
                            Text((audioDuration.value ~/ 60)
                                    .toString()
                                    .padLeft(2, '0') +
                                ":" +
                                (audioDuration.value % 60)
                                    .toString()
                                    .padLeft(2, '0')),
                          if (audioDuration.value == 0) const Text("---")
                        ],
                      ),
                    ],
                  ));
            }),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    if (isPlaying) {
                      audioPlayer.pause();
                      isPlaying = false;
                    } else {
                      audioPlayer.play();
                      isPlaying = true;
                    }
                    setState(() {
                      isPlaying
                          ? _animationController.reverse()
                          : _animationController.forward();
                    });
                  },
                  icon: AnimatedIcon(
                    icon: AnimatedIcons.pause_play,
                    progress: _animationController,
                  ),
                ),
              ],
            )
          ],
        )),
        Obx(() {
          if (audioBuffering.value) {
            return const Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator());
          }
          return Container();
        })
      ],
    );
  }

  isDownloaded(var itemId) async {
    var response = (await prefs.getJson(Constants.base_url +
        "/wp-json/learnpress/v1/lessons/" +
        itemId.toString()));
    if (!(response.toString() == "{}")) {
      var url;
      if (await get_mp4(response["content"]) != null) {
        url = await get_mp4(response["content"]);
      }
      if (await get_audio(response["content"]) != null) {
        url = await get_audio(response["content"]);
      }
      if (await get_youtube(response["content"]) != null) {
        url = await get_youtube(response["content"]);
      }
      if (await get_embedded(response["content"]) != null) {
        url = await get_embedded(response["content"]);
      }
      if (await get_pdf(response["content"]) != null) {
        url = await get_pdf(response["content"]);
      }
      if (url != null) {
        Directory? appDocDir = Platform.isAndroid
            ? await getExternalStorageDirectory()
            : await getApplicationDocumentsDirectory();
        String path = appDocDir!.path +
            "/" +
            (url.split('?')[0].split('#')[0]).split('/').last;
        if (File(path).existsSync()) {
          return true;
        }
        return false;
      }
      return true;
    }

    return false;
  }

  DownloadFile(String url, ItemsBean item) async {
    Dio dio = Dio();
    Directory? appDocDir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    String path = appDocDir!.path +
        "/" +
        (url.split('?')[0].split('#')[0]).split('/').last;
    File file = File(path);
    if (!File(path).existsSync()) {
      await file.create();
      await dio.download(
        url,
        path,
        options: Options(headers: {HttpHeaders.acceptEncodingHeader: "*"}),
        deleteOnError: true,
        cancelToken: cancelToken,
        onReceiveProgress: (receivedBytes, totalBytes) {
          if (totalBytes != -1) {
            
            downloadProgress[item.id] =
                (receivedBytes / totalBytes * 100).toInt();
            downloadingIconMode.refresh();
          } else {}
        },
      );
      return true;
    } else {
      return true;
    }
  }

  Widget downloadedButton(ItemsBean item) {
    return IconButton(
        icon: Icon(
          Icons.download_for_offline,
          color: Constants.primary_color,
        ),
        onPressed: () async {
          AlertDialog alert = AlertDialog(
            title: Text("Delete Lesson".tr),
            content: Text("Are you sure, do you want to delete the lesson?".tr),
            actions: [
              TextButton(
                child: Text("No".tr),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text("Yes".tr),
                onPressed: () async {
                  await DeleteLesson(item);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Deleted successfully".tr + "!!!")));
                },
              ),
            ],
          );
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return alert;
            },
          );
        });
  }

  DeleteLesson(ItemsBean item) async {
    var response = (await prefs.getJson(Constants.base_url +
        "/wp-json/learnpress/v1/lessons/" +
        item.id.toString()));
    if ((await get_mp4(response["content"])) != null) {
      Directory? appDocDir = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();
      String path = appDocDir!.path +
          "/" +
          ((await get_mp4(response["content"]))..split('?')[0].split('#')[0])
              .split('/')
              .last;
      if (await File(path).exists()) {
        await File(path).delete();
      }
    }
    await prefs.remove(Constants.base_url +
        "/wp-json/learnpress/v1/lessons/" +
        item.id.toString());
    downloadedLessons[item.id] = false;
    downloadingIconMode[item.id] = 0;
    downloadingItems[item.id] == false;
    downloadingIconMode.refresh();
    downloadedLessons.refresh();
  }

  Downloadlesson(ItemsBean item) async {
    downloadProgress[item.id] = 0;
    downloadingItems[item.id] = true;
    downloadingIconMode[item.id] = 1;
    downloadingIconMode.refresh();
    if (item.type == "lp_lesson") {
      var response = await LessonsApi.GetLesson(item.id as dynamic);
      if ((await get_mp4(response["content"]) != null)) {
        await DownloadFile(await get_mp4(response["content"]), item);
      }
      if ((await get_audio(response["content"]) != null)) {
        await DownloadFile(await get_audio(response["content"]), item);
      }
      if ((await get_pdf(response["content"]) != null)) {
        await DownloadFile(await get_pdf(response["content"]), item);
      }

      if ((await get_youtube(response["content"]) != null)) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("This file can't be downloaded".tr)));
        await DeleteLesson(item);
        downloadingIconMode[item.id] = 0;
        downloadingItems[item.id] == false;
      }

      if ((await get_embedded(response["content"]) != null)) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("This file can't be downloaded".tr)));
        await DeleteLesson(item);
        downloadingIconMode[item.id] = 0;
        downloadingItems[item.id] == false;
      }

      if ((await get_zoom(response["content"]) != null)) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("This file can't be downloaded".tr)));
        await DeleteLesson(item);
        downloadingIconMode[item.id] = 0;
        downloadingItems[item.id] == false;
      }
      if ((await get_h5p(response["content"]) != null)) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("This file can't be downloaded".tr)));
        await DeleteLesson(item);
        downloadingIconMode[item.id] = 0;
        downloadingItems[item.id] == false;
      }

      if ((await get_youtube(response["content"]) == null) &&
          (await get_embedded(response["content"]) == null) &&
          (await get_zoom(response["content"]) == null) &&
          (await get_h5p(response["content"]) == null)) {
        downloadProgress[item.id] = 0;
        downloadedLessons[item.id] = true;
        downloadingItems[item.id] = false;
        downloadingIconMode[item.id] = 0;
        downloadedLessons.refresh();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("This file can't be downloaded".tr)));
      await DeleteLesson(item);
      downloadingIconMode[item.id] = 0;
      downloadingItems[item.id] == false;
    }
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    @required RenderBox? parentBox,
    Offset offset = Offset.zero,
    @required SliderThemeData? sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double? trackHeight = sliderTheme!.trackHeight;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox!.size.height - trackHeight!) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

get_zoom(var content) async {
  if (content.contains("zoom_meeting_post")) {
    return content.replaceAll(new RegExp(r'[^0-9]'), '');
  }
  return null;
}

get_h5p(var content) async {
  if (content.contains("h5p id")) {
    return content
        .replaceAll(new RegExp(r'[^0-9]'), '')
        .substring(1, content.replaceAll(new RegExp(r'[^0-9]'), '').length);
  }
  return null;
}

get_youtube(var content) async {
  if (content != null) {
    List<dynamic> links = await _urlinString(content);
    for (String link in links) {
      try {
        var url = YoutubePlayer.convertUrlToId(link)!;
        return url;
      } catch (e) {}
    }
  }
  return null;
}

get_embedded(var content) async {
  if (content != null) {
    List<dynamic> links = await _urlinString(content);
    for (String link in links) {
      if (link.contains("https://iframe.mediadelivery.net")) {
        return link;
      }
    }
  }
  return null;
}

get_mp4(var content) async {
  if (content != null) {
    List<dynamic> links = await _urlinString(content);
    for (String link in links) {
      if (link.contains(".mp4")) {
        return link;
      }
    }
  }
  return null;
}

Future get_audio(var content) async {
  if (content != null) {
    List<dynamic> links = await _urlinString(content);
    for (String link in links) {
      if (link.contains(".mp3")) {
        return link;
      }
    }
  }
  return null;
}

get_pdf(var content) async {
  if (content != null) {
    List<dynamic> links = await _urlinString(content);
    for (String link in links) {
      if (link.contains(".pdf")) {
        return link;
      }
    }
  }
  return null;
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

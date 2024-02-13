import 'dart:async';

import 'package:LearnGun/widgets/Notify/notify.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uni_links/uni_links.dart';
import '../../services/SettingsAPI.dart';
import '../../widgets/BottomNav.dart';
import '../services/CoursesAPI.dart';
import 'MyCourses.dart';
import '../../utils/constants.dart';
import '../../services/SharedPrefs.dart';
import 'curriculumPreview.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool hasConnection = false;
  late var _getSettings;
  bool isConnectionDialogShowing = false;
  final duration = const Duration(milliseconds: 300);
  final distance = 24.0;

  late final _controller = AnimationController(
    vsync: this,
    duration: duration,
  );

  Future<void> initUniLinks() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      final initialLink = await getInitialLink();
      List<String> pathSeg = Uri.parse(initialLink ?? "").pathSegments;
      String slug =
          (pathSeg.last == "") ? pathSeg[pathSeg.length - 2] : pathSeg.last;

      notify.showLoadingDialog("Loading course");
      var courses = await CoursesApi().GetCourses({"slug": slug});
      if (courses.length == 0) {
        Get.back();
        notify.showDialog("Error", "Course not found", on_confirm: () {
          Get.back();
        });
      } else {
        Get.back();
        Get.to(CurriculumScreen(Course: courses[0]));
      }
      // Parse the link and warn the user, if it is not correct,
      // but keep in mind it could be `null`.
    } on PlatformException {}
  }

  @override
  void initState() {
    initUniLinks();

    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Constants.primary_color));
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      checkConnection().then((value) {
        if (value == false) {
          isConnectionDialogShowing = true;
          showDialog(
              barrierDismissible: false,
              context: Get.context!,
              builder: (_) => WillPopScope(
                  onWillPop: () => Future.value(false),
                  child: AnimatedBuilder(
                      animation: _controller,
                      builder: (BuildContext context, Widget? child) {
                        final dx = sin(_controller.value * 2 * pi) * distance;
                        return Transform.translate(
                          offset: Offset(dx, 0),
                          child: child,
                        );
                      },
                      child: AlertDialog(
                        title: const Text('No internet connection'),
                        content: const Text(
                            'You don\'t have a active internet connection'),
                        actions: [
                          TextButton(
                            child: const Text("Retry"),
                            onPressed: () {
                              checkConnection().then((value) {
                                if (!value) {
                                  _controller.forward(from: 0.0).then((value) =>
                                      _controller.forward(from: 0.0).then(
                                          (value) =>
                                              _controller.forward(from: 0.0)));
                                } else {
                                  Navigator.pop(context);
                                }
                              });
                            },
                          ),
                          TextButton(
                            child: const Text("Open offline courses"),
                            onPressed: () {
                              prefs.getString("user_info_id").then((value) {
                                if (value != null) {
                                  Get.off(const CoursesScreen(IsOffline: true));
                                }
                              });
                            },
                          ),
                        ],
                      )))).then((value) => isConnectionDialogShowing = false);
        } else {
          if (isConnectionDialogShowing) {
            Get.back();
          }
        }
      });
    });
    _getSettings = SettingsApi().GetSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
      future: checkConnection(),
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          if (!(snapshot.data as bool)) {
            Future.microtask(() {
              prefs.getString("user_info_id").then((value) {
                if (value != null) {
                  Get.off(const CoursesScreen(IsOffline: true));
                }
              });
            });
          }
        }
        return FutureBuilder(
            future: _getSettings,
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                return BottomNav();
              }
              return SizedBox(
                height: Get.height,
                width: Get.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: Get.height * 0.38),
                    ExtendedImage.asset("assets/logo.png",
                        width: Get.width * 0.8),
                    const Spacer(),
                    const CircularProgressIndicator(),
                    SizedBox(height: 20.h)
                  ],
                ),
              );
            });
      },
    ));
  }

  Future<bool> checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        hasConnection = true;
      } else {
        hasConnection = false;
      }
    } on SocketException catch (_) {
      hasConnection = false;
    }
    return hasConnection;
  }
}

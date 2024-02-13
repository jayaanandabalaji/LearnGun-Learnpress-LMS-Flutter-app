import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

import '../../utils/Translations.dart';
import '../../utils/constants.dart';
import 'themes/AppTheme.dart';
import '../../screens/SplashScreen.dart';

var theme_data;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
      );

  theme_data = AppTheme.get_app_theme();
  if (GetPlatform.isAndroid && Constants.isProtected) {
    FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  ByteData data =
      await PlatformAssetBundle().load('assets/lets-encrypt-r3.pem');
  SecurityContext.defaultContext
      .setTrustedCertificatesBytes(data.buffer.asUint8List());

  try {
    Stripe.publishableKey = Constants.stripePublishableKey;
    await Stripe.instance.applySettings();
  } finally {

    runApp(
      MyApp(),
    );
  }
}


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 756),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return GetMaterialApp(
          translations: translations(),
          locale: Locale(Constants.defaultLanguage),
          builder: (context, widget) {
            ScreenUtil.init(context);
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: widget!,
            );
          },
          navigatorKey: Get.key,
          home: SplashScreen(),
          theme: theme_data,
        );
      },
      child: SplashScreen(),
    );
  }
}

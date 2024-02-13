import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'dart:isolate';
import 'dart:ui';
import 'package:android_path_provider/android_path_provider.dart';
import 'dart:io';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../Models/Blogs.dart';
import '../utils/constants.dart';
import '../widgets/Button.dart';
import '../widgets/HtmlWidget.dart';

class blogdetail extends StatefulWidget {
  final isOthers;
  final blogs blog;
  const blogdetail({required this.blog, this.isOthers: false});

  @override
  State<blogdetail> createState() => _blogdetailState();
}

class _blogdetailState extends State<blogdetail> {
  bool adloaded = false;
  var unescape = HtmlUnescape();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  static final AdRequest request = AdRequest(
    nonPersonalizedAds: false,
  );

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  int maxFailedLoadAttempts = 3;
  ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();

    if (Constants.ShowAds) {
      _createInterstitialAd();
    }
    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      
    });
    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');

    send!.send([id, status, progress]);
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: Constants.InterstitialUnitId,
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
            if (!adloaded) {
              _showInterstitialAd();
              adloaded = true;
            }
          },
          onAdFailedToLoad: (LoadAdError error) {
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) => {},
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
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
                height: (widget.isOthers) ? Get.height * 0.8 : Get.height * 0.88,
                child: ListView(
                  padding: EdgeInsets.all(20),
                  children: [
                    Text(
                      unescape.convert(widget.blog.title.rendered),
                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    Text(
                      "By".tr+" " + widget.blog.embedded["author"][0]["name"].replaceAll("@gmail.com", ""),
                      style: TextStyle(color: Constants.primary_color, fontSize: 14.sp),
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    Text(
                      "Last updated on".tr+" " + widget.blog.modified.substring(0, 10),
                      style: TextStyle(color: Colors.grey, fontSize: 14.sp),
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
                    html_content.html_widget(widget.blog.content.rendered)
                  ],
                )),
            if (widget.isOthers)
              Expanded(
                  child: Center(
                child: theme_buttons.material_button("Download".tr, 0.6, onTap: () async {
                  var _name = widget.blog.details["file_file-link"][0].split('/').last;
                  final dir = await _prepareSaveDir(); //From path_provider package
                  var _localPath = dir + "/" + _name;
                  final savedDir = Directory(_localPath);
                  await savedDir.create(recursive: true).then((value) async {
                    await FlutterDownloader.enqueue(
                      url: widget.blog.details["file_file-link"][0],
                      fileName: _name,
                      savedDir: _localPath,
                      showNotification: true,
                      openFileFromNotification: true,
                    );
                    FlutterRingtonePlayer.playNotification();
                  });
                }),
              ))
          ],
        ));
  }

  Future<String> _prepareSaveDir() async {
    var _localPath = (await _findLocalPath())!;
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    return _localPath;
  }

  Future<String?> _findLocalPath() async {
    var externalStorageDirPath;
    if (Platform.isAndroid) {
      try {
        externalStorageDirPath = await AndroidPathProvider.downloadsPath;
      } catch (e) {
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath = directory?.path;
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath = (await getApplicationDocumentsDirectory()).absolute.path;
    }
    return externalStorageDirPath;
  }
}

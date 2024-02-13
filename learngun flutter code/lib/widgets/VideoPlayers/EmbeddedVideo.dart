import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

import '../../utils/constants.dart';

// ignore: must_be_immutable
class embeddedVideo extends StatelessWidget {
  var is_loading = false.obs;
  final url;
  embeddedVideo(this.url);
  @override
  Widget build(BuildContext context) {
    is_loading.value = true;
    return Stack(
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(url: Uri.parse(url), headers: {"referer": Constants.base_url}),
          onLoadStop: (_webViewController, uri) {
            is_loading.value = false;
          },
          onWebViewCreated: (InAppWebViewController controller) {},
        ),
        Obx(() {
          if (is_loading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return Container();
        })
      ],
    );
  }
}

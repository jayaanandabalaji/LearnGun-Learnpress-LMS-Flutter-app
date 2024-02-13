import 'package:LearnGun/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class H5Plesson extends StatefulWidget {
  final H5PId;
  final title;
  const H5Plesson(this.H5PId, this.title);

  @override
  State<H5Plesson> createState() => _H5PlessonState();
}

class _H5PlessonState extends State<H5Plesson> {
  bool isLoading = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          InAppWebView(
              onLoadStop: (_, __) {
                setState(() {
                  isLoading = false;
                });
              },
              initialUrlRequest: URLRequest(
                  url: Uri.dataFromString(
                      '</!DOCTYPE html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"<title></title></head><body><iframe src="${Constants.base_url}/wp-admin/admin-ajax.php?action=h5p_embed_app&id=${widget.H5PId}&license=${Constants.purchase_code}" width="100%" height="100%" frameborder="0" allowfullscreen="allowfullscreen" ></iframe></body></html>',
                      mimeType: 'text/html'))),
          Visibility(
              visible: isLoading,
              child: Center(
                child: CircularProgressIndicator(),
              ))
        ],
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../../utils/constants.dart';
import '../services/LessonsAPI.dart';
import 'pdf/src/document.dart';
import 'pdf/src/viewer.dart';

// ignore: must_be_immutable
class PdfViewer extends StatefulWidget {
  final url;
  bool IsOffline;
  final String courseName;
  PdfViewer(this.url, this.courseName, {this.IsOffline = false});
  @override
  PdfViewerState createState() => PdfViewerState();
}

class PdfViewerState extends State<PdfViewer> {
  get_pdf(var content) async {
    List<dynamic> links = await _urlinString(content);
    for (String link in links) {
      if (link.contains(".pdf")) {
        return link;
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

  Future GetPath() async {
    var response = await LessonsApi.GetLesson(widget.url);
    Directory? appDocDir =
        Platform.isAndroid ? await getExternalStorageDirectory() : await getApplicationDocumentsDirectory();
    String path =
        appDocDir!.path + "/" + ((await get_pdf(response["content"])).split('?')[0].split('#')[0]).split('/').last;
    return await PDFDocument.fromFile(File(path));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Column(
      children: [
        GestureDetector(
            child: Row(children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
                onPressed: () {
                  Get.back();
                },
              ),
              Text(widget.courseName, style: const TextStyle(fontWeight: FontWeight.bold)),
            ]),
            onTap: () {
              Get.back();
            }),
        Expanded(
          child: FutureBuilder(
            future: (widget.IsOffline) ? (GetPath()) : PDFDocument.fromURL(widget.url),
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                return PDFViewer(
                  document: snapshot.data as PDFDocument,
                  zoomSteps: 1,
                  lazyLoad: true,
                  pickerButtonColor: Constants.primary_color,
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        )
      ],
    )));
  }
}

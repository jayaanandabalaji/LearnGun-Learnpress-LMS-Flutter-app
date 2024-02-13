import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

import '../../widgets/HtmlWidget.dart';

class completelesson extends StatefulWidget {
  final dynamic Lessoncontent;
  const completelesson({Key? key, required this.Lessoncontent}) : super(key: key);

  @override
  _completelessonScreenState createState() => _completelessonScreenState();
}

class _completelessonScreenState extends State<completelesson> {
  _completelessonScreenState();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.black, //change your color here
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: ListView(children: [
          Center(
            child: Padding(
              padding: EdgeInsets.all(16.h),
              child: html_content.html_widget(widget.Lessoncontent),
            ),
          ),
        ]));
  }
}

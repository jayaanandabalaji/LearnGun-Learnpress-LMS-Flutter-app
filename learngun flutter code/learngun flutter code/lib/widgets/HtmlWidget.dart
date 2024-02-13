import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class html_content {
  static Widget html_widget(String Content) {
    return Html(
      data: Content,
    );
  }
}

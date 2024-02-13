import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../Models/Courses.dart';
import '../services/LessonsAPI.dart';

class previewController extends GetxController {
  var is_loading = true.obs;
  var youtube_video_id = "";
  var mp4_video_url = "";
  var embedded_url = "";
  var content = "";
  Color scaffoldColor = Colors.black;

  getItem(ItemsBean item) async {
    is_loading.value = true;
    youtube_video_id = "";
    mp4_video_url = "";
    embedded_url = "";
    content = "";
    scaffoldColor = Colors.black;

    var response = await LessonsApi.GetLesson(item.id as dynamic);
    if (!await is_video(response["content"])) {
      content = response["content"];
      scaffoldColor = Colors.white;
    }
    is_loading.value = false;
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
      embedded_url = link;
      return true;
    }
    return false;
  }

  is_mp4_video(String link) async {
    if (link.contains(".mp4")) {
      mp4_video_url = link;
      return true;
    } else {
      return false;
    }
  }

  is_youtube_video(String link) async {
    try {
      youtube_video_id = YoutubePlayer.convertUrlToId(link)!;
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
}

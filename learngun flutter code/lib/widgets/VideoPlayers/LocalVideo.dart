import 'dart:io';
import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';
import 'package:path_provider/path_provider.dart';

import '../../services/LessonsAPI.dart';

class localVideo extends StatelessWidget {
  final url;
  final isOffline;
  const localVideo(this.url, {this.isOffline = false});

  get_video(var content) async {
    List<dynamic> links = await _urlinString(content);
    for (String link in links) {
      if (link.contains(".mp4")) {
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
    var response = await LessonsApi.GetLesson(url);
    Directory? appDocDir =
        Platform.isAndroid ? await getExternalStorageDirectory() : await getApplicationDocumentsDirectory();
    String path =
        appDocDir!.path + "/" + ((await get_video(response["content"])).split('?')[0].split('#')[0]).split('/').last;
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return (isOffline)
        ? FutureBuilder(
            future: GetPath(),
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                return BetterPlayer.file(
                  snapshot.data as dynamic,
                  betterPlayerConfiguration: const BetterPlayerConfiguration(
                    autoPlay: true,
                    autoDispose: true,
                  ),
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          )
        : BetterPlayer.network(
            url,
            betterPlayerConfiguration: const BetterPlayerConfiguration(
              autoPlay: true,
              autoDispose: true,
            ),
          );
  }
}

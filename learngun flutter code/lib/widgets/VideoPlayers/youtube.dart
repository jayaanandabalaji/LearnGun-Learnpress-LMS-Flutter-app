import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class youtube extends StatelessWidget {
  final id;
  const youtube(this.id);

  @override
  Widget build(BuildContext context) {
    YoutubePlayerController controller;
    controller = YoutubePlayerController(
      initialVideoId: id,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
      ),
    );
    return YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: controller,
          showVideoProgressIndicator: true,
        ),
        builder: (context, player) {
          return Column(
            children: [player],
          );
        });
  }
}

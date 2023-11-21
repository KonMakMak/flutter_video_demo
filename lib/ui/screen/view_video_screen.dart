import 'dart:math' hide log;
import 'package:flutter/material.dart';
import 'package:flutter_video_demo/ui/bloc/video_controller.dart';
import 'package:flutter_video_demo/ui/model/video.dart';
import 'package:flutter_video_demo/ui/screen/vidoe_play.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:video_player/video_player.dart';

class ViewVideoScreen extends StatefulWidget {
  const ViewVideoScreen({super.key});

  @override
  State<ViewVideoScreen> createState() => _ViewVideoScreenState();
}

class _ViewVideoScreenState extends State<ViewVideoScreen> {
  late VideoController videoController = Get.find();
  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.networkUrl(
        Uri.parse(videoController.videoModel.url!))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Builder(builder: (context) {
          return AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(children: [
                CustomVideoPlay(
                  videoModel: videoController.videoModel,
                  onChange: (value) {
                    print(value.duration);
                  },
                )
              ]));
        }),
        // ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              controller.value.isPlaying
                  ? controller.pause()
                  : controller.play();
            });
          },
          child: Icon(
            controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
      ),
    );
  }
}

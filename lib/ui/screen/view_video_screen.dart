import 'dart:math' hide log;
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_video_demo/ui/bloc/video_controller.dart';
import 'package:flutter_video_demo/ui/model/video.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:get/route_manager.dart';
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
                VideoPlay(videoModel: videoController.videoModel)
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

// ignore: must_be_immutable
class VideoPlay extends StatefulWidget {
  VideoPlay({super.key, required this.videoModel});
  VideoModel videoModel;

  @override
  State<VideoPlay> createState() => _VideoPlayState();
}

class _VideoPlayState extends State<VideoPlay> {
  ValueNotifier<VideoPlayerValue?> currentPosition = ValueNotifier(null);
  VideoPlayerController? controller;
  late Future<void> futureController;
  var _currentDur = 0.0;

  final RxBool _isPlaying = false.obs;

  initVideo() {
    controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoModel.url!));

    futureController = controller!.initialize();
  }

  @override
  void initState() {
    initVideo();
    controller!.addListener(() {
      if (controller!.value.isInitialized) {
        currentPosition.value = controller!.value;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureController,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              alignment: Alignment.center,
              color: Colors.black,
              child: const CircularProgressIndicator(),
            ),
          );
        } else {
          return _videoPlayer();
        }
      },
    );
  }

  SizedBox _videoPlayer() {
    return SizedBox(
      height: controller!.value.size.height,
      width: double.infinity,
      child: AspectRatio(
          aspectRatio: controller!.value.aspectRatio,
          child: Stack(children: [
            VideoPlayer(controller!),
            _videoControll(),
          ])),
    );
  }

  _videoControll() {
    return Obx(() {
      return Positioned.fill(
        bottom: -10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Spacer(),
            IconButton(
              icon: Icon(
                _isPlaying.isTrue ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 40,
              ),
              onPressed: () {
                if (controller!.value.isPlaying) {
                  controller!.pause();
                  _isPlaying(false);
                } else {
                  controller!.play();
                  _isPlaying(true);
                }
              },
            ),
            const Spacer(),
            ValueListenableBuilder(
                valueListenable: currentPosition,
                builder: (context, VideoPlayerValue? videoPlayerValue, w) {
                  var sourceDuration =
                      _durationConverter(videoPlayerValue!.duration);

                  var positionDuration =
                      _durationConverter(videoPlayerValue.position);

                  var sliderPercent =
                      _calulatePositionSliderAsPercent(videoPlayerValue);

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(sourceDuration,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 22)),
                      Expanded(
                          child: Slider(
                        value: max(0, min(sliderPercent * 100, 100)),
                        min: 0,
                        max: 100,
                        thumbColor: Colors.red,
                        activeColor: Colors.red,
                        overlayColor:
                            const MaterialStatePropertyAll(Colors.red),
                        inactiveColor: Colors.black,
                        onChanged: (value) {
                          final duration = controller?.value.duration;
                          if (duration != null) {
                            var newVal = max(0, min(value, 99)) * 0.01;
                            var millis =
                                (duration.inMilliseconds * newVal).milliseconds;

                            controller
                              ?..seekTo(millis)
                              ..play();
                          }
                        },
                        onChangeEnd: (value) {
                          // print('<<< $value');
                          // controller!.play().then((value) => _isPlaying(true));
                        },
                        onChangeStart: (value) {
                          print('>>>> $value');
                          controller!
                              .pause()
                              .then((value) => _isPlaying(false));
                        },
                      )),
                      Text(
                        positionDuration,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 22),
                      ),
                    ],
                  ).marginSymmetric(horizontal: 10);
                })
          ],
        ),
      );
    });
  }

  double _calulatePositionSliderAsPercent(VideoPlayerValue videoPlayerValue) {
    return videoPlayerValue.position.inMilliseconds.ceilToDouble() /
        videoPlayerValue.duration.inMilliseconds.ceilToDouble();
  }

  String _durationConverter(Duration duration) => duration.toString().substring(
      duration.toString().indexOf(':') + 1, duration.toString().indexOf('.'));
}

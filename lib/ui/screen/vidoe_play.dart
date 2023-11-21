import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_video_demo/ui/model/video.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

enum VideoViewType { play, upload }

class CustomVideoPlay extends StatefulWidget {
  const CustomVideoPlay(
      {super.key,
      required this.videoModel,
      required this.onChange,
      this.type = VideoViewType.play});
  final VideoModel videoModel;
  final VideoViewType type;
  final ValueChanged<VideoPlayerValue> onChange;

  @override
  State<CustomVideoPlay> createState() => _CustomVideoPlayState();
}

class _CustomVideoPlayState extends State<CustomVideoPlay> {
  ValueNotifier<VideoPlayerValue?> currentPosition = ValueNotifier(null);
  VideoPlayerController? controller;
  late Future<void> futureController;

  bool _isPlaying = false;

  initVideo() {
    if (widget.videoModel.file != null) {
      controller = VideoPlayerController.file(widget.videoModel.file!);
    } else {
      controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoModel.url!));
    }

    futureController = controller!.initialize();
  }

  play() => setState(() => _isPlaying = true);
  stop() => setState(() => _isPlaying = false);

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

            /// Set opacity to video if video is uploading
            if (widget.videoModel.uploadFileStatus.value == APIStatus.loading)
              Container(color: Colors.transparent.withOpacity(0.5)),

            ///
            _videoControll(),
          ])),
    );
  }

  _videoControll() {
    if (widget.videoModel.uploadFileStatus.value == APIStatus.loading) {
      return Positioned.fill(
          bottom: -10,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: () {},
                      style: IconButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          backgroundColor: Colors.grey.shade700,
                          tapTargetSize: MaterialTapTargetSize.padded,
                          padding: const EdgeInsets.all(0)),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ))
                ],
              )
            ],
          ));
    }
    return Positioned.fill(
      bottom: -10,
      child: _playControllerLayout(),
    );
  }

  Column _playControllerLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Spacer(),
        IconButton(
          icon: Icon(
            _isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: 40,
          ),
          onPressed: () {
            setState(() {
              if (controller!.value.isPlaying) {
                controller!.pause();
                stop();
              } else {
                controller!.play();
                play();
              }
            });
          },
        ),
        const Spacer(),
        ValueListenableBuilder(
            valueListenable: currentPosition,
            builder: (context, VideoPlayerValue? vdPValue, w) {
              var sourceDuration = _durationConverter(vdPValue!.duration);
              var positionDuration = _durationConverter(vdPValue.position);

              /// Duration Percentage Formula
              /// DUP = (Current DU/ Total DU ) *100
              var durationPercent = ((vdPValue.position.inMilliseconds /
                      vdPValue.duration.inMilliseconds) *
                  100);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(sourceDuration,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16)),
                    Expanded(
                        child: Slider(
                      value: durationPercent,
                      min: 0,
                      max: 100,
                      thumbColor: Colors.red,
                      activeColor: Colors.red,
                      overlayColor: const MaterialStatePropertyAll(Colors.red),
                      inactiveColor: Colors.white,
                      onChanged: (value) {
                        /// Duration Percentage Formula
                        /// DUP = (Current DU/ Total DU ) *100
                        /// => CUD = DUP * TOD /100
                        Duration cureentDu = Duration(
                            milliseconds:
                                ((value * vdPValue.duration.inMilliseconds) /
                                        100)
                                    .truncate());
                        if (value.toInt().isEqual(100)) {
                          controller!.pause().then((value) => stop());
                        } else {
                          controller!
                            ..seekTo(cureentDu)
                            ..play();
                        }
                      },
                      onChangeEnd: (value) {
                        controller!.play().then((value) => play());
                      },
                      onChangeStart: (value) {
                        controller!.pause().then((value) => stop());
                      },
                    )),
                    Text(
                      positionDuration,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              );
            })
      ],
    );
  }

  double _calulatePositionSliderAsPercent(VideoPlayerValue videoPlayerValue) {
    return videoPlayerValue.position.inMilliseconds.ceilToDouble() /
        videoPlayerValue.duration.inMilliseconds.ceilToDouble();
  }

  String _durationConverter(Duration duration) => duration.toString().substring(
      duration.toString().indexOf(':') + 1, duration.toString().indexOf('.'));
}

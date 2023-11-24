import 'package:flutter/material.dart';
import 'package:flutter_video_demo/ui/model/video.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:video_player/video_player.dart';

enum VideoViewType { play, upload }

class CustomVideoPlay extends StatefulWidget {
  const CustomVideoPlay(
      {super.key,
      required this.videoModel,
      required this.onChange,
      this.onRemove,
      this.type = VideoViewType.play,
      this.onDelete,
      this.onRefresh,
      this.onError});
  final VideoModel videoModel;
  final VideoViewType type;
  final ValueChanged<VideoPlayerValue> onChange;
  final VoidCallback? onRemove;
  final VoidCallback? onDelete;
  final VoidCallback? onRefresh;
  final VoidCallback? onError;

  @override
  State<CustomVideoPlay> createState() => _CustomVideoPlayState();
}

class _CustomVideoPlayState extends State<CustomVideoPlay> {
  ValueNotifier<VideoPlayerValue?> currentPosition = ValueNotifier(null);
  VideoPlayerController? controller;
  late Future<void> futureController;

  VideoModel get videoModel => widget.videoModel;

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

  bool get isOnServer => widget.videoModel.isOnServer;

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
          return Obx(() {
            return _videoPlayer();
          });
        }
      },
    );
  }

  SizedBox _videoPlayer() {
    bool isUploadFailed = true;
    switch (videoModel.uploadFileStatus.value) {
      case APIStatus.loaded:
      case APIStatus.loading:
        isUploadFailed = false;
        break;
      default:
        isUploadFailed = true;
    }

    return SizedBox(
      height: controller!.value.size.height,
      width: double.infinity,
      child: AspectRatio(
          aspectRatio: controller!.value.aspectRatio,
          child: Stack(children: [
            VideoPlayer(controller!),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                /// Remove icon
                if (widget.onRemove != null)
                  IconButton(
                      onPressed: () {},
                      style: IconButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          backgroundColor: Colors.grey.shade700,
                          tapTargetSize: MaterialTapTargetSize.padded,
                          padding: const EdgeInsets.all(0)),
                      icon: const Icon(Icons.close, color: Colors.white)),
              ],
            ),

            /// Set opacity to video if video is uploading
            if (isUploadFailed)
              Container(color: Colors.transparent.withOpacity(0.5)),

            ///
            _videoControll(isUploadFailed),
          ])),
    );
  }

  _videoControll(bool isUploadFailed) {
    if (widget.type == VideoViewType.play ||
        videoModel.uploadFileStatus.value == APIStatus.loaded) {
      return Positioned.fill(
        bottom: -10,
        child: _playControllerLayout(),
      );
    }
    return _videoIsUpload(isUploadFailed);
  }

  /// Widget error widget
  Widget get _errorWidget => Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Video failed to load",
                style: TextStyle(fontSize: 13, color: Colors.white)),
            const SizedBox(height: 10),
            OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white),
                ),
                onPressed: widget.onRefresh,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text("Retry",
                    style: TextStyle(fontSize: 13, color: Colors.white))),
          ],
        ),
      );

  ///
  _videoIsUpload(bool isUploadFailed) {
    /// Check upload status
    bool isUploadCompleted =
        videoModel.uploadFileStatus.value == APIStatus.loaded;

    return Positioned.fill(
        // bottom: 0,
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Error btn
        if (isUploadFailed) _errorWidget,

        /// Upload progress
        if (!isUploadCompleted) ...[
          const Spacer(),
          const Text("Uploading...",
              style: TextStyle(fontSize: 13, color: Colors.white)),
          const SizedBox(height: 10),
          LinearPercentIndicator(
            padding: EdgeInsets.zero,
            lineHeight: 2,
            percent: widget.videoModel.uploadProgress.value / 100.0,
            barRadius: const Radius.circular(16),
            progressColor: Colors.red,
            backgroundColor: Colors.white,
          )
        ]
      ],
    ).marginAll(16));
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

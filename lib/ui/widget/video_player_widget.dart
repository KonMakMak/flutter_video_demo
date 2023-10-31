import 'package:flutter/material.dart';
import 'package:flutter_video_demo/ui/widget/video_controls_widget.dart';
import 'package:flutter_video_demo/ui/widget/video_progress_indicator.dart';
import 'package:video_player/video_player.dart';

import 'custom_controls_widget.dart';

class VideoPlayerWidget extends StatefulWidget {
  final List<Duration> timestamps;

  const VideoPlayerWidget({
    required this.timestamps,
    super.key,
  }) : super();
  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.networkUrl(Uri.parse(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                VideoPlayer(controller),
                VideoControlsWidget(controller: controller),
                CustomVideoProgressIndicator(
                  controller,
                  allowScrubbing: true,
                  timestamps: widget.timestamps,
                  colors: null,
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          CustomControlsWidget(
            controller: controller,
            timestamps: widget.timestamps,
          ),
          SizedBox(height: 12),
        ],
      );
}

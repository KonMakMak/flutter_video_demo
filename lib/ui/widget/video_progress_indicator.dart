import 'package:flutter/material.dart';
// import 'package:get/instance_manager.dart';
import 'package:get/route_manager.dart';
// import 'package:vector_math/vector_math_64.dart';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';

class CustomVideoProgressIndicator extends StatefulWidget {
  const CustomVideoProgressIndicator(this.controller,
      {required this.colors,
      required this.allowScrubbing,
      this.padding = const EdgeInsets.only(top: 5.0),
      required this.timestamps,
      super.key});

  /// The [VideoPlayerController] that actually associates a video with this
  /// widget.
  final VideoPlayerController controller;

  /// The default colors used throughout the indicator.
  ///
  /// See [VideoProgressColors] for default values.
  final VideoProgressColors? colors;

  final List<Duration> timestamps;

  /// When true, the widget will detect touch input and try to seek the video
  /// accordingly. The widget ignores such input when false.
  ///
  /// Defaults to false.
  final bool allowScrubbing;

  /// This allows for visual padding around the progress indicator that can
  /// still detect gestures via [allowScrubbing].
  ///
  /// Defaults to `top: 5.0`.
  final EdgeInsets padding;

  @override
  State<CustomVideoProgressIndicator> createState() =>
      _CustomVideoProgressIndicatorState();
}

class _CustomVideoProgressIndicatorState
    extends State<CustomVideoProgressIndicator> {
  late VoidCallback listener;

  VideoPlayerController get controller => widget.controller;

  VideoProgressColors get colors =>
      widget.colors ?? const VideoProgressColors();

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  List<int> durationDifferences = [];

  @override
  void initState() {
    super.initState();
    listener = () {
      if (!mounted) {
        return;
      }
      setState(() {});
    };
    controller.addListener(listener);
  }

  @override
  void deactivate() {
    controller.removeListener(listener);
    super.deactivate();
  }

  void calculateDurationDiffs() {
    final timestamps = widget.timestamps;
    final firstDifference =
        timestamps.first.inSeconds - Duration.zero.inSeconds;

    durationDifferences.add(firstDifference);
    for (int i = 0; i < timestamps.length - 1; i++) {
      final difference = timestamps[i + 1].inSeconds - timestamps[i].inSeconds;
      durationDifferences.add(difference);
    }
    final lastDifference =
        controller.value.duration.inSeconds - timestamps.last.inSeconds;
    durationDifferences.add(lastDifference);
  }

  @override
  Widget build(BuildContext context) {
    Widget progressIndicator;
    if (controller.value.isInitialized) {
      if (durationDifferences.isEmpty) {
        calculateDurationDiffs();
      }

      final int duration = controller.value.duration.inMilliseconds;
      final int position = controller.value.position.inMilliseconds;

      int maxBuffering = 0;
      for (DurationRange range in controller.value.buffered) {
        final int end = range.end.inMilliseconds;
        if (end > maxBuffering) {
          maxBuffering = end;
        }
      }

      progressIndicator = Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          LinearProgressIndicator(
            value: maxBuffering / duration,
            valueColor: AlwaysStoppedAnimation<Color>(colors.bufferedColor),
            backgroundColor: colors.backgroundColor,
          ),
          LinearProgressIndicator(
            value: position / duration,
            valueColor: AlwaysStoppedAnimation<Color>(colors.playedColor),
            backgroundColor: Colors.transparent,
          ),
        ],
      );
    } else {
      progressIndicator = LinearProgressIndicator(
        value: null,
        valueColor: AlwaysStoppedAnimation<Color>(colors.playedColor),
        backgroundColor: colors.backgroundColor,
      );
    }
    final Widget paddedProgressIndicator = Stack(
      children: [
        Container(
          height: 10,
          child: progressIndicator,
        ),
        Container(
          height: 10,
          child: Row(
            children: durationDifferences
                .map(
                  (difference) => Expanded(
                    flex: difference,
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                        height: double.infinity,
                        width: 2,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );

    final progressBar = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (controller.value.isInitialized)
          Container(
            alignment: Alignment.bottomLeft,
            padding: EdgeInsets.all(8),
            child: Text(
              '${_formatDuration(controller.value.position)} / ${_formatDuration(controller.value.duration)}',
              style: TextStyle(color: Colors.white),
            ),
          ),
        paddedProgressIndicator,
      ],
    );

    if (widget.allowScrubbing) {
      return _VideoScrubber(
        child: progressBar,
        controller: controller,
      );
    } else {
      return progressBar;
    }
  }
}

class _VideoScrubber extends StatefulWidget {
  _VideoScrubber({
    required this.child,
    required this.controller,
  });

  final Widget child;
  final VideoPlayerController controller;

  @override
  _VideoScrubberState createState() => _VideoScrubberState();
}

class _VideoScrubberState extends State<_VideoScrubber> {
  bool _controllerWasPlaying = false;

  VideoPlayerController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    void seekToRelativePosition(Offset globalPosition) {
      final box = context.findRenderObject();
      final tapPos = box!.getTransformTo(globalPosition as RenderObject?);
      final relative = tapPos.up / Get.size.width;
      final Duration position = controller.value.duration * relative.length;
      controller.seekTo(position);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: widget.child,
      onHorizontalDragStart: (DragStartDetails details) {
        if (!controller.value.isInitialized) {
          return;
        }
        _controllerWasPlaying = controller.value.isPlaying;
        if (_controllerWasPlaying) {
          controller.pause();
        }
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (!controller.value.isInitialized) {
          return;
        }
        seekToRelativePosition(details.globalPosition);
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (_controllerWasPlaying) {
          controller.play();
        }
      },
      onTapDown: (TapDownDetails details) {
        if (!controller.value.isInitialized) {
          return;
        }
        seekToRelativePosition(details.globalPosition);
      },
    );
  }
}

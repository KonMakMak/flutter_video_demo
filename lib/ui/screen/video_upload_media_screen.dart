import 'package:flutter/material.dart';
import 'package:flutter_video_demo/ui/model/video.dart';
import 'package:video_player/video_player.dart';

class VideoUploadMeida extends StatefulWidget {
  const VideoUploadMeida({super.key});

  @override
  State<VideoUploadMeida> createState() => _VideoUploadMeidaState();
}

class _VideoUploadMeidaState extends State<VideoUploadMeida> {
  VideoModel videoModel = VideoModel();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(children: []),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {}, label: const Icon(Icons.image)),
    );
  }
}

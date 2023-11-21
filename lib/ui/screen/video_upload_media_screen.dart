import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_video_demo/ui/model/video.dart';
import 'package:flutter_video_demo/ui/screen/vidoe_play.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class VideoUploadMeida extends StatefulWidget {
  const VideoUploadMeida({super.key});

  @override
  State<VideoUploadMeida> createState() => _VideoUploadMeidaState();
}

class _VideoUploadMeidaState extends State<VideoUploadMeida> {
  VideoModel? videoModel;

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
      body: ListView(children: [
        if (videoModel != null)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: CustomVideoPlay(videoModel: videoModel!, onChange: (v) {}),
          )
      ]),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final ImagePicker picker = ImagePicker();
            XFile? file = await picker.pickVideo(source: ImageSource.gallery);

            setState(() {
              videoModel = VideoModel()
                ..file = File(file!.path)
                ..uploadFileStatus(APIStatus.loading);
            });
          },
          label: const Icon(Icons.image)),
    );
  }
}

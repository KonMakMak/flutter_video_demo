import 'package:flutter/material.dart';
import 'package:flutter_video_demo/ui/bloc/video_controller.dart';
import 'package:flutter_video_demo/ui/model/video.dart';
import 'package:flutter_video_demo/ui/screen/vidoe_play.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class VideoUploadMeida extends StatefulWidget {
  const VideoUploadMeida({super.key});

  @override
  State<VideoUploadMeida> createState() => _VideoUploadMeidaState();
}

class _VideoUploadMeidaState extends State<VideoUploadMeida> {
  VideoModel? videoModel;
  late VideoController videoController = Get.find();

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
    return GetBuilder(
        init: videoController,
        dispose: (state) {
          state.controller?.uploadVideo = VideoModel();
        },
        builder: (_) {
          return Scaffold(
            body: ListView(children: [
              if (_.uploadVideo.url != null || _.uploadVideo.file != null)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CustomVideoPlay(
                      videoModel: _.uploadVideo,
                      type: VideoViewType.upload,
                      onChange: (v) {},
                      onRemove: () {}),
                ),
              Obx(() => Text(_.uploadVideo.toJson().toString())),
            ]),
            floatingActionButton: FloatingActionButton.extended(
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  XFile? Xfile =
                      await picker.pickVideo(source: ImageSource.gallery);
                  if (Xfile != null) {
                    videoController.videoUpload(Xfile,
                        (progress, taskSnapshot) {
                      _.uploadVideo.uploadProgress(progress);
                    });
                  }
                },
                label: const Icon(Icons.image)),
          );
        });
  }
}

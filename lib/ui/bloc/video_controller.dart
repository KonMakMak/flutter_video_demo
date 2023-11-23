import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_video_demo/ui/model/video.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class VideoController extends GetxController {
  VideoModel videoModel = VideoModel.fromJson({
    'url':
        'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'

    // 'url':
    // 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'
  });
  VideoModel readVideo = VideoModel();
  VideoModel uploadVideo = VideoModel();
  @override
  onInit() {
    // readVideo.uploadFileStatus(APIStatus.loading);
    // videoController();
    super.onInit();
  }

  Reference get firebaseRe => FirebaseStorage.instance.ref('');
  Future videoController() async {
    var url = await firebaseRe.child('video/');

    readVideo.url = await url.getDownloadURL().then((value) {
      // log(">>>>>>> $value");
      if (value.isNotEmpty) {
        readVideo.uploadFileStatus(APIStatus.loaded);
      }
      return value;
    });
    update();
  }

  videoUpload(XFile file, ProgressCallback onProgress) {
    var convertFile = File(file.path);

    /// Before push to server, declare some value for local video
    uploadVideo
      ..file = convertFile
      ..isOnServer = true
      ..uploadFileStatus(APIStatus.loading);
    update();

    /// Upload to cloud storage
    var metadata = SettableMetadata(contentType: 'video/mp4');
    Reference ref = FirebaseStorage.instance.ref("video/${file.name}");
    var uploadTask = ref.putFile(File(file.path), metadata);

    /// Handle task when upload completed
    /// assign file url reference
    uploadTask.whenComplete(() async {
      String downloadUrl = await ref.getDownloadURL();
      uploadVideo
        ..url = downloadUrl
        ..isOnServer = true
        ..uploadFileStatus(APIStatus.loaded);
    });

    uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
      switch (taskSnapshot.state) {
        case TaskState.running:
          final progress =
              100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
          onProgress(progress, taskSnapshot);
          break;
        case TaskState.paused:
          final progress =
              100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
          onProgress(progress, taskSnapshot);
          break;
        case TaskState.canceled:
          onProgress(0, taskSnapshot);
          break;
        case TaskState.error:
          onProgress(0, taskSnapshot);
          break;
        case TaskState.success:
          onProgress(100.0, taskSnapshot);
          break;
      }
    }).onDone(() async {});

    update();
  }
}

typedef ProgressCallback = void Function(
    double progress, TaskSnapshot taskSnapshot);

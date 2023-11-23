import 'dart:io';
import 'package:get/get.dart';

import '';

class VideoModel {
  VideoModel();

  File? file;
  String? url;

  ///
  Rx<APIStatus> uploadFileStatus = APIStatus.empty.obs;
  RxDouble uploadProgress = 0.0.obs;
  bool isOnServer = true;

  VideoModel.fromJson(Map<String, dynamic> json) : url = json['url'];

  Map<String, dynamic> toJson() => {
        'url': url,
        'file': file,
        'status': uploadFileStatus.value,
        "progress": uploadProgress.value,
        'is_onserver': isOnServer
      };
}

enum APIStatus {
  unInitialized,
  loading,
  loaded,
  empty,
  error,
  connectionError,
  expired
}

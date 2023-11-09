import 'dart:io';
import '';

class VideoModel {
  VideoModel();

  File? file;

  String? url;

  VideoModel.fromJson(Map<String, dynamic> json) : url = json['url'];

  Map<String, dynamic> toJson() => {'url': url};
}

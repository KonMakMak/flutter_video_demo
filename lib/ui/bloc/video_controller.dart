import 'package:flutter_video_demo/ui/model/video.dart';
import 'package:get/get.dart';

class VideoController extends GetxController {
  VideoModel videoModel = VideoModel.fromJson({
    'url':
        'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'

    // 'url':
    // 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'
  });
}

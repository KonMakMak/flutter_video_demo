import 'package:flutter/material.dart';
import 'package:flutter_video_demo/ui/screen/video_upload_media_screen.dart';
import 'package:flutter_video_demo/ui/screen/view_video_screen.dart';
import 'package:get/route_manager.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video demo'),
      ),
      body: ListView(
        children: [
          _buildBtn(
            'Video upload',
            onPress: () {
              Get.to(const VideoUploadMeida());
            },
          ),
          _buildBtn(
            'Video View',
            onPress: () {
              Get.to(const ViewVideoScreen());
            },
          )
        ],
      ),
    );
  }

  ElevatedButton _buildBtn(String title, {required Function() onPress}) =>
      ElevatedButton(onPressed: onPress, child: Text(title));
}

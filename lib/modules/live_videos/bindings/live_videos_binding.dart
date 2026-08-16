import 'package:get/get.dart';
import '../controllers/live_videos_controller.dart';

class LiveVideosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LiveVideosController>(() => LiveVideosController());
  }
}

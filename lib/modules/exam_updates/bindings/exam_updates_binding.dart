import 'package:get/get.dart';
import '../controllers/exam_updates_controller.dart';

class ExamUpdatesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExamUpdatesController>(() => ExamUpdatesController());
  }
}

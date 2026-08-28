import 'package:get/get.dart';
import '../controllers/test_batches_controller.dart';

class TestBatchesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TestBatchesController>(() => TestBatchesController());
  }
}

import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../controllers/section_selection_controller.dart';
import '../repositories/tests_repository.dart';

class SectionSelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TestsRepository>(() => TestsRepository(Get.find<ApiClient>()), fenix: true);
    Get.lazyPut<SectionSelectionController>(
      () => SectionSelectionController(Get.find<TestsRepository>()),
    );
  }
}

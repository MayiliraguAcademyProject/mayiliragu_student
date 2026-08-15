import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../tests/repositories/tests_repository.dart';
import '../controllers/bookmarked_questions_controller.dart';

class BookmarkedQuestionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TestsRepository>(() => TestsRepository(Get.find<ApiClient>()), fenix: true);
    Get.lazyPut<BookmarkedQuestionsController>(
      () => BookmarkedQuestionsController(Get.find<TestsRepository>()),
      fenix: true,
    );
  }
}

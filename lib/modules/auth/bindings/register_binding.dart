import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../controllers/register_controller.dart';
import '../repositories/auth_repository.dart';

class RegisterBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(() => AuthRepository(Get.find<ApiClient>()), fenix: true);
    Get.lazyPut<RegisterController>(() => RegisterController(Get.find<AuthRepository>()));
  }
}

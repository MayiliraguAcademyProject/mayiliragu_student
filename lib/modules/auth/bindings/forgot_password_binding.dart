import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../controllers/forgot_password_controller.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut<AuthRepository>(() => AuthRepository(Get.find<ApiClient>()), fenix: true);
    }
    if (!Get.isRegistered<ForgotPasswordController>()) {
      Get.lazyPut<ForgotPasswordController>(() => ForgotPasswordController(Get.find<AuthRepository>()), fenix: true);
    }
  }
}


import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../controllers/otp_verification_controller.dart';
import '../repositories/auth_repository.dart';

class OtpVerificationBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(() => AuthRepository(Get.find<ApiClient>()), fenix: true);
    Get.lazyPut<OtpVerificationController>(() => OtpVerificationController(Get.find<AuthRepository>()));
  }
}

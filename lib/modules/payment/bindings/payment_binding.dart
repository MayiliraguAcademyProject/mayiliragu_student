import 'package:get/get.dart';
import '../controllers/payment_controller.dart';
import '../repositories/payment_repository.dart';

class PaymentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentRepository>(() => PaymentRepository());
    Get.lazyPut<PaymentController>(() => PaymentController(Get.find<PaymentRepository>()));
  }
}

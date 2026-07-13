import 'package:get/get.dart';
import '../models/app_config_model.dart';
import '../network/api_client.dart';

class AppConfigService extends GetxService {
  final ApiClient _apiClient = Get.find<ApiClient>();

  Future<AppConfigModel?> fetchAppConfig() async {
    try {
      final response = await _apiClient.get('/app-config');
      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        if (body['status'] == 'success' && body['data'] != null) {
          return AppConfigModel.fromJson(body['data']);
        }
      }
    } catch (e) {
      // Fail-open strategy: log error and return null so the app proceeds
      Get.log('Error fetching app configuration: $e');
    }
    return null;
  }
}

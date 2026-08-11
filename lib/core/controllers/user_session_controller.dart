import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../network/api_client.dart';
import '../../shared/models/student_profile_model.dart';

class UserSessionController extends GetxController {
  final isPremium = false.obs;
  final isLoading = false.obs;
  final studentProfile = Rxn<StudentProfileModel>();

  Future<void> loadSession() async {
    try {
      isLoading.value = true;
      final apiClient = Get.find<ApiClient>();
      
      // Get basic profile to obtain userId and role
      final profileRes = await apiClient.get('/profile');
      if (profileRes.statusCode == 200) {
        final userData = profileRes.data['data'];
        final userId = userData['id'] as String?;
        final role = userData['role'] as String?;

        if (userId != null && userId.isNotEmpty && role == 'STUDENT') {
          final studentRes = await apiClient.get('/enrollments/students/$userId/profile');
          if (studentRes.statusCode == 200) {
            final profileData = studentRes.data['data'];
            if (profileData != null) {
              final profile = StudentProfileModel.fromJson(profileData);
              studentProfile.value = profile;
              isPremium.value = profile.isPremium;
              return;
            }
          }
        }
      }
      isPremium.value = false;
    } catch (e) {
      debugPrint('Error loading user session: $e');
      isPremium.value = false;
    } finally {
      isLoading.value = false;
    }
  }
}

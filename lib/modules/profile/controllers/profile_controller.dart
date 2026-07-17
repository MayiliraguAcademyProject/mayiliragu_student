import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../repositories/profile_repository.dart';
import '../../../core/utils/toast_helper.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../app/routes/app_routes.dart';
import '../../../shared/models/student_profile_model.dart';

class ProfileController extends GetxController {
  final ProfileRepository _repository;

  ProfileController(this._repository);

  final nameController = TextEditingController();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  final isLoading = false.obs;
  final isUpdatingName = false.obs;
  final isChangingPassword = false.obs;
  final isUpdatingStudentProfile = false.obs;
  final studentProfileLoaded = false.obs;
  final isDeletingAccount = false.obs;

  // Student Profile controllers
  final dobController = TextEditingController();
  final bloodGroupController = TextEditingController();
  final aadhaarController = TextEditingController();
  final nationalityController = TextEditingController(text: 'Indian');
  
  final mobileController = TextEditingController();
  final whatsappController = TextEditingController();
  final emergencyController = TextEditingController();
  final parentNameController = TextEditingController();
  final parentMobileController = TextEditingController();

  final currentAddressController = TextEditingController();
  final permanentAddressController = TextEditingController();
  final cityController = TextEditingController();
  final districtController = TextEditingController();
  final pinCodeController = TextEditingController();

  final qualificationController = TextEditingController();
  final degreeController = TextEditingController();
  final collegeController = TextEditingController();
  final yearOfPassingController = TextEditingController();
  final percentageController = TextEditingController();

  // Rx values for dropdowns
  final selectedGender = ''.obs;
  final selectedCategory = 'General'.obs;
  final selectedMedium = 'English'.obs;
  final selectedState = 'Tamil Nadu'.obs;
  final userId = ''.obs;
  final studentProfile = Rxn<StudentProfileModel>();

  final userName = ''.obs;
  final userEmail = ''.obs;
  final userRole = ''.obs;
  final userCreatedAt = ''.obs;

  final obscureCurrentPassword = true.obs;
  final obscureNewPassword = true.obs;
  final obscureConfirmPassword = true.obs;

  final isDarkMode = false.obs;
  final appVersion = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
    _loadThemeMode();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion.value = "v${packageInfo.version}+${packageInfo.buildNumber}";
    } catch (e) {
      appVersion.value = "v1.0.0";
    }
  }

  void _loadThemeMode() {
    final storage = Get.find<SecureStorageService>();
    storage.getThemeMode().then((mode) {
      if (mode != null) {
        isDarkMode.value = mode == 'dark';
      } else {
        isDarkMode.value = Get.isDarkMode;
      }
    });
  }

  Future<void> toggleTheme(bool value) async {
    isDarkMode.value = value;
    final mode = value ? 'dark' : 'light';
    final storage = Get.find<SecureStorageService>();
    await storage.setThemeMode(mode);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final response = await _repository.getProfile();
      if (response.statusCode == 200) {
        final data = response.data['data'];
        userId.value = data['id'] ?? '';
        userName.value = data['name'] ?? '';
        userEmail.value = data['email'] ?? '';
        userRole.value = data['role'] ?? '';
        userCreatedAt.value = data['createdAt'] ?? '';
        nameController.text = userName.value;
        if (userId.value.isNotEmpty && userRole.value == 'STUDENT') {
          await fetchStudentProfile(userId.value);
        }
      } else {
        AppToast.error('Failed to load profile details');
      }
    } catch (e) {
      AppToast.error('Error loading profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateName() async {
    final newName = nameController.text.trim();
    if (newName.isEmpty || newName.length < 2) {
      AppToast.validation('Name must be at least 2 characters long');
      return;
    }

    try {
      isUpdatingName.value = true;
      final response = await _repository.updateName(newName);
      if (response.statusCode == 200) {
        userName.value = newName;
        AppToast.success('Display name updated successfully');
      } else {
        AppToast.error('Failed to update display name');
      }
    } catch (e) {
      AppToast.error('Error updating name: $e');
    } finally {
      isUpdatingName.value = false;
    }
  }

  Future<void> changePassword() async {
    final currentPassword = currentPasswordController.text;
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmNewPasswordController.text;

    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      AppToast.validation('All password fields are required');
      return;
    }

    if (newPassword.length < 6) {
      AppToast.validation('New password must be at least 6 characters long');
      return;
    }

    if (newPassword != confirmPassword) {
      AppToast.validation('New passwords do not match');
      return;
    }

    try {
      isChangingPassword.value = true;
      final response = await _repository.changePassword(currentPassword, newPassword);
      if (response.statusCode == 200) {
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmNewPasswordController.clear();
        AppToast.success('Password changed successfully');
      } else {
        AppToast.error(response.data['message'] ?? 'Failed to change password');
      }
    } catch (e) {
      String msg = 'Error changing password: $e';
      if (e is DioException && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          msg = data['message'].toString();
        }
      }
      AppToast.error(msg);
    } finally {
      isChangingPassword.value = false;
    }
  }

  Future<void> logout() async {
    try {
      final apiClient = Get.find<ApiClient>();
      await apiClient.post(ApiConstants.logout);
    } catch (_) {}
    try {
      final storage = Get.find<SecureStorageService>();
      await storage.clearAll();
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      AppToast.error('Logout failed: $e');
    }
  }

  Future<void> fetchStudentProfile(String uid) async {
    try {
      studentProfileLoaded.value = false;
      final response = await _repository.getStudentProfile(uid);
      if (response.statusCode == 200) {
        final profileData = response.data['data'];
        if (profileData != null) {
          final profile = StudentProfileModel.fromJson(profileData);
          studentProfile.value = profile;
          selectedGender.value = profile.gender ?? '';
          if (profile.dob != null) {
            try {
              final parsed = DateTime.parse(profile.dob!);
              dobController.text = "${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}";
            } catch (_) {
              dobController.text = profile.dob!.split('T')[0];
            }
          } else {
            dobController.text = '';
          }
          bloodGroupController.text = profile.bloodGroup ?? '';
          aadhaarController.text = profile.aadhaarNumber ?? '';
          nationalityController.text = profile.nationality;
          selectedCategory.value = profile.category ?? 'General';

          mobileController.text = profile.mobileNumber ?? '';
          whatsappController.text = profile.whatsappNumber ?? '';
          emergencyController.text = profile.emergencyContact ?? '';
          parentNameController.text = profile.parentName ?? '';
          parentMobileController.text = profile.parentMobile ?? '';

          currentAddressController.text = profile.currentAddress ?? '';
          permanentAddressController.text = profile.permanentAddress ?? '';
          cityController.text = profile.city ?? '';
          districtController.text = profile.district ?? '';
          selectedState.value = profile.state;
          pinCodeController.text = profile.pinCode ?? '';

          qualificationController.text = profile.highestQualification ?? '';
          degreeController.text = profile.degree ?? '';
          collegeController.text = profile.college ?? '';
          yearOfPassingController.text = profile.yearOfPassing?.toString() ?? '';
          percentageController.text = profile.percentage?.toString() ?? '';
          selectedMedium.value = profile.mediumOfEducation ?? 'English';
        }
        studentProfileLoaded.value = true;
      }
    } catch (e) {
      debugPrint('Error fetching student profile: $e');
    }
  }

  Future<bool> updateStudentProfile({bool isOnboarding = false}) async {
    final mob = mobileController.text.trim();
    if (mob.isNotEmpty && mob.length != 10) {
      AppToast.validation('Mobile number must be exactly 10 digits');
      return false;
    }
    final wa = whatsappController.text.trim();
    if (wa.isNotEmpty && wa.length != 10) {
      AppToast.validation('WhatsApp number must be exactly 10 digits');
      return false;
    }
    final emg = emergencyController.text.trim();
    if (emg.isNotEmpty && wa.length != 10) {
      AppToast.validation('Emergency contact must be exactly 10 digits');
      return false;
    }
    final pmob = parentMobileController.text.trim();
    if (pmob.isNotEmpty && pmob.length != 10) {
      AppToast.validation('Parent mobile number must be exactly 10 digits');
      return false;
    }
    final pin = pinCodeController.text.trim();
    if (pin.isNotEmpty && pin.length != 6) {
      AppToast.validation('PIN Code must be exactly 6 digits');
      return false;
    }
    final aadh = aadhaarController.text.trim();
    if (aadh.isNotEmpty && aadh.length != 12) {
      AppToast.validation('Aadhaar number must be exactly 12 digits');
      return false;
    }

    try {
      isUpdatingStudentProfile.value = true;
      final currentProfile = studentProfile.value;

      final updatedProfile = StudentProfileModel(
        id: currentProfile?.id ?? '',
        userId: currentProfile?.userId ?? userId.value,
        studentId: currentProfile?.studentId ?? '',
        gender: selectedGender.value.isEmpty ? null : selectedGender.value,
        dob: dobController.text.isEmpty ? null : dobController.text,
        bloodGroup: bloodGroupController.text.trim().isEmpty ? null : bloodGroupController.text.trim(),
        aadhaarNumber: aadhaarController.text.trim().isEmpty ? null : aadhaarController.text.trim(),
        nationality: nationalityController.text.trim().isEmpty ? 'Indian' : nationalityController.text.trim(),
        category: selectedCategory.value.isEmpty ? 'General' : selectedCategory.value,
        mobileNumber: mobileController.text.trim().isEmpty ? null : mobileController.text.trim(),
        whatsappNumber: whatsappController.text.trim().isEmpty ? null : whatsappController.text.trim(),
        emergencyContact: emergencyController.text.trim().isEmpty ? null : emergencyController.text.trim(),
        parentName: parentNameController.text.trim().isEmpty ? null : parentNameController.text.trim(),
        parentMobile: parentMobileController.text.trim().isEmpty ? null : parentMobileController.text.trim(),
        currentAddress: currentAddressController.text.trim().isEmpty ? null : currentAddressController.text.trim(),
        permanentAddress: permanentAddressController.text.trim().isEmpty ? null : permanentAddressController.text.trim(),
        city: cityController.text.trim().isEmpty ? null : cityController.text.trim(),
        district: districtController.text.trim().isEmpty ? null : districtController.text.trim(),
        state: selectedState.value.isEmpty ? 'Tamil Nadu' : selectedState.value,
        pinCode: pinCodeController.text.trim().isEmpty ? null : pinCodeController.text.trim(),
        highestQualification: qualificationController.text.trim().isEmpty ? null : qualificationController.text.trim(),
        degree: degreeController.text.trim().isEmpty ? null : degreeController.text.trim(),
        college: collegeController.text.trim().isEmpty ? null : collegeController.text.trim(),
        yearOfPassing: yearOfPassingController.text.isEmpty ? null : int.tryParse(yearOfPassingController.text),
        percentage: percentageController.text.isEmpty ? null : double.tryParse(percentageController.text),
        mediumOfEducation: selectedMedium.value.isEmpty ? 'English' : selectedMedium.value,
      );

      final response = await _repository.updateStudentProfile(userId.value, updatedProfile.toJson());
      if (response.statusCode == 200) {
        if (isOnboarding) {
          final storage = Get.find<SecureStorageService>();
          await storage.setIsOnboardingCompleted(true);
          Get.offAllNamed(Routes.DASHBOARD);
        } else {
          AppToast.success('Profile updated successfully');
        }
        return true;
      } else {
        AppToast.error(response.data['message'] ?? 'Failed to update profile');
        return false;
      }
    } catch (e) {
      String msg = 'Error updating profile: $e';
      if (e is DioException && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          msg = data['message'].toString();
        }
      }
      AppToast.error(msg);
      return false;
    } finally {
      isUpdatingStudentProfile.value = false;
    }
  }

  Future<void> deleteAccount() async {
    isDeletingAccount.value = true;
    try {
      final response = await _repository.deleteAccount();
      if (response.statusCode == 200) {
        final storage = Get.find<SecureStorageService>();
        await storage.clearAll();
        AppToast.success('Account deleted successfully');
        Get.offAllNamed(Routes.LOGIN);
      } else {
        AppToast.error(response.data['message'] ?? 'Failed to delete account');
      }
    } catch (e) {
      String msg = 'Error deleting account: $e';
      if (e is DioException && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          msg = data['message'].toString();
        }
      }
      AppToast.error(msg);
    } finally {
      isDeletingAccount.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    
    dobController.dispose();
    bloodGroupController.dispose();
    aadhaarController.dispose();
    nationalityController.dispose();
    mobileController.dispose();
    whatsappController.dispose();
    emergencyController.dispose();
    parentNameController.dispose();
    parentMobileController.dispose();
    currentAddressController.dispose();
    permanentAddressController.dispose();
    cityController.dispose();
    districtController.dispose();
    pinCodeController.dispose();
    qualificationController.dispose();
    degreeController.dispose();
    collegeController.dispose();
    yearOfPassingController.dispose();
    percentageController.dispose();
    
    super.onClose();
  }
}

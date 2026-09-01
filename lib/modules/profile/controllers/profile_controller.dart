import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../repositories/profile_repository.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/toast_helper.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../app/routes/app_routes.dart';
import '../../../shared/models/student_profile_model.dart';
import '../../../main.dart';

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
      appVersion.value = "v1.0.2";
    }
  }

  void _loadThemeMode() {
    final storage = Get.find<SecureStorageService>();
    storage.getThemeMode().then((mode) {
      if (mode == 'dark') {
        isDarkMode.value = true;
      } else if (mode == 'system') {
        isDarkMode.value = PlatformDispatcher.instance.platformBrightness == Brightness.dark;
      } else {
        isDarkMode.value = false;
      }
    });
  }

  Future<void> toggleTheme(bool value) async {
    isDarkMode.value = value;
    final mode = value ? 'dark' : 'light';
    final storage = Get.find<SecureStorageService>();
    await storage.setThemeMode(mode);
    if (Get.isRegistered<ThemeController>()) {
      Get.find<ThemeController>().changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    } else {
      Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    }
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
        if (userId.value.isNotEmpty && UserRole.fromString(userRole.value).isStudent) {
          await fetchStudentProfile(userId.value);
        }
      } else {
        AppToast.error('Failed to load profile details');
      }
    } catch (e) {
      AppToast.error(AppErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to load profile details.'));
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
      AppToast.error(AppErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to update name'));
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
      AppToast.error(AppErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to change password'));
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
      AppToast.error(AppErrorHandler.getErrorMessage(e, defaultMessage: 'Logout failed'));
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

  bool validateDemographicsStep() {
    if (selectedGender.value.trim().isEmpty) {
      AppToast.validation('Please select your gender');
      return false;
    }
    if (dobController.text.trim().isEmpty) {
      AppToast.validation('Please select your date of birth');
      return false;
    }
    if (bloodGroupController.text.trim().isEmpty) {
      AppToast.validation('Please enter your blood group');
      return false;
    }
    final aadh = aadhaarController.text.trim();
    if (aadh.isEmpty) {
      AppToast.validation('Please enter your Aadhaar number');
      return false;
    }
    if (aadh.length != 12) {
      AppToast.validation('Aadhaar number must be exactly 12 digits');
      return false;
    }
    if (nationalityController.text.trim().isEmpty) {
      AppToast.validation('Please enter your nationality');
      return false;
    }
    if (selectedCategory.value.trim().isEmpty) {
      AppToast.validation('Please select your category');
      return false;
    }
    return true;
  }

  bool validateContactStep() {
    final mob = mobileController.text.trim();
    if (mob.isEmpty) {
      AppToast.validation('Please enter your mobile number');
      return false;
    }
    if (mob.length != 10) {
      AppToast.validation('Mobile number must be exactly 10 digits');
      return false;
    }

    final wa = whatsappController.text.trim();
    if (wa.isEmpty) {
      AppToast.validation('Please enter your WhatsApp number');
      return false;
    }
    if (wa.length != 10) {
      AppToast.validation('WhatsApp number must be exactly 10 digits');
      return false;
    }

    final emg = emergencyController.text.trim();
    if (emg.isEmpty) {
      AppToast.validation('Please enter an emergency contact number');
      return false;
    }
    if (emg.length != 10) {
      AppToast.validation('Emergency contact must be exactly 10 digits');
      return false;
    }

    final parentName = parentNameController.text.trim();
    if (parentName.isEmpty) {
      AppToast.validation('Please enter parent/guardian name');
      return false;
    }

    final pmob = parentMobileController.text.trim();
    if (pmob.isEmpty) {
      AppToast.validation('Please enter parent mobile number');
      return false;
    }
    if (pmob.length != 10) {
      AppToast.validation('Parent mobile number must be exactly 10 digits');
      return false;
    }

    return true;
  }

  bool validateAddressStep() {
    if (currentAddressController.text.trim().isEmpty) {
      AppToast.validation('Please enter current address');
      return false;
    }
    if (permanentAddressController.text.trim().isEmpty) {
      AppToast.validation('Please enter permanent address');
      return false;
    }
    if (cityController.text.trim().isEmpty) {
      AppToast.validation('Please enter city');
      return false;
    }
    if (districtController.text.trim().isEmpty) {
      AppToast.validation('Please enter district');
      return false;
    }
    if (selectedState.value.trim().isEmpty) {
      AppToast.validation('Please select state');
      return false;
    }
    final pin = pinCodeController.text.trim();
    if (pin.isEmpty) {
      AppToast.validation('Please enter PIN code');
      return false;
    }
    if (pin.length != 6) {
      AppToast.validation('PIN Code must be exactly 6 digits');
      return false;
    }
    return true;
  }

  bool validateEducationStep() {
    if (qualificationController.text.trim().isEmpty) {
      AppToast.validation('Please enter highest qualification');
      return false;
    }
    if (degreeController.text.trim().isEmpty) {
      AppToast.validation('Please enter degree');
      return false;
    }
    if (collegeController.text.trim().isEmpty) {
      AppToast.validation('Please enter college name');
      return false;
    }
    final yop = yearOfPassingController.text.trim();
    if (yop.isEmpty) {
      AppToast.validation('Please enter year of passing');
      return false;
    }
    final yopInt = int.tryParse(yop);
    if (yopInt == null || yop.length != 4 || yopInt < 1950 || yopInt > DateTime.now().year + 5) {
      AppToast.validation('Please enter a valid 4-digit year of passing');
      return false;
    }
    final pct = percentageController.text.trim();
    if (pct.isEmpty) {
      AppToast.validation('Please enter percentage or CGPA');
      return false;
    }
    final pctNum = double.tryParse(pct);
    if (pctNum == null || pctNum <= 0 || pctNum > 100) {
      AppToast.validation('Please enter a valid percentage (1-100) or CGPA');
      return false;
    }
    if (selectedMedium.value.trim().isEmpty) {
      AppToast.validation('Please select medium of education');
      return false;
    }
    return true;
  }

  bool validateAllSteps() {
    return validateDemographicsStep() &&
        validateContactStep() &&
        validateAddressStep() &&
        validateEducationStep();
  }

  Future<bool> updateStudentProfile({bool isOnboarding = false}) async {
    if (isOnboarding && !validateAllSteps()) {
      return false;
    }
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
    if (emg.isNotEmpty && emg.length != 10) {
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
      AppToast.error(
        AppErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to update profile. Please try again.'),
      );
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
      AppToast.error(
        AppErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to delete account. Please try again.'),
      );
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

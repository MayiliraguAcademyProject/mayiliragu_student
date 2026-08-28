import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:upgrader/upgrader.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/services/app_config_service.dart';
import '../../../../core/utils/version_comparator.dart';
import '../../../../core/widgets/update_required_dialog.dart';

class SplashController extends GetxController {
  final SecureStorageService _storage = Get.find<SecureStorageService>();
  final AppConfigService _configService = Get.find<AppConfigService>();

  final Upgrader upgrader = Upgrader(
    durationUntilAlertAgain: Duration.zero,
  );

  final versionText = 'Version ...'.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 1. Get installed app version info
    String installedVersion = '1.0.2';
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      installedVersion = packageInfo.version;
      versionText.value = 'Version $installedVersion';
    } catch (e) {
      Get.log('Error getting PackageInfo: $e');
    }

    // 2. Upgrader store check (Play Store / App Store)
    try {
      await upgrader.initialize();
      if (upgrader.isUpdateAvailable()) {
        Get.log('Upgrader: Update is available. Halting navigation to force update.');
        return;
      }
    } catch (e) {
      Get.log('Error during Upgrader check: $e');
    }

    // Delay slightly to give premium splash feel (minimum 1.5 seconds)
    final stopwatch = Stopwatch()..start();

    // 3. Fetch app config from backend (version gating check)
    final appConfig = await _configService.fetchAppConfig();

    if (appConfig != null && appConfig.requiredVersion != null && appConfig.apkDownloadUrl != null) {
      final bool isOutdated = VersionComparator.isVersionOutdated(
        installedVersion,
        appConfig.requiredVersion!,
      );

      Get.log('--- Version Check ---');
      Get.log('Installed Version: $installedVersion');
      Get.log('Required Version: ${appConfig.requiredVersion}');
      Get.log('Is Outdated: $isOutdated');
      Get.log('---------------------');

      if (isOutdated) {
        // Stop delay and show non-dismissible dialog
        Get.dialog(
          UpdateRequiredDialog(
            requiredVersion: appConfig.requiredVersion!,
            apkDownloadUrl: appConfig.apkDownloadUrl!,
            releaseNotes: appConfig.releaseNotes,
          ),
          barrierDismissible: false,
        );
        return;
      }
    }

    // 4. Normal navigation flow
    await _navigateNext(stopwatch);
  }

  Future<void> _navigateNext(Stopwatch stopwatch) async {
    const minDelayMs = 1500;
    final elapsedMs = stopwatch.elapsedMilliseconds;
    if (elapsedMs < minDelayMs) {
      await Future.delayed(Duration(milliseconds: minDelayMs - elapsedMs));
    }

    final token = await _storage.getAccessToken();
    final role = await _storage.getUserRole();
    final userRole = UserRole.fromString(role);
    final hasSeenOnboarding = await _storage.hasSeenOnboarding();

    String targetRoute = Routes.ONBOARDING;
    if (hasSeenOnboarding) {
      if (token != null && userRole.isStudent) {
        final onboardingCompleted = await _storage.isOnboardingCompleted();
        targetRoute = onboardingCompleted ? Routes.DASHBOARD : Routes.PROFILE_ONBOARDING;
      } else if (token != null && userRole.isGuest) {
        targetRoute = Routes.DASHBOARD;
      } else {
        targetRoute = Routes.LOGIN;
      }
    }

    Get.offAllNamed(targetRoute);
  }
}

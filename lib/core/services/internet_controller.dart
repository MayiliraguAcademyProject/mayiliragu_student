import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/no_internet_widget.dart';

class InternetController extends GetxController {
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnection();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _checkInitialConnection() async {
    final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    _updateConnectionStatus(results);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // If the list contains none or is empty, we are offline
    final bool isOffline = results.contains(ConnectivityResult.none) || results.isEmpty;

    if (isOffline) {
      if (!Get.isSnackbarOpen) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.rawSnackbar(
            titleText: const NoInternetWidget(),
            messageText: const SizedBox.shrink(),
            backgroundColor: Colors.transparent,
            isDismissible: false,
            duration: const Duration(days: 365),
            snackPosition: SnackPosition.BOTTOM,
            padding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
          );
        });
      }
    } else {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
    }
  }
}

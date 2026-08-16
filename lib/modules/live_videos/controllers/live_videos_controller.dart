import 'dart:async';
import 'package:get/get.dart';
import '../../../core/models/live_stream_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/toast_helper.dart';

class LiveVideosController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  final RxList<LiveStreamModel> liveStreams = <LiveStreamModel>[].obs;
  final RxBool isLoading = false.obs;

  Timer? _countdownTimer;

  // Active time for computing countdowns locally
  final Rx<DateTime> currentTime = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    fetchLiveStreams();
    // Start local timer ticking every second
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      currentTime.value = DateTime.now();
    });
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }

  Future<void> fetchLiveStreams() async {
    isLoading.value = true;
    try {
      final response = await _apiClient.dio.get(ApiConstants.liveStreams);
      if (response.data != null && response.data['status'] == 'success') {
        final list = response.data['data'] as List;
        liveStreams.value = list
            .map((json) => LiveStreamModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      Get.log('Error fetching live streams: $e');
      AppToast.error(AppStrings.failedToLoadLiveStreams);
    } finally {
      isLoading.value = false;
    }
  }

  // Getters for filtering streams based on scheduledStart time compared to current time
  List<LiveStreamModel> get activeStreams {
    final now = currentTime.value;
    return liveStreams.where((stream) {
      final startTime = stream.scheduledStartTime;
      final diff = startTime.difference(now);
      // Stream is "Live" if the start time is passed, but less than 2 hours ago
      return diff.inSeconds <= 0 && diff.inHours.abs() < 2;
    }).toList();
  }

  List<LiveStreamModel> get upcomingStreams {
    final now = currentTime.value;
    return liveStreams.where((stream) {
      return stream.scheduledStartTime.isAfter(now);
    }).toList();
  }

  List<LiveStreamModel> get recordedStreams {
    final now = currentTime.value;
    return liveStreams.where((stream) {
      final startTime = stream.scheduledStartTime;
      final diff = startTime.difference(now);
      // Deemed completed/recorded if scheduled time is older than 2 hours
      return diff.inSeconds < 0 && diff.inHours.abs() >= 2;
    }).toList();
  }

  // Countdown text generator for a given scheduled start time
  String getCountdown(DateTime startTime) {
    final now = currentTime.value;
    final diff = startTime.difference(now);

    if (diff.inSeconds <= 0) {
      if (diff.inHours.abs() < 2) {
        return AppStrings.liveNowUppercase;
      }
      return AppStrings.completed;
    }

    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    final List<String> parts = [];
    if (days > 0) parts.add('${days}d');
    if (hours > 0 || days > 0) parts.add('${hours}h');
    parts.add('${minutes}m');
    parts.add('${seconds}s');

    return '${AppStrings.startsIn} ${parts.join(' ')}';
  }

  // Helper to extract YouTube Video ID from standard YouTube URL
  String getYoutubeVideoId(String url) {
    if (url.isEmpty) return '';
    
    // Watch URL matching
    final watchRegExp = RegExp(r'[?&]v=([^&#]+)');
    final watchMatch = watchRegExp.firstMatch(url);
    if (watchMatch != null && watchMatch.group(1) != null) {
      return watchMatch.group(1)!;
    }

    // Short/Embed/Live URL matching
    final generalRegExp = RegExp(r'(?:youtu\.be\/|embed\/|live\/|v\/)([^?&#]+)');
    final generalMatch = generalRegExp.firstMatch(url);
    if (generalMatch != null && generalMatch.group(1) != null) {
      return generalMatch.group(1)!;
    }

    return '';
  }
}

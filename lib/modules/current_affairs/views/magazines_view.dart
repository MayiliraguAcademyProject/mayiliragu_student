import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/current_affairs_controller.dart';
import '../widgets/monthly_magazine_card.dart';

class MagazinesView extends StatefulWidget {
  const MagazinesView({super.key});

  @override
  State<MagazinesView> createState() => _MagazinesViewState();
}

class _MagazinesViewState extends State<MagazinesView> {
  @override
  void initState() {
    super.initState();
    Get.find<CurrentAffairsController>().fetchMagazines();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CurrentAffairsController>();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text("Monthly Compilation Magazines", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ),
      body: Obx(() {
        if (controller.isMagazinesLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.brandPurple));
        }

        if (controller.magazinesList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.book_outlined, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                const Text("No monthly magazines published yet.", style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.magazinesList.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, idx) {
            final mag = controller.magazinesList[idx];
            return MonthlyMagazineCard(magazine: mag);
          },
        );
      }),
    );
  }
}

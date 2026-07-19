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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0.5,
        title: Text("Monthly Compilation Magazines", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
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
                Icon(Icons.book_outlined, size: 48, color: colorScheme.onSurfaceVariant),
                const SizedBox(height: 12),
                Text("No monthly magazines published yet.", style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
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

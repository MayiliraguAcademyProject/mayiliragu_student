import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/current_affairs_controller.dart';
import '../widgets/important_date_card.dart';

class DatesView extends StatefulWidget {
  const DatesView({super.key});

  @override
  State<DatesView> createState() => _DatesViewState();
}

class _DatesViewState extends State<DatesView> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    Get.find<CurrentAffairsController>().fetchDates();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CurrentAffairsController>();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text("Important Calendar Dates", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: ['All', 'National', 'International', 'Commemorative'].map((type) {
                final isSelected = _selectedFilter == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      type,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.brandPurple,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: isSelected ? AppColors.brandPurple : Colors.grey.shade200),
                    onSelected: (val) {
                      setState(() {
                        _selectedFilter = type;
                      });
                      controller.fetchDates(type: type == 'All' ? null : type);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Events List
          Expanded(
            child: Obx(() {
              if (controller.isDatesLoading.value) {
                return const Center(child: CircularProgressIndicator(color: AppColors.brandPurple));
              }

              if (controller.datesList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_note, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text("No calendar events added yet.", style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: controller.datesList.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, idx) {
                  final dt = controller.datesList[idx];
                  return ImportantDateCard(date: dt);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

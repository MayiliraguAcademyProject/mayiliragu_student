import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/current_affairs_controller.dart';
import '../widgets/government_scheme_card.dart';

class SchemesView extends StatefulWidget {
  const SchemesView({super.key});

  @override
  State<SchemesView> createState() => _SchemesViewState();
}

class _SchemesViewState extends State<SchemesView> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    Get.find<CurrentAffairsController>().fetchSchemes();
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
        title: Text("Government Schemes Tracker", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: ['All', 'Central', 'State'].map((type) {
                final isSelected = _selectedFilter == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      "$type Schemes",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.brandPurple,
                    backgroundColor: colorScheme.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: isSelected ? AppColors.brandPurple : colorScheme.outline),
                    onSelected: (val) {
                      setState(() {
                        _selectedFilter = type;
                      });
                      controller.fetchSchemes(type: type == 'All' ? null : type);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Schemes List
          Expanded(
            child: Obx(() {
              if (controller.isSchemesLoading.value) {
                return const Center(child: CircularProgressIndicator(color: AppColors.brandPurple));
              }

              if (controller.schemesList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_balance_outlined, size: 48, color: colorScheme.onSurfaceVariant),
                      const SizedBox(height: 12),
                      Text("No government schemes added yet.", style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: controller.schemesList.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, idx) {
                  final sch = controller.schemesList[idx];
                  return GovernmentSchemeCard(scheme: sch);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

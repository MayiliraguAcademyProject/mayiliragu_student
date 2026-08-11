import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/study_materials_controller.dart';
import '../widgets/category_chip.dart';
import '../widgets/material_card.dart';
import 'study_material_detail_view.dart';

class StudyMaterialDashboardView extends GetView<StudyMaterialsController> {
  const StudyMaterialDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StudyMaterialsController>();

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0.5,
        title: Text(
          'Library Hub',
          style: AppTextStyles.heading.copyWith(fontSize: 20, color: colorScheme.onSurface),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark_outline, color: colorScheme.onSurface),
            onPressed: () {
              controller.fetchBookmarks();
              _showBookmarksSheet(context, controller);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchCategories();
          await controller.fetchMaterials();
          await controller.fetchBookmarks();
        },
        color: AppColors.brandPurple,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              _buildSearchBar(controller),
              const SizedBox(height: 20),

              // Categories Filter Header
              Text(
                "Categories",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),

              // Category chips list
              _buildCategoryFilters(controller),
              const SizedBox(height: 24),

              // Material items list header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Trending Resources",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Obx(() => Text(
                        "${controller.materialsList.length} items",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      )),
                ],
              ),
              const SizedBox(height: 12),

              // Materials List
              _buildMaterialsFeed(context, controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(StudyMaterialsController controller) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: TextField(
            onChanged: (val) {
              controller.searchQuery.value = val;
              controller.fetchMaterials();
            },
            decoration: InputDecoration(
              hintText: "Search notes, e-books, categories...",
              hintStyle: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
              prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            style: TextStyle(color: colorScheme.onSurface),
          ),
        );
      }
    );
  }

  Widget _buildCategoryFilters(StudyMaterialsController controller) {
    return SizedBox(
      height: 38,
      child: Obx(() {
        if (controller.isCategoriesLoading.value && controller.categoriesList.isEmpty) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        final categories = controller.categoriesList;
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Obx(() {
                final active = controller.selectedCategoryId.value.isEmpty;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CategoryChip(
                    label: "All Library",
                    isSelected: active,
                    onSelected: (selected) {
                      controller.selectedCategoryId.value = "";
                      controller.fetchMaterials();
                    },
                  ),
                );
              });
            }

            final cat = categories[index - 1];
            return Obx(() {
              final active = controller.selectedCategoryId.value == cat.id;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CategoryChip(
                  label: cat.name,
                  isSelected: active,
                  onSelected: (selected) {
                    controller.selectedCategoryId.value = cat.id;
                    controller.fetchMaterials();
                  },
                ),
              );
            });
          },
        );
      }),
    );
  }

  Widget _buildMaterialsFeed(BuildContext context, StudyMaterialsController controller) {
    return Obx(() {
      if (controller.isMaterialsLoading.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.brandPurple),
          ),
        );
      }

      if (controller.materialsList.isEmpty) {
        final colorScheme = Theme.of(context).colorScheme;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Column(
            children: [
              Icon(Icons.library_books_outlined, size: 48, color: colorScheme.onSurfaceVariant),
              const SizedBox(height: 12),
              Text(
                "No materials found in this category.",
                style: TextStyle(
                    fontSize: 12, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.materialsList.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final mat = controller.materialsList[index];
          return MaterialCard(
            material: mat,
            onTap: () => Get.to(() => StudyMaterialDetailView(materialId: mat.id)),
            onBookmarkTap: () => controller.toggleBookmark(mat.id),
          );
        },
      );
    });
  }

  void _showBookmarksSheet(BuildContext context, StudyMaterialsController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "My Saved Materials",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w900, color: colorScheme.onSurface),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Obx(() {
                  if (controller.bookmarksList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bookmark_outline, size: 40, color: colorScheme.onSurfaceVariant),
                          const SizedBox(height: 8),
                          Text("No saved resources yet.",
                              style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: controller.bookmarksList.length,
                    itemBuilder: (context, index) {
                      final mat = controller.bookmarksList[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: AppColors.brandPurple.withValues(alpha: 0.08),
                          child: const Icon(Icons.folder_zip, color: AppColors.brandPurple, size: 18),
                        ),
                        title: Text(
                          mat.title,
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          mat.category?.name ?? 'Material',
                          style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
                        ),
                        trailing: const Icon(Icons.chevron_right, size: 16),
                        onTap: () {
                          Navigator.pop(context);
                          Get.to(() => StudyMaterialDetailView(materialId: mat.id));
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

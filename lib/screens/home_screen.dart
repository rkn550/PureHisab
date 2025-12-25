import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purehisab/app/routes/app_pages.dart';
import '../app/utils/app_colors.dart';
import '../controllers/home_controller.dart';
import 'widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              _buildTabs(controller),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Obx(
                        () => controller.isSearchFocused
                            ? const SizedBox.shrink()
                            : _buildSummaryCard(controller),
                      ),
                      _buildSearchAndFilters(controller),
                      _buildCustomerSupplierList(controller),
                      const SizedBox(height: 100), // Space for FAB
                    ],
                  ),
                ),
              ),
            ],
          ),
          Obx(
            () => controller.showFilterModal
                ? _buildFilterModal(context, controller)
                : const SizedBox.shrink(),
          ),
        ],
      ),
      floatingActionButton: Obx(
        () => (controller.showFilterModal || controller.isSearchFocused)
            ? const SizedBox.shrink()
            : _buildFloatingActionButton(controller),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildTabs(HomeController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildTab(controller, 'CUSTOMERS', 0)),
          Expanded(child: _buildTab(controller, 'SUPPLIERS', 1)),
        ],
      ),
    );
  }

  Widget _buildTab(HomeController controller, String label, int index) {
    return Obx(
      () => CustomTabWidget(
        label: label,
        isSelected: controller.selectedTabIndex == index,
        onTap: () => controller.changeTab(index),
      ),
    );
  }

  Widget _buildSummaryCard(HomeController controller) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const .all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                spacing: 6,
                children: [
                  Row(
                    spacing: 4,
                    children: [
                      Icon(
                        Icons.arrow_upward,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 16,
                      ),
                      Text(
                        'You will give',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: .w500,
                        ),
                      ),
                    ],
                  ),

                  Obx(
                    () => Text(
                      '₹ ${_formatAmount(controller.amountToGive)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: .bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 50,
              margin: const .symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: .topCenter,
                  end: .bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.white.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                spacing: 6,
                children: [
                  Row(
                    spacing: 4,
                    children: [
                      Icon(
                        Icons.arrow_downward,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 16,
                      ),

                      Text(
                        'You will get',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: .w500,
                        ),
                      ),
                    ],
                  ),
                  Obx(
                    () => Text(
                      '₹ ${_formatAmount(controller.amountToGet)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: .bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(HomeController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: CustomSearchBar(
              focusNode: controller.searchFocusNode,
              hintText: 'Name, Mobile no.',
              searchQuery: controller.searchQuery.obs,
              onChanged: controller.updateSearchQuery,
              onClear: () {
                controller.updateSearchQuery('');
                controller.searchFocusNode.unfocus();
              },
            ),
          ),
          const SizedBox(width: 12),
          Obx(
            () => FilterButton(
              onTap: () => controller.toggleFilterModal(),
              isActive: controller.showFilterModal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerSupplierList(HomeController controller) {
    return Obx(() {
      final items = controller.getFilteredList();

      if (items.isEmpty) {
        return EmptyState(
          icon: Icons.person,
          message: controller.selectedTabIndex == 0
              ? 'Add supplier and manage your purchases'
              : 'Add customer and manage your sales',
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final name = item['name']?.toString() ?? '';
          final time = item['time']?.toString() ?? '';
          final amount = (item['amount'] as num).toDouble();
          final type = item['type']?.toString() ?? 'give';
          final hasRequest = item['hasRequest'] as bool? ?? false;
          final isGive = type == 'give';

          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (index * 50)),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: .circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    await Get.toNamed(
                      Routes.partiesDetails,
                      arguments: {'partyId': item['id']},
                    );
                    controller.refreshData();
                  },
                  borderRadius: .circular(12),
                  child: Padding(
                    padding: const .all(16),
                    child: Row(
                      children: [
                        _buildPartyAvatar(
                          photoUrl: item['photoUrl']?.toString(),
                          name: name,
                          isGive: isGive,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: .start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: .w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    time,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                      fontWeight: .w400,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: .end,
                          children: [
                            Container(
                              padding: const .symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: (isGive ? Colors.green : Colors.red)
                                    .withValues(alpha: 0.1),
                                borderRadius: .circular(8),
                              ),
                              child: Text(
                                '₹ ${_formatAmount(amount)}',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: .bold,
                                  color: isGive
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                ),
                              ),
                            ),
                            if (hasRequest) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const .symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primaryDark,
                                    ],
                                  ),
                                  borderRadius: .circular(6),
                                ),
                                child: const Text(
                                  'REQUEST',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: .bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildFloatingActionButton(HomeController controller) {
    return Obx(() {
      final isCustomerTab = controller.selectedTabIndex == 0;
      return Container(
        margin: const EdgeInsets.only(bottom: 16, right: 16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isCustomerTab
                  ? [const Color(0xFFE91E63), const Color(0xFFC2185B)]
                  : [Colors.green.shade600, Colors.green.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: .circular(28),
            boxShadow: [
              BoxShadow(
                color: (isCustomerTab ? const Color(0xFFE91E63) : Colors.green)
                    .withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: CustomExtendedFAB(
            icon: Icons.person_add,
            label: isCustomerTab ? 'ADD CUSTOMER' : 'ADD SUPPLIER',
            onPressed: () => _handleAddParty(controller),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
          ),
        ),
      );
    });
  }

  Widget _buildFilterModal(BuildContext context, HomeController controller) {
    return GestureDetector(
      onTap: () {
        controller.closeFilterModal();
      },
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {}, // Prevent closing when tapping inside modal
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: .circular(20),
                  topRight: .circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const .only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: .circular(2),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const .all(16),
                      child: Column(
                        crossAxisAlignment: .start,
                        children: [
                          const Text(
                            'Filter by',
                            style: TextStyle(fontSize: 16, fontWeight: .bold),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildFilterChip(controller, 'All'),
                              _buildFilterChip(controller, 'You will get'),
                              _buildFilterChip(controller, 'You will give'),
                              _buildFilterChip(controller, 'Settled'),
                              _buildFilterChip(controller, 'Due Today'),
                              _buildFilterChip(controller, 'Upcoming'),
                              _buildFilterChip(controller, 'No Due Date'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Sort by',
                            style: TextStyle(fontSize: 16, fontWeight: .bold),
                          ),
                          const SizedBox(height: 12),
                          _buildSortOption(controller, 'Most Recent'),
                          _buildSortOption(controller, 'Highest Amount'),
                          _buildSortOption(controller, 'By Name (A-Z)'),
                          _buildSortOption(controller, 'Oldest'),
                          _buildSortOption(controller, 'Least Amount'),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () {
                        controller.closeFilterModal();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const .symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'VIEW RESULT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: .bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(HomeController controller, String label) {
    return Obx(() {
      final isSelected = controller.selectedFilter == label;
      return FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => controller.selectFilter(label),
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontSize: 12,
        ),
        padding: const .symmetric(horizontal: 12, vertical: 8),
      );
    });
  }

  Widget _buildSortOption(HomeController controller, String label) {
    return Obx(() {
      final isSelected = controller.selectedSort == label;
      return InkWell(
        onTap: () => controller.selectSort(label),
        child: Container(
          padding: const .symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: .circle,
                  border: .all(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                  color: isSelected ? AppColors.primary : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      );
    });
  }

  String _formatAmount(double amount) {
    final formatter = amount.toStringAsFixed(0);
    final parts = formatter.split('.');
    final integerPart = parts[0];
    final reversed = integerPart.split('').reversed.join();
    final formatted = reversed.replaceAllMapped(
      RegExp(r'(\d{3})(?=\d)'),
      (match) => '${match.group(0)},',
    );
    return formatted.split('').reversed.join();
  }

  Future<void> _handleAddParty(HomeController controller) async {
    final partyType = controller.selectedTabIndex;
    final arguments = {'partyType': partyType};
    await Get.toNamed(Routes.contactList, arguments: arguments);
  }

  Widget _buildPartyAvatar({
    String? photoUrl,
    required String name,
    required bool isGive,
  }) {
    final gradientColors = isGive
        ? [Colors.green.shade400, Colors.green.shade600]
        : [Colors.red.shade400, Colors.red.shade600];

    if (photoUrl != null && photoUrl.isNotEmpty) {
      final photoFile = File(photoUrl);
      if (photoFile.existsSync()) {
        return Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (isGive ? Colors.green : Colors.red).withValues(
                  alpha: 0.3,
                ),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 28,
            backgroundImage: FileImage(photoFile),
            backgroundColor: gradientColors[0],
          ),
        );
      }
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (isGive ? Colors.green : Colors.red).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

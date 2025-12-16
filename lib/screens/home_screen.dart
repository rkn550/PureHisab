import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purehisab/app/routes/app_pages.dart';
import '../app/utils/app_colors.dart';
import '../controllers/home_controller.dart';

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
                        () => controller.isSearchFocused.value
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
            () => controller.showFilterModal.value
                ? _buildFilterModal(context, controller)
                : const SizedBox.shrink(),
          ),
          Obx(
            () => controller.showAccountModal.value
                ? _buildAccountModal(context, controller)
                : const SizedBox.shrink(),
          ),
        ],
      ),
      floatingActionButton: Obx(
        () =>
            (controller.showFilterModal.value ||
                controller.showAccountModal.value ||
                controller.isSearchFocused.value)
            ? const SizedBox.shrink()
            : _buildFloatingActionButton(controller),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildTabs(HomeController controller) {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          Expanded(child: _buildTab(controller, 'CUSTOMERS', 0)),
          Expanded(child: _buildTab(controller, 'SUPPLIERS', 1)),
        ],
      ),
    );
  }

  Widget _buildTab(HomeController controller, String label, int index) {
    return Obx(() {
      final isSelected = controller.selectedTab.value == index;
      return InkWell(
        onTap: () {
          controller.changeTab(index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSummaryCard(HomeController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You will give',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(
                  () => Text(
                    '₹ ${_formatAmount(controller.amountToGive.value)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 1,
            height: 40,
            child: CustomPaint(painter: _DottedLinePainter()),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You will get',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(
                  () => Text(
                    '₹ ${_formatAmount(controller.amountToGet.value)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(HomeController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Obx(() {
                final hasText = controller.searchQuery.value.isNotEmpty;
                return TextField(
                  focusNode: controller.searchFocusNode,
                  onChanged: (value) {
                    controller.updateSearchQuery(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Name, Mobile no.',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    prefixIcon: hasText
                        ? IconButton(
                            icon: Icon(
                              Icons.close,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: () {
                              controller.updateSearchQuery('');
                              controller.searchFocusNode.unfocus();
                            },
                          )
                        : Icon(
                            Icons.search,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  style: const TextStyle(fontSize: 14),
                );
              }),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () {
              controller.toggleFilterModal();
            },
            child: Column(
              children: [
                Icon(Icons.filter_list, color: AppColors.primary, size: 24),
                const SizedBox(height: 2),
                const Text(
                  'Filters',
                  style: TextStyle(fontSize: 10, color: AppColors.primary),
                ),
              ],
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
        return Container(
          margin: const EdgeInsets.all(32),
          child: Column(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                controller.selectedTab.value == 0
                    ? 'Add supplier and manage your purchases'
                    : 'Add customer and manage your sales',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
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

          return InkWell(
            onTap: () {
              Get.toNamed(
                Routes.customerDetail,
                arguments: {
                  'name': name,
                  'phone': item['phone']?.toString() ?? '',
                  'id': item['id']?.toString() ?? name,
                  'isCustomer': controller.selectedTab.value == 0,
                  'storeName': controller.storeName.value,
                },
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹ ${_formatAmount(amount)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isGive ? Colors.green : Colors.red,
                        ),
                      ),
                      if (hasRequest) ...[
                        const SizedBox(height: 4),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            minimumSize: const Size(0, 24),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'REQUEST',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildFloatingActionButton(HomeController controller) {
    return Obx(() {
      final isCustomerTab = controller.selectedTab.value == 0;
      return Container(
        margin: const EdgeInsets.only(bottom: 16, right: 16),
        child: FloatingActionButton.extended(
          onPressed: () {
            _handleAddParty(controller);
          },
          backgroundColor: isCustomerTab
              ? const Color(0xFFE91E63) // Magenta for customers
              : Colors.green, // Green for suppliers
          icon: const Icon(Icons.person_add, color: Colors.white),
          label: Text(
            isCustomerTab ? 'ADD CUSTOMER' : 'ADD SUPPLIER',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
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
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          const Text(
                            'Filter by',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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
                          const SizedBox(height: 24),
                          const Text(
                            'Sort by',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'VIEW RESULT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
      final isSelected = controller.selectedFilter.value == label;
      return FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          controller.selectFilter(label);
        },
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontSize: 12,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      );
    });
  }

  Widget _buildSortOption(HomeController controller, String label) {
    return Obx(() {
      final isSelected = controller.selectedSort.value == label;
      return InkWell(
        onTap: () {
          controller.selectSort(label);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
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

  Widget _buildAccountModal(BuildContext context, HomeController controller) {
    return GestureDetector(
      onTap: () {
        controller.closeAccountModal();
      },
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {}, // Prevent closing when tapping inside modal
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Account',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            controller.closeAccountModal();
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Obx(
                      () => ListView.builder(
                        shrinkWrap: true,
                        itemCount: controller.accountsList.length,
                        itemBuilder: (context, index) {
                          final account = controller.accountsList[index];
                          final name = account['name']?.toString() ?? '';
                          final customerCount =
                              account['customerCount'] as int? ?? 0;
                          final isSelected =
                              account['isSelected'] as bool? ?? false;

                          return InkWell(
                            onTap: () {
                              controller.selectAccount(index);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        name.isNotEmpty
                                            ? name
                                                  .split(' ')
                                                  .map(
                                                    (word) => word.isNotEmpty
                                                        ? word[0].toUpperCase()
                                                        : '',
                                                  )
                                                  .take(2)
                                                  .join()
                                            : '?',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$customerCount ${customerCount == 1 ? 'Customer' : 'Customers'}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle,
                                      color: AppColors.primary,
                                      size: 24,
                                    )
                                  else
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.grey.shade400,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () {
                        controller.closeAccountModal();
                        Get.toNamed(Routes.createAccount);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'CREATE NEW ACCOUNT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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

  // Helper method to format amount with commas
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
    final partyType = controller.selectedTab.value;
    final arguments = {'partyType': partyType};

    // Navigate directly to contact list screen
    // Permission dialog will be shown on the contact list screen
    await Get.toNamed(Routes.contactList, arguments: arguments);
  }
}

// Custom painter for dotted vertical line
class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    const dashHeight = 4.0;
    const dashSpace = 3.0;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/customer_detail_controller.dart';
import '../app/utils/app_colors.dart';
import '../app/routes/app_pages.dart';

class CustomerDetailScreen extends StatelessWidget {
  const CustomerDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CustomerDetailController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(controller),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSummaryCard(controller),
            _buildActionButtons(controller),
            _buildTransactionHistory(controller),
            const SizedBox(height: 100), // Space for bottom buttons
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActionButtons(controller),
    );
  }

  PreferredSizeWidget _buildAppBar(CustomerDetailController controller) {
    return AppBar(
      backgroundColor: AppColors.primaryDark,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      title: Obx(
        () => Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  controller.customerName.value.isNotEmpty
                      ? controller.customerName.value[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          controller.customerName.value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Obx(
                        () => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            controller.isCustomer.value
                                ? 'Customer'
                                : 'Supplier',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(
                        Routes.profile,
                        arguments: {
                          'name': controller.customerName.value,
                          'phone': controller.customerPhone.value,
                          'id': controller.customerId.value,
                          'isCustomer': controller.isCustomer.value,
                        },
                      );
                    },
                    child: const Text(
                      'View settings',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Obx(
          () => IconButton(
            icon: const Icon(Icons.phone, color: Colors.white),
            onPressed: controller.customerPhone.value.isNotEmpty
                ? () => controller.makePhoneCall()
                : null,
            tooltip: controller.customerPhone.value.isNotEmpty
                ? 'Call ${controller.customerPhone.value}'
                : 'No phone number available',
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(CustomerDetailController controller) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Obx(() {
          final willGet = controller.amountToGet.value > 0;
          final amount = willGet
              ? controller.amountToGet.value
              : controller.amountToGive.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    willGet ? Icons.arrow_downward : Icons.arrow_upward,
                    color: Colors.white.withOpacity(0.9),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    willGet ? 'You will get' : 'You will give',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '₹ ${_formatAmount(amount)}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.hasReminder.value
                              ? 'Collection reminder set'
                              : 'Set collection reminder',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (controller.hasReminder.value)
                        IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            controller.removeCollectionReminder();
                          },
                        )
                      else
                        TextButton(
                          onPressed: () {
                            _showDatePicker(controller);
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            minimumSize: const Size(0, 32),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'SET DATE',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildActionButtons(CustomerDetailController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(
            icon: Icons.picture_as_pdf,
            label: 'Report',
            onTap: controller.onReportTap,
          ),
          Obx(
            () => _buildActionButton(
              icon: Icons.message,
              label: 'SMS',
              onTap: controller.onSMSTap,
              isEnabled: controller.customerPhone.value.isNotEmpty,
            ),
          ),
          Obx(
            () => _buildActionButton(
              icon: Icons.chat,
              label: 'WhatsApp',
              onTap: controller.onWhatsAppTap,
              isEnabled: controller.customerPhone.value.isNotEmpty,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isEnabled = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isEnabled
                ? AppColors.primary.withOpacity(0.1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isEnabled ? AppColors.primary : Colors.grey.shade400,
                size: 26,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isEnabled ? AppColors.primary : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionHistory(CustomerDetailController controller) {
    return Obx(() {
      final grouped = controller.getGroupedTransactions();
      final sortedDates = grouped.keys.toList()
        ..sort((a, b) => b.compareTo(a)); // Most recent first

      if (grouped.isEmpty) {
        return Container(
          margin: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.receipt_long, size: 60, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'No transactions yet',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column headers
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'ENTRIES',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    'YOU GAVE',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    'YOU GOT',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Transactions grouped by date
          ...sortedDates.map((dateKey) {
            final transactions = grouped[dateKey]!;
            final firstTransaction = transactions.first;
            final date = firstTransaction['date'] as DateTime;
            final dateHeader = controller.formatDateHeader(date);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    dateHeader,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ...transactions.map((transaction) {
                  return _buildTransactionItem(controller, transaction);
                }),
              ],
            );
          }),
        ],
      );
    });
  }

  Widget _buildTransactionItem(
    CustomerDetailController controller,
    Map<String, dynamic> transaction,
  ) {
    final date = transaction['date'] as DateTime;
    final type = transaction['type'] as String;
    final amount = (transaction['amount'] as num).toDouble();
    final balance = (transaction['balance'] as num).toDouble();
    final note = transaction['note']?.toString() ?? '';
    final isGive = type == 'give';
    final time = controller.formatTransactionTime(date);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isGive
              ? Colors.red.withOpacity(0.2)
              : Colors.green.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${date.day} ${_getMonthName(date.month)} ${date.year.toString().substring(2)} • $time',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bal. ₹ ${_formatAmount(balance)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (note.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        note,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(
                width: 80,
                child: isGive
                    ? Text(
                        '₹ ${_formatAmount(amount)}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              SizedBox(
                width: 80,
                child: !isGive
                    ? Text(
                        '₹ ${_formatAmount(amount)}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionButtons(CustomerDetailController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: controller.onYouGaveTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'YOU GAVE ₹',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: controller.onYouGotTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'YOU GOT ₹',
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
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
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

  Future<void> _showDatePicker(CustomerDetailController controller) async {
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      controller.setCollectionReminder(picked);
    }
  }
}

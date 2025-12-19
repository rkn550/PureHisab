import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/customer_detail_controller.dart';
import '../app/utils/app_colors.dart';
import '../app/routes/app_pages.dart';
import 'widgets/widgets.dart';

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
      leading: CustomIconButton(
        icon: Icons.arrow_back,
        onPressed: () => Get.back(),
        iconColor: Colors.white,
        size: 48,
        backgroundColor: Colors.transparent,
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
                    fontWeight: .bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
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
                            fontWeight: .w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Obx(
                        () => Container(
                          padding: .symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: .circular(12),
                          ),
                          child: Text(
                            controller.isCustomer.value
                                ? 'Customer'
                                : 'Supplier',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: .w500,
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
          () => CustomIconButton(
            icon: Icons.phone,
            onPressed: controller.customerPhone.value.isNotEmpty
                ? () => controller.makePhoneCall()
                : null,
            iconColor: Colors.white,
            size: 48,
            backgroundColor: Colors.transparent,
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
      margin: .fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: .topLeft,
          end: .bottomRight,
        ),
        borderRadius: .circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: .all(16),
        child: Obx(() {
          final willGet = controller.amountToGet.value > 0;
          final amount = willGet
              ? controller.amountToGet.value
              : controller.amountToGive.value;

          return Column(
            crossAxisAlignment: .start,
            children: [
              Row(
                children: [
                  Icon(
                    willGet ? Icons.arrow_downward : Icons.arrow_upward,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    willGet ? 'You will get' : 'You will give',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: .w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '₹ ${_formatAmount(amount)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: .bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              Obx(
                () => InkWell(
                  onTap: controller.hasReminder.value
                      ? null
                      : () => _showDatePicker(controller),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: .symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: .circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: .all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: .circular(8),
                          ),
                          child: Icon(
                            Icons.calendar_today_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: .start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                controller.hasReminder.value
                                    ? 'Reminder Set'
                                    : 'Set Reminder',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: .w600,
                                ),
                              ),
                              if (controller.hasReminder.value) ...[
                                const SizedBox(height: 2),
                                Obx(() {
                                  if (controller
                                      .collectionReminderDate
                                      .value
                                      .isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  try {
                                    final parts = controller
                                        .collectionReminderDate
                                        .value
                                        .split('-');
                                    if (parts.length == 3) {
                                      final year = int.parse(parts[0]);
                                      final month = int.parse(parts[1]);
                                      final day = int.parse(parts[2]);
                                      final date = DateTime(year, month, day);
                                      return Text(
                                        controller.formatDateHeader(date),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white.withValues(
                                            alpha: 0.8,
                                          ),
                                          fontWeight: .w400,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    // Ignore parsing errors
                                  }
                                  return const SizedBox.shrink();
                                }),
                              ] else ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Tap to set collection date',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontWeight: .w400,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (controller.hasReminder.value)
                          CustomIconButton(
                            icon: Icons.close_rounded,
                            onPressed: () {
                              controller.removeCollectionReminder();
                            },
                            iconColor: Colors.white,
                            iconSize: 20,
                            size: 32,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.2,
                            ),
                          )
                        else
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                      ],
                    ),
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
      margin: .symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: .spaceAround,
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
        borderRadius: .circular(10),
        child: Container(
          padding: .symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isEnabled
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.grey.shade100,
            borderRadius: .circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              Icon(
                icon,
                color: isEnabled ? AppColors.primary : Colors.grey.shade400,
                size: 26,
              ),

              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: .w600,
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
          margin: .all(32),
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
        crossAxisAlignment: .start,
        children: [
          // Column headers
          Container(
            margin: .symmetric(horizontal: 16),
            padding: .symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'ENTRIES',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                      fontWeight: .w500,
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    'YOU GAVE',
                    textAlign: .right,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                      fontWeight: .w500,
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    'YOU GOT',
                    textAlign: .right,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                      fontWeight: .w500,
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
              crossAxisAlignment: .start,
              children: [
                Container(
                  margin: .symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    dateHeader,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: .w500,
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
      margin: .symmetric(horizontal: 16, vertical: 6),
      padding: .all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: .circular(12),
        border: Border.all(
          color: isGive
              ? Colors.red.withValues(alpha: 0.2)
              : Colors.green.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      '${date.day} ${_getMonthName(date.month)} ${date.year.toString().substring(2)} • $time',
                      style: const TextStyle(fontSize: 12, fontWeight: .w500),
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
                        textAlign: .right,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: .bold,
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
                        textAlign: .right,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: .bold,
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
      padding: .all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: PrimaryButton(
              text: 'YOU GAVE ₹',
              onPressed: controller.onYouGaveTap,
              height: 50,
              fontSize: 16,
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PrimaryButton(
              text: 'YOU GOT ₹',
              onPressed: controller.onYouGotTap,
              height: 50,
              fontSize: 16,
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
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

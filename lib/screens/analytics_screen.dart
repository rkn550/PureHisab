import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/analytics_controller.dart';
import '../app/utils/app_colors.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AnalyticsController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.refreshAnalytics();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards Section
                Padding(
                  padding: .all(16),
                  child: Column(
                    children: [
                      _buildSummaryCard(controller),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMiniCard(
                              'To Give',
                              controller.totalToGive.value,
                              Icons.arrow_upward,
                              Colors.red,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMiniCard(
                              'To Get',
                              controller.totalToGet.value,
                              Icons.arrow_downward,
                              Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Monthly & Weekly Stats
                Padding(
                  padding: .symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      const Text(
                        'This Month',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: .bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMiniCard(
                              'To Give',
                              controller.thisMonthToGive.value,
                              Icons.arrow_upward,
                              Colors.red,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMiniCard(
                              'To Get',
                              controller.thisMonthToGet.value,
                              Icons.arrow_downward,
                              AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildStatsCard(
                        'Total Transactions',
                        controller.thisMonthTransactions.value.toDouble(),
                        Icons.receipt_long,
                        AppColors.primary,
                        isCount: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Weekly Stats
                Padding(
                  padding: .symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      const Text(
                        'This Week',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: .bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMiniCard(
                              'You Got',
                              controller.thisWeekIncome.value,
                              Icons.arrow_downward,
                              AppColors.success,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMiniCard(
                              'You Gave',
                              controller.thisWeekExpense.value,
                              Icons.arrow_upward,
                              Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildStatsCard(
                        'Total Transactions',
                        controller.thisWeekTransactions.value.toDouble(),
                        Icons.receipt_long,
                        AppColors.primary,
                        isCount: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Top Customers
                Padding(
                  padding: .symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      const Text(
                        'Top Customers',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: .bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTopList(controller.topCustomers),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Top Suppliers
                Padding(
                  padding: .symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      const Text(
                        'Top Suppliers',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: .bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTopList(controller.topSuppliers),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(AnalyticsController controller) {
    return Obx(
      () => Container(
        padding: .all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: .topLeft,
            end: .bottomRight,
          ),
          borderRadius: .circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            const Text(
              'Total Balance',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: .w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.formatAmountFull(controller.totalBalance.value),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: .bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildBalanceItem(
                    'Customers',
                    controller.totalCustomers.value.toString(),
                    Icons.people_outline,
                  ),
                ),
                Expanded(
                  child: _buildBalanceItem(
                    'Suppliers',
                    controller.totalSuppliers.value.toString(),
                    Icons.business_outlined,
                  ),
                ),
                Expanded(
                  child: _buildBalanceItem(
                    'Transactions',
                    controller.totalTransactions.value.toString(),
                    Icons.receipt_long,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: .bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildMiniCard(
    String title,
    double value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: .all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: .circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: .start,
        spacing: 12,
        children: [
          Container(
            padding: .all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: .circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            spacing: 4,
            crossAxisAlignment: .start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: .w500,
                ),
              ),
              Text(
                _formatAmount(value),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: .bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(
    String title,
    double value,
    IconData icon,
    Color color, {
    bool isCount = false,
  }) {
    return Container(
      padding: .all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: .circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: .all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: .circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: .w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isCount ? value.toInt().toString() : _formatAmount(value),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: .bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopList(RxList<Map<String, dynamic>> items) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: .circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == items.length - 1;

            return Container(
              padding: .symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(
                        bottom: BorderSide(color: AppColors.border, width: 1),
                      ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color:
                          (item['type'] == 'give'
                                  ? Colors.red
                                  : AppColors.success)
                              .withValues(alpha: 0.1),
                      borderRadius: .circular(8),
                    ),
                    child: Icon(
                      item['type'] == 'give'
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: item['type'] == 'give'
                          ? Colors.red
                          : AppColors.success,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        Text(
                          item['name'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: .w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item['type'] == 'give' ? 'You gave' : 'You got',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatAmount((item['amount'] as num).toDouble()),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: .bold,
                      color: item['type'] == 'give'
                          ? Colors.red
                          : AppColors.success,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount == 0) {
      return '₹0';
    }
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }
}

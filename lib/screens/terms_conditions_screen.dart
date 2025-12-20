import 'package:flutter/material.dart';
import '../app/utils/app_colors.dart';
import 'widgets/widgets.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: .w700,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: .all(20),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            // _buildHeader(),
            // const SizedBox(height: 28),
            _buildIntroduction(),
            const SizedBox(height: 20),
            _buildUsagePolicy(),
            const SizedBox(height: 20),
            _buildDataResponsibility(),
            const SizedBox(height: 20),
            _buildServiceChanges(),
            const SizedBox(height: 20),
            _buildLimitationOfLiability(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget _buildHeader() {
  //   return Center(
  //     child: Column(
  //       spacing: 12,
  //       children: [
  //         const Text(
  //           'Terms & Conditions',
  //           style: TextStyle(
  //             fontSize: 24,
  //             fontWeight: .bold,
  //             color: AppColors.primary,
  //             letterSpacing: 1.2,
  //           ),
  //         ),
  //         Text(
  //           'Please read these terms carefully',
  //           style: TextStyle(
  //             fontSize: 16,
  //             color: AppColors.textSecondary,
  //             fontWeight: .w500,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildIntroduction() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: .start,
        spacing: 16,
        children: [
          Row(
            spacing: 10,
            children: [
              Container(
                padding: .all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: .circular(10),
                ),
                child: const Icon(
                  Icons.info_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const Text(
                'Agreement',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: .bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Text(
            'By using PureHisab, you agree to the following terms:',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsagePolicy() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: .start,
        spacing: 16,
        children: [
          Row(
            spacing: 10,
            children: [
              Container(
                padding: .all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: .circular(10),
                ),
                child: const Icon(
                  Icons.policy_rounded,
                  color: AppColors.success,
                  size: 24,
                ),
              ),
              const Text(
                'Usage Policy',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: .bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          _buildTermItem(
            icon: Icons.book_rounded,
            text:
                'The app is intended for personal and business bookkeeping only',
          ),
          _buildTermItem(
            icon: Icons.person_rounded,
            text: 'Users are responsible for all data entered into the app',
          ),
        ],
      ),
    );
  }

  Widget _buildDataResponsibility() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: .start,
        spacing: 16,
        children: [
          Row(
            spacing: 10,
            children: [
              Container(
                padding: .all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.15),
                  borderRadius: .circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_rounded,
                  color: AppColors.info,
                  size: 24,
                ),
              ),
              const Text(
                'Data Responsibility',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: .bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          _buildTermItem(
            icon: Icons.edit_rounded,
            text: 'All transaction records are user-generated',
          ),
          _buildTermItem(
            icon: Icons.warning_rounded,
            text:
                'PureHisab is not liable for losses due to incorrect data entry',
          ),
        ],
      ),
    );
  }

  Widget _buildServiceChanges() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: .start,
        spacing: 16,
        children: [
          Row(
            spacing: 10,
            children: [
              Container(
                padding: .all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: .circular(10),
                ),
                child: const Icon(
                  Icons.update_rounded,
                  color: AppColors.warning,
                  size: 24,
                ),
              ),
              const Text(
                'Service Changes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: .bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          _buildTermItem(
            icon: Icons.settings_rounded,
            text: 'App features and policies may be updated periodically',
          ),
          _buildTermItem(
            icon: Icons.check_circle_rounded,
            text:
                'Continued use of the app implies acceptance of updated terms',
          ),
        ],
      ),
    );
  }

  Widget _buildLimitationOfLiability() {
    return Container(
      padding: .all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.05),
        borderRadius: .circular(16),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: .start,
        spacing: 16,
        children: [
          Row(
            spacing: 10,
            children: [
              Container(
                padding: .all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.15),
                  borderRadius: .circular(10),
                ),
                child: const Icon(
                  Icons.gavel_rounded,
                  color: AppColors.error,
                  size: 24,
                ),
              ),
              const Text(
                'Limitation of Liability',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: .bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          _buildTermItem(
            icon: Icons.info_outline_rounded,
            text: 'PureHisab is provided "as is" without guarantees',
          ),
          _buildTermItem(
            icon: Icons.shield_outlined,
            text:
                'The company is not responsible for indirect or consequential damages',
          ),
        ],
      ),
    );
  }

  Widget _buildTermItem({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: .start,
      spacing: 12,
      children: [
        Container(
          padding: .all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: .circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

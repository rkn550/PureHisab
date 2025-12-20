import 'package:flutter/material.dart';
import '../app/utils/app_colors.dart';
import 'widgets/widgets.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            fontSize: 20,
            fontWeight: .w700,
            color: AppColors.error,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.error),
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
            _buildDataStorage(),
            const SizedBox(height: 20),
            _buildDataUsage(),
            const SizedBox(height: 20),
            _buildSecurity(),
            const SizedBox(height: 20),
            _buildImportantNote(),
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
  //         Container(
  //           padding: .all(16),
  //           decoration: BoxDecoration(
  //             color: AppColors.primary.withValues(alpha: 0.1),
  //             shape: BoxShape.circle,
  //           ),
  //           child: const Icon(
  //             Icons.privacy_tip_rounded,
  //             color: AppColors.primary,
  //             size: 40,
  //           ),
  //         ),
  //         const Text(
  //           'Privacy Policy',
  //           style: TextStyle(
  //             fontSize: 28,
  //             fontWeight: .bold,
  //             color: AppColors.primary,
  //             letterSpacing: 1.2,
  //           ),
  //         ),
  //         Text(
  //           'Your privacy matters to us',
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
                'Our Commitment',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: .bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Text(
            'PureHisab values user privacy and is committed to protecting personal and business data.',
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

  Widget _buildDataStorage() {
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
                  Icons.storage_rounded,
                  color: AppColors.success,
                  size: 24,
                ),
              ),
              const Text(
                'Data Storage',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: .bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          _buildPolicyItem(
            icon: Icons.phone_android_rounded,
            text: 'User data is primarily stored on the user\'s device',
          ),
          _buildPolicyItem(
            icon: Icons.cloud_rounded,
            text:
                'Cloud storage is used only for secure backup and synchronization',
          ),
          _buildPolicyItem(
            icon: Icons.shield_rounded,
            text: 'Data is never shared or sold to third parties',
          ),
        ],
      ),
    );
  }

  Widget _buildDataUsage() {
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
                  Icons.data_usage_rounded,
                  color: AppColors.info,
                  size: 24,
                ),
              ),
              const Text(
                'Data Usage',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: .bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          _buildPolicyItem(
            icon: Icons.apps_rounded,
            text: 'Data is used only to provide core app features',
          ),
          _buildPolicyItem(
            icon: Icons.verified_user_rounded,
            text: 'No data is accessed without user action or consent',
          ),
        ],
      ),
    );
  }

  Widget _buildSecurity() {
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
                  Icons.lock_rounded,
                  color: AppColors.warning,
                  size: 24,
                ),
              ),
              const Text(
                'Security',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: .bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          _buildPolicyItem(
            icon: Icons.vpn_key_rounded,
            text: 'Secure authentication mechanisms are implemented',
          ),
          _buildPolicyItem(
            icon: Icons.security_rounded,
            text:
                'Reasonable measures are taken to protect against unauthorized access',
          ),
        ],
      ),
    );
  }

  Widget _buildImportantNote() {
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
                  Icons.warning_rounded,
                  color: AppColors.error,
                  size: 24,
                ),
              ),
              const Text(
                'Important Note',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: .bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Container(
            padding: .all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: .circular(12),
            ),
            child: Row(
              crossAxisAlignment: .start,
              spacing: 12,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.error,
                  size: 24,
                ),
                Expanded(
                  child: Text(
                    'PureHisab never asks for OTPs, passwords, or sensitive personal information.',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                      height: 1.6,
                      fontWeight: .w500,
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

  Widget _buildPolicyItem({required IconData icon, required String text}) {
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

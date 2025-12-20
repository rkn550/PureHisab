import 'package:flutter/material.dart';
import '../app/utils/app_colors.dart';
import 'widgets/widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('About PureHisab'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: .all(20),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildDescription(),
            const SizedBox(height: 32),
            _buildFeatures(),
            const SizedBox(height: 32),
            _buildValues(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        spacing: 8,
        children: [
          const Text(
            'PureHisab',
            style: TextStyle(
              fontSize: 28,
              fontWeight: .bold,
              color: AppColors.primary,
              letterSpacing: 1.2,
            ),
          ),

          Text(
            'Simple & Reliable Digital Ledger',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: .w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: .start,
        spacing: 12,
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
                  Icons.description_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),

              const Text(
                'About',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: .bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          Text(
            'PureHisab is a simple and reliable digital ledger application designed to help individuals and small businesses manage their daily financial records efficiently.',
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

  Widget _buildFeatures() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: .start,
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
                  Icons.star_rounded,
                  color: AppColors.success,
                  size: 24,
                ),
              ),

              const Text(
                'Key Features',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: .bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildFeatureItem(
            icon: Icons.account_balance_wallet_rounded,
            title: 'Record Transactions',
            description:
                'Record money given and received with clarity and accuracy',
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.people_rounded,
            title: 'Manage Accounts',
            description: 'Manage customer and supplier accounts efficiently',
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.business_rounded,
            title: 'Multiple Businesses',
            description: 'Maintain multiple businesses in one app',
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.offline_bolt_rounded,
            title: 'Offline Support',
            description: 'Use the app offline with secure local storage',
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.cloud_sync_rounded,
            title: 'Secure Sync',
            description: 'Sync data securely when connected to the internet',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: .start,
      spacing: 10,
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
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: .w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildValues() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: .start,
        spacing: 12,
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
                  Icons.verified_rounded,
                  color: AppColors.info,
                  size: 24,
                ),
              ),

              const Text(
                'Our Values',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: .bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Text(
            'PureHisab focuses on ease of use, data safety, and transparency, enabling users to manage their accounts without complexity.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          _buildValueItem(icon: Icons.thumb_up_rounded, text: 'Ease of Use'),
          _buildValueItem(icon: Icons.lock_rounded, text: 'Data Safety'),
          _buildValueItem(icon: Icons.visibility_rounded, text: 'Transparency'),
        ],
      ),
    );
  }

  Widget _buildValueItem({required IconData icon, required String text}) {
    return Row(
      spacing: 12,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),

        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: .w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

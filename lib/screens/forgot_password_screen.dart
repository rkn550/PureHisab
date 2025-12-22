import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/utils/app_colors.dart';
import '../controllers/forgot_password_controller.dart';
import 'widgets/widgets.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ForgotPasswordController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Forgot Password',
          style: TextStyle(
            fontSize: 24,
            fontWeight: .bold,
            color: AppColors.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: KeyboardDismisser(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: .stretch,
                children: [
                  const SizedBox(height: 20),
                  _buildLogoSection(),
                  const SizedBox(height: 20),
                  _buildHeaderSection(),
                  const SizedBox(height: 20),
                  _buildEmailInput(controller),
                  const SizedBox(height: 20),
                  _buildResetButton(controller),
                  const SizedBox(height: 20),
                  _buildBackToLoginLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return const AppLogo();
  }

  Widget _buildHeaderSection() {
    return Text(
      'Enter your email address and we\'ll send you a link to reset your password.',
      style: TextStyle(fontSize: 16, color: AppColors.primary, height: 1.5),
    );
  }

  Widget _buildEmailInput(ForgotPasswordController controller) {
    return CustomTextField(
      controller: controller.emailController,
      label: 'Email',
      hintText: 'Enter your email address',
      keyboardType: .emailAddress,
      prefixIcon: const Padding(
        padding: .all(12),
        child: Icon(
          Icons.email_outlined,
          color: AppColors.textSecondary,
          size: 24,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!value.contains('@') || !value.contains('.')) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _buildResetButton(ForgotPasswordController controller) {
    return Obx(
      () => PrimaryButton(
        text: 'Send Reset Link',
        onPressed: controller.isLoading ? null : controller.onResetPassword,
        isLoading: controller.isLoading,
      ),
    );
  }

  Widget _buildBackToLoginLink() {
    return Center(
      child: GestureDetector(
        onTap: () => Get.back(),
        child: RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            children: [
              const TextSpan(text: 'Remember your password? '),
              TextSpan(
                text: 'Back to Login',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: .w600,
                  decoration: .underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

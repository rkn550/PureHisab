import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../app/utils/app_colors.dart';
import '../app/routes/app_pages.dart';
import 'widgets/widgets.dart';

class LogInScreen extends StatelessWidget {
  const LogInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: KeyboardDismisser(
          child: SingleChildScrollView(
            padding: .symmetric(horizontal: 24),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: .stretch,
                children: [
                  const SizedBox(height: 60),
                  _buildLogoSection(),
                  const SizedBox(height: 40),
                  _buildWelcomeSection(),
                  const SizedBox(height: 40),
                  _buildPhoneInput(controller, context),
                  const SizedBox(height: 30),
                  _buildContinueButton(controller, context),
                  const SizedBox(height: 20),
                  _buildTermsText(),
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

  Widget _buildWelcomeSection() {
    return const Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          'Welcome Back!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: .bold,
            color: AppColors.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneInput(LoginController controller, BuildContext context) {
    return CustomTextField(
      controller: controller.phoneController,
      label: 'Phone Number',
      hintText: 'Enter 10-digit mobile number',
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      prefixIcon: const Padding(
        padding: .all(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🇮🇳', style: TextStyle(fontSize: 20)),
            SizedBox(width: 6),
            Text(
              '+91',
              style: TextStyle(
                fontSize: 16,
                fontWeight: .w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 70, minHeight: 48),
      suffixIcon: Obx(
        () => controller.phoneNumber.value.isNotEmpty
            ? const Padding(
                padding: .all(8),
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 24,
                ),
              )
            : const SizedBox.shrink(),
      ),
      onChanged: (value) => controller.updatePhoneNumber(value),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your phone number';
        }
        if (value.length < 10) {
          return 'Phone number must be 10 digits';
        }
        return null;
      },
    );
  }

  Widget _buildContinueButton(
    LoginController controller,
    BuildContext context,
  ) {
    return Obx(
      () => PrimaryButton(
        text: 'Continue',
        onPressed: controller.isLoading.value ? null : controller.onContinue,
        isLoading: controller.isLoading.value,
      ),
    );
  }

  Widget _buildTermsText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          children: [
            const TextSpan(text: 'By continuing, you agree to our '),
            TextSpan(
              text: 'Terms of Service',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Get.toNamed(Routes.termsConditions);
                },
            ),
            const TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Get.toNamed(Routes.privacyPolicy);
                },
            ),
          ],
        ),
      ),
    );
  }
}

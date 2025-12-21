import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../app/utils/app_colors.dart';
import '../app/routes/app_pages.dart';
import '../controllers/signup_controller.dart';
import 'widgets/widgets.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'Create Account',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
        elevation: 0,
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLogoSection(),
                  const SizedBox(height: 20),
                  _buildHeaderSection(),
                  const SizedBox(height: 20),
                  _buildNameInput(controller),
                  const SizedBox(height: 10),
                  _buildEmailInput(controller),
                  const SizedBox(height: 10),
                  _buildPhoneInput(controller),
                  const SizedBox(height: 10),
                  _buildPasswordInput(controller),
                  const SizedBox(height: 10),
                  _buildConfirmPasswordInput(controller),
                  const SizedBox(height: 20),
                  _buildSignupButton(controller),
                  const SizedBox(height: 16),
                  _buildLoginLink(),
                  const SizedBox(height: 20),
                  _buildTermsText(),
                  const SizedBox(height: 20),
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
    return const Text(
      'Sign up to get started',
      style: TextStyle(fontSize: 16, color: AppColors.primary),
    );
  }

  Widget _buildNameInput(SignupController controller) {
    return CustomTextField(
      controller: controller.nameController,
      label: 'Full Name',
      hintText: 'Enter your full name',
      keyboardType: TextInputType.name,
      prefixIcon: const Padding(
        padding: EdgeInsets.all(12),
        child: Icon(
          Icons.person_outlined,
          color: AppColors.textSecondary,
          size: 24,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your name';
        }
        if (value.length < 2) {
          return 'Name must be at least 2 characters';
        }
        return null;
      },
    );
  }

  Widget _buildEmailInput(SignupController controller) {
    return CustomTextField(
      controller: controller.emailController,
      label: 'Email',
      hintText: 'Enter your email address',
      keyboardType: TextInputType.emailAddress,
      prefixIcon: const Padding(
        padding: EdgeInsets.all(12),
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

  Widget _buildPhoneInput(SignupController controller) {
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
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🇮🇳', style: TextStyle(fontSize: 20)),
            SizedBox(width: 6),
            Text(
              '+91',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 70, minHeight: 48),
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

  Widget _buildPasswordInput(SignupController controller) {
    return Obx(
      () => CustomTextField(
        controller: controller.passwordController,
        label: 'Password',
        hintText: 'Enter your password',
        obscureText: !controller.isPasswordVisible.value,
        prefixIcon: const Padding(
          padding: EdgeInsets.all(12),
          child: Icon(
            Icons.lock_outlined,
            color: AppColors.textSecondary,
            size: 24,
          ),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            controller.isPasswordVisible.value
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: AppColors.textSecondary,
            size: 24,
          ),
          onPressed: controller.togglePasswordVisibility,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your password';
          }
          if (value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildConfirmPasswordInput(SignupController controller) {
    return Obx(
      () => CustomTextField(
        controller: controller.confirmPasswordController,
        label: 'Confirm Password',
        hintText: 'Re-enter your password',
        obscureText: !controller.isConfirmPasswordVisible.value,
        prefixIcon: const Padding(
          padding: EdgeInsets.all(12),
          child: Icon(
            Icons.lock_outlined,
            color: AppColors.textSecondary,
            size: 24,
          ),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            controller.isConfirmPasswordVisible.value
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: AppColors.textSecondary,
            size: 24,
          ),
          onPressed: controller.toggleConfirmPasswordVisibility,
        ),
        validator: controller.validateConfirmPassword,
      ),
    );
  }

  Widget _buildSignupButton(SignupController controller) {
    return Obx(
      () => PrimaryButton(
        text: 'Sign Up',
        onPressed: controller.isLoading.value ? null : controller.onSignup,
        isLoading: controller.isLoading.value,
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          children: [
            const TextSpan(text: 'Already have an account? '),
            TextSpan(
              text: 'Login',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primary,
              ),
              recognizer: TapGestureRecognizer()..onTap = () => Get.back(),
            ),
          ],
        ),
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
                decorationColor: AppColors.primary,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => Get.toNamed(Routes.termsConditions),
            ),
            const TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primary,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => Get.toNamed(Routes.privacyPolicy),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import '../app/utils/app_colors.dart';
import '../app/routes/app_pages.dart';
import '../controllers/login_email_controller.dart';
import 'widgets/widgets.dart';

class LoginEmailScreen extends StatelessWidget {
  const LoginEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginEmailController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: KeyboardDismisser(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  _buildLogoSection(),
                  const SizedBox(height: 20),
                  _buildWelcomeSection(),
                  const SizedBox(height: 20),
                  _buildEmailInput(controller),
                  const SizedBox(height: 10),
                  _buildPasswordInput(controller),
                  const SizedBox(height: 12),
                  _buildForgotPasswordLink(),
                  const SizedBox(height: 20),
                  _buildLoginButton(controller),
                  const SizedBox(height: 16),
                  _buildCreateAccountLink(),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailInput(LoginEmailController controller) {
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

  Widget _buildPasswordInput(LoginEmailController controller) {
    return Obx(
      () => CustomTextField(
        controller: controller.passwordController,
        label: 'Password',
        hintText: 'Enter your password',
        obscureText: !controller.isPasswordVisible,
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
            controller.isPasswordVisible
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

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => Get.toNamed(Routes.forgotPassword),
        child: Text(
          'Forgot Password?',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(LoginEmailController controller) {
    return Obx(
      () => PrimaryButton(
        text: 'Login',
        onPressed: controller.isLoading ? null : controller.onLogin,
        isLoading: controller.isLoading,
      ),
    );
  }

  Widget _buildCreateAccountLink() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          children: [
            const TextSpan(text: "Don't have an account? "),
            TextSpan(
              text: 'Sign Up',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primary,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => Get.toNamed(Routes.signup),
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

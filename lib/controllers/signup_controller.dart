import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purehisab/app/routes/app_pages.dart';
import 'package:purehisab/data/services/auth_service.dart';

class SignupController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  get nameController => _nameController;
  get phoneNumberController => _phoneNumberController;
  get emailController => _emailController;
  get passwordController => _passwordController;
  get confirmPasswordController => _confirmPasswordController;
  get formKey => _formKey;

  final RxBool _isPasswordVisible = false.obs;
  final RxBool _isConfirmPasswordVisible = false.obs;
  final RxBool _isLoading = false.obs;

  bool get isPasswordVisible => _isPasswordVisible.value;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible.value;
  bool get isLoading => _isLoading.value;

  set isPasswordVisible(bool value) => _isPasswordVisible.value = value;
  set isConfirmPasswordVisible(bool value) =>
      _isConfirmPasswordVisible.value = value;
  set isLoading(bool value) => _isLoading.value = value;

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible = !isConfirmPasswordVisible;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!value.isEmail) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one capital letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one small letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your confirm password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (value.length != 10) {
      return 'Phone number must be 10 digits';
    }
    return null;
  }

  Future<void> onSignup() async {
    if (!formKey.currentState!.validate()) return;
    isLoading = true;
    try {
      final user = await _authService.createUser(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phoneNumber: phoneNumberController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (user != null) {
        // Show success message
        Get.snackbar(
          'Success',
          'Account Created Successfully. Please login to continue.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          duration: const Duration(seconds: 2),
        );

        // Navigate to login screen - user needs to login manually
        // Use Future.delayed to ensure UI is ready before navigation
        Future.delayed(const Duration(milliseconds: 100), () {
          if (Get.isRegistered<SignupController>()) {
            Get.offAllNamed(Routes.login);
          }
        });
      } else {
        Get.snackbar(
          'Signup Failed',
          'Failed to create account',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading = false;
    }
  }

  @override
  void onClose() {
    // Dispose controllers safely
    try {
      _nameController.dispose();
    } catch (e) {
      // Controller already disposed
    }
    try {
      _emailController.dispose();
    } catch (e) {
      // Controller already disposed
    }
    try {
      _phoneNumberController.dispose();
    } catch (e) {
      // Controller already disposed
    }
    try {
      _passwordController.dispose();
    } catch (e) {
      // Controller already disposed
    }
    try {
      _confirmPasswordController.dispose();
    } catch (e) {
      // Controller already disposed
    }
    super.onClose();
  }
}

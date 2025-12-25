import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purehisab/app/routes/app_pages.dart';
import 'package:purehisab/app/utils/snacks_bar.dart';
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

  void resetForm() {
    nameController.clear();
    emailController.clear();
    phoneNumberController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    formKey.currentState!.reset();
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
        resetForm();
        SnacksBar.showSnackbar(
          title: 'Success',
          message: 'Account Created Successfully. Please login to continue.',
          type: SnacksBarType.SUCCESS,
        );

        Future.delayed(const Duration(milliseconds: 100), () {
          if (Get.isRegistered<SignupController>()) {
            Get.offAllNamed(Routes.login);
          }
        });
      } else {
        SnacksBar.showSnackbar(
          title: 'Signup Failed',
          message: 'Failed to create account',
          type: SnacksBarType.ERROR,
        );
      }
    } catch (e) {
      SnacksBar.showSnackbar(
        title: 'Error',
        message: e.toString().replaceAll('Exception: ', ''),
        type: SnacksBarType.ERROR,
      );
    } finally {
      isLoading = false;
    }
  }

  @override
  void onClose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.onClose();
  }
}

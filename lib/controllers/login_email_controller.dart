import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purehisab/app/routes/app_pages.dart';
import 'package:purehisab/app/utils/snacks_bar.dart';
import 'package:purehisab/data/services/auth_service.dart';
import 'package:purehisab/data/services/session_service.dart';

class LoginEmailController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final SessionService _sessionService = Get.find<SessionService>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  get emailController => _emailController;
  get passwordController => _passwordController;
  get formKey => _formKey;

  final RxBool _isPasswordVisible = false.obs;
  final RxBool _isLoading = false.obs;

  bool get isPasswordVisible => _isPasswordVisible.value;
  bool get isLoading => _isLoading.value;

  set isPasswordVisible(bool value) => _isPasswordVisible.value = value;
  set isLoading(bool value) => _isLoading.value = value;

  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(milliseconds: 100), () {
      _checkIfAlreadyLoggedIn();
    });
  }

  void _checkIfAlreadyLoggedIn() {
    if (_sessionService.isLoggedIn) {
      Future.microtask(() {
        Get.offAllNamed(Routes.home, arguments: {'initialTab': 1});
      });
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
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
    return null;
  }

  Future<void> onLogin() async {
    if (!formKey.currentState!.validate()) return;
    isLoading = true;
    try {
      final user = await _authService.loginUser(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await _sessionService.saveSession(user);
      resetForm();
      SnacksBar.showSnackbar(
        title: 'Login Successful',
        message: 'Welcome back, ${user.name}',
        type: SnacksBarType.SUCCESS,
      );
      Future.microtask(() {
        Get.offAllNamed(Routes.home, arguments: {'initialTab': 1});
      });
    } catch (e) {
      SnacksBar.showSnackbar(
        title: 'Error',
        message: 'Failed to login. Please try again.',
        type: SnacksBarType.ERROR,
      );
    } finally {
      isLoading = false;
    }
  }

  void resetForm() {
    emailController.clear();
    passwordController.clear();
    formKey.currentState!.reset();
  }

  @override
  void onClose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.onClose();
  }
}

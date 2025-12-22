import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purehisab/app/routes/app_pages.dart';
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

  bool _isDisposed = false;

  @override
  void onInit() {
    super.onInit();
    // Delay the check to ensure UI is fully built
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_isDisposed) {
        _checkIfAlreadyLoggedIn();
      }
    });
  }

  void _checkIfAlreadyLoggedIn() {
    // Check if user is already logged in
    if (!_isDisposed && _sessionService.isLoggedIn) {
      // Navigate directly to home page
      Future.microtask(() {
        if (!_isDisposed) {
          Get.offAllNamed(Routes.home, arguments: {'initialTab': 1});
        }
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

      Get.snackbar(
        'Login Successful',
        'Welcome back, ${user.name}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        duration: const Duration(seconds: 2),
      );

      Future.microtask(() {
        Get.offAllNamed(Routes.home, arguments: {'initialTab': 1});
      });
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
    _isDisposed = true;
    // Dispose controllers safely
    try {
      _emailController.dispose();
    } catch (e) {
      // Controller already disposed or error occurred
      debugPrint('Error disposing emailController: $e');
    }
    try {
      _passwordController.dispose();
    } catch (e) {
      // Controller already disposed or error occurred
      debugPrint('Error disposing passwordController: $e');
    }
    super.onClose();
  }
}

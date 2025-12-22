import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purehisab/data/services/auth_service.dart';

class ForgotPasswordController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final RxBool _isLoading = false.obs;

  get emailController => _emailController;
  get formKey => _formKey;
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) => _isLoading.value = value;

  Future<void> onResetPassword() async {
    if (!formKey.currentState!.validate()) return;
    isLoading = true;
    try {
      await _authService.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      Get.snackbar(
        'Success',
        'Password reset link has been sent to ${emailController.text}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
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
    _emailController.dispose();
    super.onClose();
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final RxBool isLoading = false.obs;

  void onResetPassword() {
    if (formKey.currentState!.validate()) {
      // No integration - just validate
      isLoading.value = true;
      Future.delayed(const Duration(seconds: 2), () {
        isLoading.value = false;
        Get.snackbar(
          'Password Reset',
          'Password reset link has been sent to ${emailController.text}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          duration: const Duration(seconds: 3),
        );
        // Navigate back after showing message
        Future.delayed(const Duration(seconds: 1), () {
          Get.back();
        });
      });
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}

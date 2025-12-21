import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginEmailController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final RxBool isPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void onLogin() {
    if (formKey.currentState!.validate()) {
      // No integration - just validate
      isLoading.value = true;
      Future.delayed(const Duration(seconds: 1), () {
        isLoading.value = false;
        Get.snackbar(
          'Login',
          'Email: ${emailController.text}\nPassword: ${passwordController.text}',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      });
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

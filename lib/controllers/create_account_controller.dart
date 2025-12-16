import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';

class CreateAccountController extends GetxController {
  final nameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  Future<void> createAccount() async {
    if (formKey.currentState?.validate() ?? false) {
      final name = nameController.text.trim();
      if (name.isEmpty) {
        Get.snackbar(
          'Error',
          'Please enter a name',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
        return;
      }

      isLoading.value = true;

      try {
        // Simulate API call
        await Future.delayed(const Duration(milliseconds: 500));

        // Navigate back first to avoid widget rebuild conflicts
        Get.back();

        // Wait for navigation to complete, then update state
        await Future.delayed(const Duration(milliseconds: 100));

        // Get HomeController and add new account
        if (Get.isRegistered<HomeController>()) {
          final homeController = Get.find<HomeController>();
          homeController.addNewAccount(name);
        }

        // Show success message after state update
        Future.delayed(const Duration(milliseconds: 200), () {
          if (Get.isSnackbarOpen == false) {
            Get.snackbar(
              'Success',
              'Account created successfully',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green.shade100,
              colorText: Colors.green.shade900,
              duration: const Duration(seconds: 2),
            );
          }
        });
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to create account. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }
}

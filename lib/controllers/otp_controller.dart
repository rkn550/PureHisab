import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/routes/app_pages.dart';
import '../app/utils/app_colors.dart';

class OtpController extends GetxController {
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

  final RxBool isLoading = false.obs;
  final RxString phoneNumber = ''.obs;
  final RxString otp = ''.obs;
  final RxInt resendTimer = 60.obs;
  final RxBool canResend = false.obs;

  @override
  void onInit() {
    super.onInit();
    _getPhoneNumber();
    _startResendTimer();
    // Auto focus first field
    Future.delayed(const Duration(milliseconds: 300), () {
      focusNodes[0].requestFocus();
    });
  }

  void _startResendTimer() {
    canResend.value = false;
    resendTimer.value = 60;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (resendTimer.value > 0) {
        resendTimer.value--;
        return true;
      } else {
        canResend.value = true;
        return false;
      }
    });
  }

  void _getPhoneNumber() {
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      phoneNumber.value = args['phoneNumber'] ?? '';
    }
  }

  void updateOtp(String value, int index) {
    otp.value = otpControllers.map((controller) => controller.text).join();
    if (value.isNotEmpty && index < 5) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  bool validateOtp() {
    final enteredOtp = otpControllers
        .map((controller) => controller.text)
        .join();
    return enteredOtp.length == 6;
  }

  Future<void> verifyOtp() async {
    if (!validateOtp()) {
      Get.snackbar(
        'Invalid OTP',
        'Please enter a valid 6-digit OTP',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
      );
      return;
    }

    isLoading.value = true;

    try {
      // Simulate API call - Replace with actual API call
      // final enteredOtp = otpControllers.map((controller) => controller.text).join();
      await Future.delayed(const Duration(seconds: 1));

      // Navigate to home screen with current index
      Get.offAllNamed(
        Routes.home,
        arguments: {
          'initialTab': 1, // Home tab (Analytics=0, Home=1, Profile=2)
        },
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void resendOtp() {
    if (!canResend.value) return;

    // Clear all OTP fields
    for (var controller in otpControllers) {
      controller.clear();
    }
    otp.value = '';
    focusNodes[0].requestFocus();

    // Show success message
    Get.snackbar(
      'OTP Resent',
      'A new OTP has been sent to ${phoneNumber.value}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.successLight,
      colorText: AppColors.success,
      icon: const Icon(Icons.check_circle, color: AppColors.success),
    );

    // Restart timer
    _startResendTimer();
  }

  @override
  void onClose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.onClose();
  }
}

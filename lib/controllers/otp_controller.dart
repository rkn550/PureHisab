// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../app/routes/app_pages.dart';
// import '../app/utils/app_colors.dart';
// import '../data/services/auth_service.dart';

// class OtpController extends GetxController {
//   AuthService get _authService => Get.find<AuthService>();

//   final List<TextEditingController> otpControllers = List.generate(
//     6,
//     (index) => TextEditingController(),
//   );
//   final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

//   final RxBool isLoading = false.obs;
//   final RxString phoneNumber = ''.obs;
//   final RxString otp = ''.obs;
//   final RxInt resendTimer = 60.obs;
//   final RxBool canResend = false.obs;
//   final RxBool isResending = false.obs;
//   final RxString verificationId = ''.obs;
//   final RxInt resendToken = 0.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     _getPhoneNumber();
//     _getVerificationId();
//     _startResendTimer();
//     Future.delayed(const Duration(milliseconds: 300), () {
//       focusNodes[0].requestFocus();
//     });
//   }

//   void _getVerificationId() {
//     final args = Get.arguments;
//     if (args != null && args is Map<String, dynamic>) {
//       verificationId.value = args['verificationId'] as String? ?? '';
//       resendToken.value = args['resendToken'] as int? ?? 0;
//     }
//   }

//   void _startResendTimer() {
//     canResend.value = false;
//     resendTimer.value = 60;
//     Future.doWhile(() async {
//       await Future.delayed(const Duration(seconds: 1));
//       if (resendTimer.value > 0) {
//         resendTimer.value--;
//         return true;
//       } else {
//         canResend.value = true;
//         return false;
//       }
//     });
//   }

//   void _getPhoneNumber() {
//     final args = Get.arguments;
//     if (args != null && args is Map<String, dynamic>) {
//       phoneNumber.value = args['phoneNumber'] ?? '';
//     }
//   }

//   void updateOtp(String value, int index) {
//     if (value.isNotEmpty) {
//       otp.value = otpControllers.map((controller) => controller.text).join();
//       if (index < 5) {
//         focusNodes[index + 1].requestFocus();
//       }
//     } else {
//       if (otpControllers[index].text.isEmpty && index > 0) {
//         otpControllers[index - 1].clear();
//         focusNodes[index - 1].requestFocus();
//       }
//       otp.value = otpControllers.map((controller) => controller.text).join();
//     }
//   }

//   bool validateOtp() {
//     final enteredOtp = otpControllers
//         .map((controller) => controller.text)
//         .join();
//     return enteredOtp.length == 6;
//   }

//   Future<void> verifyOtp() async {
//     if (!validateOtp()) {
//       Get.snackbar(
//         'Invalid OTP',
//         'Please enter a valid 6-digit OTP',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Get.theme.colorScheme.errorContainer,
//         colorText: Get.theme.colorScheme.onErrorContainer,
//       );
//       return;
//     }

//     if (verificationId.value.isEmpty) {
//       Get.snackbar(
//         'Error',
//         'Verification ID not found. Please request a new OTP.',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Get.theme.colorScheme.errorContainer,
//         colorText: Get.theme.colorScheme.onErrorContainer,
//       );
//       return;
//     }

//     isLoading.value = true;

//     try {
//       final enteredOtp = otpControllers
//           .map((controller) => controller.text)
//           .join();

//       await _authService.verifyOtp(
//         verificationId: verificationId.value,
//         smsCode: enteredOtp,
//       );

//       Get.offAllNamed(Routes.home, arguments: {'initialTab': 1});
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         e.toString().replaceAll('Exception: ', ''),
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Get.theme.colorScheme.errorContainer,
//         colorText: Get.theme.colorScheme.onErrorContainer,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> resendOtp() async {
//     if (!canResend.value || isResending.value) return;
//     isResending.value = true;
//     try {
//       for (var controller in otpControllers) {
//         controller.clear();
//       }
//       otp.value = '';
//       for (var focusNode in focusNodes) {
//         focusNode.unfocus();
//       }
//       final result = await _authService.sendOtp(
//         phoneNumber.value,
//         resendToken: resendToken.value == 0 ? null : resendToken.value,
//       );
//       verificationId.value = result['verificationId'] as String? ?? '';
//       resendToken.value = result['resendToken'] as int? ?? 0;
//       Get.snackbar(
//         'OTP Resent',
//         'A new OTP has been sent to ${phoneNumber.value}',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: AppColors.successLight,
//         colorText: AppColors.success,
//         icon: const Icon(Icons.check_circle, color: AppColors.success),
//       );
//       _startResendTimer();
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         e.toString().replaceAll('Exception: ', ''),
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Get.theme.colorScheme.errorContainer,
//         colorText: Get.theme.colorScheme.onErrorContainer,
//       );
//     } finally {
//       isResending.value = false;
//     }
//   }

//   @override
//   void onClose() {
//     for (var controller in otpControllers) {
//       controller.dispose();
//     }
//     for (var node in focusNodes) {
//       node.dispose();
//     }
//     super.onClose();
//   }
// }

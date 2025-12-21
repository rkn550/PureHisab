// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:purehisab/app/routes/app_pages.dart';
// import 'package:purehisab/data/services/auth_service.dart';

// class LoginController extends GetxController {
//   AuthService get _authService => Get.find<AuthService>();
//   final phoneController = TextEditingController();
//   final formKey = GlobalKey<FormState>();
//   final RxBool isLoading = false.obs;
//   final RxString phoneNumber = ''.obs;
//   static const String countryCode = '+91';

//   @override
//   void onInit() {
//     super.onInit();
//     // Firebase auth state checking removed
//   }

//   void updatePhoneNumber(String value) {
//     phoneNumber.value = value;
//   }

//   Future<void> onContinue() async {
//     if (!formKey.currentState!.validate()) return;
//     isLoading.value = true;
//     try {
//       final result = await _authService.sendOtp(
//         '$countryCode${phoneNumber.value}',
//       );
//       Get.toNamed(
//         Routes.otp,
//         arguments: {
//           'phoneNumber': '$countryCode${phoneNumber.value}',
//           'verificationId': result['verificationId'],
//           'resendToken': result['resendToken'],
//         },
//       );
//     } catch (e) {
//       Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   @override
//   void onClose() {
//     _authStateSubscription?.cancel();
//     phoneController.dispose();
//     super.onClose();
//   }
// }

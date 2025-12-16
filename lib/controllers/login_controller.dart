import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purehisab/app/routes/app_pages.dart';
import 'package:purehisab/data/services/auth_service.dart';

class LoginController extends GetxController {
  final AuthService _authService = AuthService();

  final phoneController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final RxBool isLoading = false.obs;
  final RxString phoneNumber = ''.obs;

  static const String countryCode = '+91';

  void updatePhoneNumber(String value) {
    phoneNumber.value = value;
  }

  Future<void> onContinue() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final verificationId = await _authService.sendOtp(
        '$countryCode${phoneNumber.value}',
      );

      Get.toNamed(
        Routes.otp,
        arguments: {
          'phoneNumber': '$countryCode${phoneNumber.value}',
          'verificationId': verificationId,
        },
      );
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}

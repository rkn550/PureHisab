import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/services/app_lock_service.dart';
import '../app/routes/app_pages.dart';
import 'app_lifecycle_controller.dart';

class AppLockController extends GetxController {
  AppLockService get _appLockService => Get.find<AppLockService>();
  final TextEditingController pinController = TextEditingController();
  final FocusNode pinFocusNode = FocusNode();
  final RxString enteredPin = ''.obs;
  final RxBool isAuthenticating = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    pinController.dispose();
    pinFocusNode.dispose();
    super.onClose();
  }

  void onPinDigitTap(String digit) {
    if (enteredPin.value.length < 4) {
      enteredPin.value += digit;
      errorMessage.value = '';

      if (enteredPin.value.length == 4) {
        verifyPin();
      }
    }
  }

  void onBackspace() {
    if (enteredPin.value.isNotEmpty) {
      enteredPin.value = enteredPin.value.substring(
        0,
        enteredPin.value.length - 1,
      );
      errorMessage.value = '';
    }
  }

  Future<void> verifyPin() async {
    isAuthenticating.value = true;

    await Future.delayed(const Duration(milliseconds: 300));

    final isValid = await _appLockService.verifyPin(enteredPin.value);
    if (isValid) {
      onUnlockSuccess();
    } else {
      enteredPin.value = '';
      errorMessage.value = 'Incorrect PIN. Please try again.';
      isAuthenticating.value = false;
    }
  }

  void onUnlockSuccess() async {
    await _appLockService.onUnlockSuccess();
    if (Get.isRegistered<AppLifecycleController>()) {
      Get.find<AppLifecycleController>().onUnlockSuccess();
    }
    if (Get.currentRoute == Routes.appLock) {
      Get.offNamed(Routes.home, arguments: {'initialTab': 1});
    } else {
      Get.back();
    }
  }
}

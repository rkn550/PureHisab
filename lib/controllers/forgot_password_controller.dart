import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purehisab/app/utils/snacks_bar.dart';
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
      resetForm();
      SnacksBar.showSnackbar(
        title: 'Success',
        message: 'Password reset link has been sent to ${emailController.text}',
        type: SnacksBarType.SUCCESS,
      );
    } catch (e) {
      SnacksBar.showSnackbar(
        title: 'Error',
        message: e.toString().replaceAll('Exception: ', ''),
        type: SnacksBarType.ERROR,
      );
    } finally {
      isLoading = false;
    }
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

  void resetForm() {
    emailController.clear();
    formKey.currentState!.reset();
  }

  @override
  void onClose() {
    _emailController.dispose();
    super.onClose();
  }
}

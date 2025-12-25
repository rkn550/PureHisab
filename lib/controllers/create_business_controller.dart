import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purehisab/app/utils/snacks_bar.dart';
import 'package:purehisab/data/services/business_repo.dart';
import 'navigation_controller.dart';

class CreateBusinessController extends GetxController {
  final BusinessRepository _businessRepository = Get.find<BusinessRepository>();
  final TextEditingController _businessNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final RxBool _isLoading = false.obs;

  TextEditingController get businessNameController => _businessNameController;
  GlobalKey<FormState> get formKey => _formKey;
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) => _isLoading.value = value;

  Future<void> createBusiness() async {
    if (!formKey.currentState!.validate()) return;
    isLoading = true;

    try {
      await _businessRepository.createBusiness(
        businessName: businessNameController.text.trim(),
      );

      Get.back(result: true);

      try {
        if (Get.isRegistered<NavigationController>()) {
          final navController = Get.find<NavigationController>();
          await navController.loadBusinessesFromDatabase();
          if (navController.businesses.isNotEmpty) {
            navController.businessId = navController.businesses.last.id;
          }
        }
      } catch (e) {}

      await Future.delayed(const Duration(milliseconds: 300));
      SnacksBar.showSnackbar(
        title: 'Success',
        message: 'Business created successfully',
        type: SnacksBarType.SUCCESS,
      );
    } catch (e) {
      SnacksBar.showSnackbar(
        title: 'Error',
        message:
            'Failed to create business: ${e.toString().replaceAll('Exception: ', '')}',
        type: SnacksBarType.ERROR,
      );
    } finally {
      isLoading = false;
    }
  }

  String? validateBusinessName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a business name';
    }
    if (value.trim().length < 2) {
      return 'Business name must be at least 2 characters';
    }
    return null;
  }

  @override
  void onClose() {
    _businessNameController.dispose();
    super.onClose();
  }
}

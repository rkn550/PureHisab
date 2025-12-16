import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';

class AddPartyController extends GetxController {
  final partyNameController = TextEditingController();
  final mobileController = TextEditingController();
  final addressController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  final RxBool isLoading = false.obs;
  final RxString partyType = 'Customer'.obs; // 'Customer' or 'Supplier'
  final RxBool showGstinAddress = false.obs;

  // Party type from navigation (0 = Customer, 1 = Supplier)
  int? initialPartyType;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      // Set party type based on tab (0 = Customer, 1 = Supplier)
      initialPartyType = args['partyType'] as int?;
      if (initialPartyType == 1) {
        partyType.value = 'Supplier';
      } else {
        // Explicitly set Customer if partyType is 0 or null
        partyType.value = 'Customer';
      }

      // Pre-fill contact data if available
      if (args.containsKey('contactName')) {
        final contactName = args['contactName'] as String? ?? '';
        if (contactName.isNotEmpty && contactName != 'Unknown') {
          partyNameController.text = contactName;
        }
      }
      if (args.containsKey('contactNumber')) {
        final contactNumber = args['contactNumber'] as String? ?? '';
        if (contactNumber.isNotEmpty) {
          // Clean the number (remove non-digits) before setting
          final cleaned = contactNumber.replaceAll(RegExp(r'[^\d]'), '');
          mobileController.text = cleaned;
        }
      }
    }
  }

  @override
  void onClose() {
    partyNameController.dispose();
    mobileController.dispose();
    addressController.dispose();
    super.onClose();
  }

  void togglePartyType(String type) {
    partyType.value = type;
  }

  void toggleGstinAddress() {
    showGstinAddress.value = !showGstinAddress.value;
  }

  Future<void> addParty() async {
    if (formKey.currentState?.validate() ?? false) {
      isLoading.value = true;

      try {
        // Simulate API call
        await Future.delayed(const Duration(milliseconds: 500));

        // Get HomeController and add new party
        if (Get.isRegistered<HomeController>()) {
          final homeController = Get.find<HomeController>();

          // Build party data with all collected information
          final newParty = <String, dynamic>{
            'name': partyNameController.text.trim(),
            'mobile': mobileController.text.trim(),
            'time': 'Just now',
            'amount': 0.0,
            'type': partyType.value == 'Customer' ? 'give' : 'get',
            'hasRequest': false,
          };

          // Add address if provided
          final address = addressController.text.trim();
          if (address.isNotEmpty) {
            newParty['address'] = address;
          }

          // Add to appropriate list
          if (partyType.value == 'Customer') {
            homeController.customersList.add(newParty);
          } else {
            homeController.suppliersList.add(newParty);
          }

          // Update summary amounts
          homeController.updateSummaryAmounts();

          // Clear form after successful addition
          _clearForm();
        }

        // Navigate back to home screen
        // Pop all routes until we're back at home
        Get.until((route) => route.isFirst);

        // Show success message
        Future.delayed(const Duration(milliseconds: 300), () {
          if (Get.isSnackbarOpen == false) {
            Get.snackbar(
              'Success',
              '${partyType.value} added successfully',
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
          'Failed to add ${partyType.value}. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  String? validatePartyName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter party name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? validateMobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter mobile number';
    }
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length != 10) {
      return 'Please enter a valid 10-digit mobile number';
    }
    return null;
  }

  // Clear form fields
  void _clearForm() {
    partyNameController.clear();
    mobileController.clear();
    addressController.clear();
    showGstinAddress.value = false;
  }
}

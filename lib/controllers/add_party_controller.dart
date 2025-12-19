import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purehisab/data/services/party_repo.dart';
import 'home_controller.dart';

class AddPartyController extends GetxController {
  PartyRepository get _partyRepository => Get.find<PartyRepository>();

  final partyNameController = TextEditingController();
  final mobileController = TextEditingController();
  final addressController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  final RxBool isLoading = false.obs;
  final RxString partyType = 'Customer'.obs;
  final RxBool showGstinAddress = false.obs;

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
        if (!Get.isRegistered<HomeController>()) {
          throw Exception('HomeController not found');
        }

        final homeController = Get.find<HomeController>();
        if (homeController.selectedBusinessId.value.isEmpty) {
          throw Exception('No business selected');
        }

        await _partyRepository.createParty(
          businessId: homeController.selectedBusinessId.value,
          partyName: partyNameController.text.trim(),
          type: partyType.value == 'Customer' ? 'customer' : 'supplier',
          phoneNumber: mobileController.text.trim().isNotEmpty
              ? mobileController.text.trim()
              : null,
          address: addressController.text.trim().isNotEmpty
              ? addressController.text.trim()
              : null,
        );

        await homeController.loadPartiesFromDatabase();

        _clearForm();

        Get.until((route) => route.isFirst);

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
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        Get.snackbar(
          'Error',
          errorMessage.isNotEmpty
              ? errorMessage
              : 'Failed to add ${partyType.value}. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          duration: const Duration(seconds: 4),
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

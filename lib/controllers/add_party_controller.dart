import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purehisab/app/routes/app_pages.dart';
import 'package:purehisab/app/utils/snacks_bar.dart';
import 'package:purehisab/controllers/navigation_controller.dart';
import 'package:purehisab/controllers/home_controller.dart';
import 'package:purehisab/data/services/party_repo.dart';

class AddPartyController extends GetxController {
  PartyRepository get _partyRepository => Get.find<PartyRepository>();

  final _partyNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  TextEditingController get partyNameController => _partyNameController;
  TextEditingController get mobileController => _mobileController;
  TextEditingController get addressController => _addressController;

  final _formKey = GlobalKey<FormState>();
  GlobalKey<FormState> get formKey => _formKey;
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  final RxString _partyType = 'customer'.obs;
  String get partyType => _partyType.value;
  final RxBool _showGstinAddress = false.obs;
  bool get showGstinAddress => _showGstinAddress.value;

  @override
  void onInit() {
    super.onInit();
    getArguments();
  }

  @override
  void onClose() {
    _partyNameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    super.onClose();
  }

  void getArguments() {
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      _partyType.value = args['partyType']?.toString() ?? 'customer';
      _partyNameController.text = args['partyName']?.toString() ?? '';
      _mobileController.text = args['mobile']?.toString() ?? '';
    }
  }

  void togglePartyType(String type) {
    debugPrint('togglePartyType: $type');
    _partyType.value = type;
  }

  void toggleGstinAddress() {
    _showGstinAddress.value = !_showGstinAddress.value;
  }

  Future<void> addParty() async {
    if (!_formKey.currentState!.validate()) return;
    _isLoading.value = true;

    try {
      final party = await _partyRepository.createParty(
        businessId: Get.find<NavigationController>().businessId,
        partyName: _partyNameController.text.trim(),
        type: partyType == 'customer' ? 'customer' : 'supplier',
        phoneNumber: _mobileController.text.trim(),
        address: _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
      );
      _clearForm();

      await Get.toNamed(
        Routes.partiesDetails,
        arguments: {'partyId': party.id, 'partyType': party.type},
      );

      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        homeController.refreshData();
      }

      Future.delayed(const Duration(milliseconds: 300), () {
        if (Get.isSnackbarOpen == false) {
          SnacksBar.showSnackbar(
            title: 'Success',
            message: '$partyType added successfully',
            type: SnacksBarType.SUCCESS,
          );
        }
      });
    } catch (e) {
      SnacksBar.showSnackbar(
        title: 'Error',
        message: 'Failed to add $partyType. Please try again.',
        type: SnacksBarType.ERROR,
      );
    } finally {
      _isLoading.value = false;
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

  void _clearForm() {
    _partyNameController.clear();
    _mobileController.clear();
    _addressController.clear();
    _showGstinAddress.value = false;
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purehisab/data/model/business_model.dart';
import 'package:purehisab/data/services/business_repo.dart';
import 'package:purehisab/data/services/party_repo.dart';
import 'package:purehisab/screens/main_navigation_screen.dart';

class NavigationController extends GetxController {
  final BusinessRepository _businessRepository = Get.find<BusinessRepository>();
  final PartyRepository _partyRepository = Get.find<PartyRepository>();

  final RxInt _currentIndex = 0.obs;
  int get currentIndex => _currentIndex.value;

  final RxList<BusinessModel> _businesses = <BusinessModel>[].obs;
  List<BusinessModel> get businesses => _businesses;

  final RxString _businessId = ''.obs;
  String get businessId => _businessId.value;
  set businessId(String value) => _businessId.value = value;
  RxString get businessIdRx => _businessId;

  final RxMap<String, int> _customerCounts = <String, int>{}.obs;
  int getCustomerCount(String businessId) => _customerCounts[businessId] ?? 0;

  @override
  void onInit() {
    super.onInit();
    loadBusinessesFromDatabase();
  }

  void setInitialTab(int index) {
    if (index >= 0 && index <= 2) _currentIndex.value = index;
  }

  Future<void> loadBusinessesFromDatabase() async {
    final businesses = await _businessRepository.getBusinesses();
    _businesses.assignAll(businesses);
    if (businesses.isNotEmpty) {
      if (Get.isBottomSheetOpen == true) {
        Get.back();
      }
      await loadCustomerCounts();
      if (_businessId.value.isEmpty) {
        _businessId.value = businesses.first.id;
      }
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.isBottomSheetOpen != true) {
          _showCreateBusinessBottomSheet();
        }
      });
    }
  }

  void _showCreateBusinessBottomSheet() {
    if (Get.isBottomSheetOpen == true) return;

    Get.bottomSheet(
      const CreateBusinessBottomSheet(),
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
    );
  }

  Future<void> loadCustomerCounts() async {
    for (var business in _businesses) await customerCount(business.id);
  }

  Future<void> customerCount(String businessId) async {
    try {
      final parties = await _partyRepository.getPartiesByType(
        businessId: businessId,
        type: 'customer',
      );
      _customerCounts[businessId] = parties.length;
    } catch (e) {
      _customerCounts[businessId] = 0;
    }
  }

  Future<void> openBusinessListBottomSheet() async {
    if (Get.isBottomSheetOpen == true) return;

    await loadCustomerCounts();
    await Get.bottomSheet(
      const BusinessListBottomSheet(),
      isScrollControlled: true,
      barrierColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
    );
  }
}

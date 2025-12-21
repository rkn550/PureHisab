import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purehisab/data/model/business_model.dart';
import 'package:purehisab/data/model/party_model.dart';
import 'package:purehisab/data/services/business_repo.dart';
import 'package:purehisab/data/services/party_repo.dart';
import 'package:purehisab/data/services/transaction_repo.dart';
import 'package:purehisab/app/routes/app_pages.dart';
import 'package:purehisab/app/utils/app_colors.dart';
import 'business_profile_controller.dart';

class HomeController extends GetxController {
  BusinessRepository get _businessRepository => Get.find<BusinessRepository>();
  PartyRepository get _partyRepository => Get.find<PartyRepository>();
  TransactionRepository get _transactionRepository =>
      Get.find<TransactionRepository>();

  final searchFocusNode = FocusNode();
  final RxInt selectedTab = 0.obs;

  final RxString selectedFilter = 'All'.obs;
  final RxString selectedSort = 'Most Recent'.obs;
  final RxBool showFilterModal = false.obs;

  final RxDouble amountToGive = 0.0.obs;
  final RxDouble amountToGet = 0.0.obs;

  final RxString storeName = ''.obs;
  final RxString selectedBusinessId = ''.obs;
  final RxBool showAccountModal = false.obs;

  final RxList<Map<String, dynamic>> accountsList =
      <Map<String, dynamic>>[].obs;

  final RxString searchQuery = ''.obs;
  final RxBool isSearchFocused = false.obs;

  final RxList<Map<String, dynamic>> customersList =
      <Map<String, dynamic>>[].obs;

  final RxList<Map<String, dynamic>> suppliersList =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadBusinessesFromDatabase();
    searchFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    try {
      isSearchFocused.value = searchFocusNode.hasFocus;
    } catch (e) {
      // Silently handle focus change errors
      debugPrint('Error on focus change: $e');
    }
  }

  Future<int> _getCustomerCount(String businessId) async {
    try {
      final parties = await _partyRepository.getPartiesByType(
        businessId,
        'customer',
      );
      return parties.length;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getSupplierCount(String businessId) async {
    try {
      final parties = await _partyRepository.getPartiesByType(
        businessId,
        'supplier',
      );
      return parties.length;
    } catch (e) {
      return 0;
    }
  }

  Future<void> refreshAccountCounts() async {
    try {
      for (int i = 0; i < accountsList.length; i++) {
        final businessId = accountsList[i]['id']?.toString();
        if (businessId != null && businessId.isNotEmpty) {
          final customerCount = await _getCustomerCount(businessId);
          final supplierCount = await _getSupplierCount(businessId);
          accountsList[i]['customerCount'] = customerCount;
          accountsList[i]['supplierCount'] = supplierCount;
        } else {
          accountsList[i]['customerCount'] = 0;
          accountsList[i]['supplierCount'] = 0;
        }
      }
    } catch (e) {
      debugPrint('Error refreshing account counts: $e');
    }
  }

  Future<void> _loadBusinessesFromDatabase() async {
    try {
      final businesses = await _businessRepository.getBusinesses();

      accountsList.clear();

      for (var business in businesses) {
        final customerCount = await _getCustomerCount(business.id);
        final supplierCount = await _getSupplierCount(business.id);
        final account = {
          'id': business.id,
          'name': business.businessName,
          'customerCount': customerCount,
          'supplierCount': supplierCount,
          'isSelected': false,
          'business': business,
        };
        accountsList.add(account);
      }

      if (accountsList.isNotEmpty) {
        bool hasSelected = false;
        for (var account in accountsList) {
          if (account['isSelected'] == true) {
            hasSelected = true;
            final businessId = account['id']?.toString();
            if (businessId != null) {
              selectedBusinessId.value = businessId;
              storeName.value = account['name'] as String;
            }
            break;
          }
        }

        if (!hasSelected) {
          accountsList[0]['isSelected'] = true;
          selectedBusinessId.value = accountsList[0]['id'] as String;
          storeName.value = accountsList[0]['name'] as String;

          _notifyBusinessProfileController(selectedBusinessId.value);
        }
      }

      if (accountsList.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showCreateBusinessBottomSheet();
        });
      } else if (selectedBusinessId.value.isNotEmpty) {
        loadPartiesFromDatabase();
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (accountsList.isEmpty) {
          _showCreateBusinessBottomSheet();
        }
      });
    }
  }

  Future<void> loadPartiesFromDatabase() async {
    if (selectedBusinessId.value.isEmpty) return;

    try {
      final parties = await _partyRepository.getPartiesByBusiness(
        selectedBusinessId.value,
      );

      customersList.clear();
      suppliersList.clear();

      for (var party in parties) {
        final partyData = await _convertPartyToHomeFormat(party);
        if (party.type == 'customer') {
          customersList.add(partyData);
        } else {
          suppliersList.add(partyData);
        }
      }

      updateSummaryAmounts();
    } catch (e) {
      debugPrint('Error loading parties from database: $e');
      Get.snackbar(
        'Error',
        'Failed to load parties',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  Future<Map<String, dynamic>> _convertPartyToHomeFormat(
    PartyModel party,
  ) async {
    final transactions = await _transactionRepository.getTransactionsByParty(
      party.id,
    );

    double totalAmount = 0.0;
    String type = 'give';
    DateTime? lastTransactionDate;

    if (transactions.isNotEmpty) {
      final lastTransaction = transactions.first;
      lastTransactionDate = DateTime.fromMillisecondsSinceEpoch(
        lastTransaction.date,
      );

      for (var tx in transactions) {
        if (tx.direction == 'gave') {
          totalAmount += tx.amount;
        } else {
          totalAmount -= tx.amount;
        }
      }

      type = totalAmount >= 0 ? 'give' : 'get';
      totalAmount = totalAmount.abs();
    }

    String timeText = 'Just now';
    if (lastTransactionDate != null) {
      final now = DateTime.now();
      final difference = now.difference(lastTransactionDate);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          if (difference.inMinutes == 0) {
            timeText = 'Just now';
          } else {
            timeText = '${difference.inMinutes}m ago';
          }
        } else {
          timeText = '${difference.inHours}h ago';
        }
      } else if (difference.inDays == 1) {
        timeText = '1 day ago';
      } else if (difference.inDays < 7) {
        timeText = '${difference.inDays} days ago';
      } else {
        final months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        timeText =
            '${lastTransactionDate.day} ${months[lastTransactionDate.month - 1]}';
      }
    }

    return {
      'id': party.id,
      'name': party.partyName,
      'phone': party.phoneNumber ?? '',
      'amount': totalAmount,
      'type': type,
      'time': timeText,
      'hasRequest': false,
      'address': party.address,
    };
  }

  void changeTab(int index) {
    selectedTab.value = index;
    searchQuery.value = '';
    updateSummaryAmounts();
  }

  void selectFilter(String filter) {
    selectedFilter.value = filter;
  }

  void selectSort(String sort) {
    selectedSort.value = sort;
  }

  void toggleFilterModal() {
    showFilterModal.value = !showFilterModal.value;
  }

  void closeFilterModal() {
    showFilterModal.value = false;
  }

  void toggleAccountModal() async {
    if (!showAccountModal.value) {
      await refreshAccountCounts();
    }
    showAccountModal.value = !showAccountModal.value;
  }

  void closeAccountModal() {
    showAccountModal.value = false;
  }

  void selectAccount(int index) {
    if (index >= 0 && index < accountsList.length) {
      for (var account in accountsList) {
        account['isSelected'] = false;
      }
      accountsList[index]['isSelected'] = true;
      final selectedAccount = accountsList[index];
      storeName.value = selectedAccount['name'] as String;

      final businessId = selectedAccount['id']?.toString();
      if (businessId != null && businessId.isNotEmpty) {
        selectedBusinessId.value = businessId;
        _notifyBusinessProfileController(businessId);
        loadPartiesFromDatabase();
      }

      closeAccountModal();
    }
  }

  void _notifyBusinessProfileController(String businessId) {
    if (Get.isRegistered<BusinessProfileController>()) {
      final businessProfileController = Get.find<BusinessProfileController>();
      businessProfileController.loadBusinessById(businessId);
    }
  }

  void addNewAccount(String name) {
    for (var account in accountsList) {
      account['isSelected'] = false;
    }

    final newAccount = {'name': name, 'customerCount': 0, 'isSelected': true};
    accountsList.add(newAccount);
    storeName.value = name;

    if (showAccountModal.value) {
      closeAccountModal();
    }
  }

  Future<void> addNewAccountFromBusiness(BusinessModel business) async {
    for (var account in accountsList) {
      account['isSelected'] = false;
    }

    final customerCount = await _getCustomerCount(business.id);
    final supplierCount = await _getSupplierCount(business.id);
    final newAccount = {
      'id': business.id,
      'name': business.businessName,
      'customerCount': customerCount,
      'supplierCount': supplierCount,
      'isSelected': true,
      'business': business,
    };
    accountsList.add(newAccount);
    storeName.value = business.businessName;
    selectedBusinessId.value = business.id;

    _notifyBusinessProfileController(business.id);

    if (showAccountModal.value) {
      closeAccountModal();
    }

    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }
  }

  Future<void> refreshBusinesses() async {
    await _loadBusinessesFromDatabase();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  List<Map<String, dynamic>> getCurrentList() {
    return selectedTab.value == 0 ? customersList : suppliersList;
  }

  void updateSummaryAmounts() {
    final list = getCurrentList();
    double give = 0.0;
    double get = 0.0;

    for (var item in list) {
      if (item['type'] == 'give') {
        give += (item['amount'] as num).toDouble();
      } else {
        get += (item['amount'] as num).toDouble();
      }
    }

    amountToGive.value = give;
    amountToGet.value = get;
  }

  List<Map<String, dynamic>> getFilteredList() {
    var list = List<Map<String, dynamic>>.from(getCurrentList());

    if (searchQuery.value.isNotEmpty) {
      list = list.where((item) {
        final name = (item['name'] ?? '').toString().toLowerCase();
        return name.contains(searchQuery.value.toLowerCase());
      }).toList();
    }

    if (selectedFilter.value != 'All') {
      switch (selectedFilter.value) {
        case 'You will give':
          list = list.where((item) => item['type'] == 'give').toList();
          break;
        case 'You will get':
          list = list.where((item) => item['type'] == 'get').toList();
          break;
        case 'Settled':
          break;
        case 'Due Today':
          break;
        case 'Upcoming':
          break;
        case 'No Due Date':
          break;
      }
    }

    switch (selectedSort.value) {
      case 'Most Recent':
        break;
      case 'Highest Amount':
        list.sort((a, b) {
          final amountA = (a['amount'] as num).toDouble();
          final amountB = (b['amount'] as num).toDouble();
          return amountB.compareTo(amountA);
        });
        break;
      case 'By Name (A-Z)':
        list.sort((a, b) {
          final nameA = (a['name'] ?? '').toString();
          final nameB = (b['name'] ?? '').toString();
          return nameA.compareTo(nameB);
        });
        break;
      case 'Oldest':
        list = list.reversed.toList();
        break;
      case 'Least Amount':
        list.sort((a, b) {
          final amountA = (a['amount'] as num).toDouble();
          final amountB = (b['amount'] as num).toDouble();
          return amountA.compareTo(amountB);
        });
        break;
    }

    return list;
  }

  Worker? _selectedTabWorker;

  @override
  void onReady() {
    super.onReady();
    _selectedTabWorker = ever(selectedTab, (_) {
      updateSummaryAmounts();
    });
  }

  void _showCreateBusinessBottomSheet() {
    Get.bottomSheet(
      _buildCreateBusinessBottomSheet(),
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
    );
  }

  Widget _buildCreateBusinessBottomSheet() {
    return Container(
      padding: .all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: .circular(20),
          topRight: .circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Icon(Icons.business, size: 60, color: AppColors.primary),
          const SizedBox(height: 20),
          const Text(
            'Create Your First Business',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Start managing your accounts by creating your first business profile',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 26),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed(Routes.createAccount);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'CREATE BUSINESS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    _selectedTabWorker?.dispose();
    searchFocusNode.removeListener(_onFocusChange);
    searchFocusNode.dispose();
    super.onClose();
  }
}

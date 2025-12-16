import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final searchFocusNode = FocusNode();
  // Tab selection: 0 for Customers, 1 for Suppliers
  final RxInt selectedTab = 0.obs;

  // Filter and sort states
  final RxString selectedFilter = 'All'.obs;
  final RxString selectedSort = 'Most Recent'.obs;
  final RxBool showFilterModal = false.obs;

  // Summary amounts
  final RxDouble amountToGive = 10888.0.obs;
  final RxDouble amountToGet = 0.0.obs;

  // Store name
  final RxString storeName = 'Kirana Store'.obs;
  final RxBool showAccountModal = false.obs;

  // Mock accounts/stores list
  final RxList<Map<String, dynamic>> accountsList = <Map<String, dynamic>>[
    {'name': 'Kirana Store', 'customerCount': 5, 'isSelected': true},
    {'name': 'Student', 'customerCount': 0, 'isSelected': false},
    {'name': 'Dggdh', 'customerCount': 0, 'isSelected': false},
    {'name': 'Dhdhdhd', 'customerCount': 0, 'isSelected': false},
    {'name': 'Mdkdmf', 'customerCount': 0, 'isSelected': false},
    {'name': 'Djjfjfjf', 'customerCount': 0, 'isSelected': false},
  ].obs;

  // Search query
  final RxString searchQuery = ''.obs;
  final RxBool isSearchFocused = false.obs;

  // Mock data for Customers
  final RxList<Map<String, dynamic>> customersList = <Map<String, dynamic>>[
    {
      'name': 'Suman',
      'time': '7 minutes ago',
      'amount': 5333.0,
      'type': 'give', // green
      'hasRequest': false,
      'phone': '9876543210',
    },
    {
      'name': 'Rajiv',
      'time': '8 minutes ago',
      'amount': 5555.0,
      'type': 'give', // green
      'hasRequest': false,
      'phone': '9876543211',
    },
  ].obs;

  // Mock data for Suppliers
  final RxList<Map<String, dynamic>> suppliersList = <Map<String, dynamic>>[
    {
      'name': 'Gddh',
      'time': '6 seconds ago',
      'amount': 555.0,
      'type': 'give', // green
      'hasRequest': false,
      'phone': '9876543212',
    },
    {
      'name': 'Gdhdbd',
      'time': '46 seconds ago',
      'amount': 55.0,
      'type': 'get', // red
      'hasRequest': true,
      'phone': '9876543213',
    },
    {
      'name': 'Surya',
      'time': '44 seconds ago',
      'amount': 289311.0,
      'type': 'get', // red
      'hasRequest': true,
      'phone': '9876543214',
    },
  ].obs;

  // Initialize summary amounts for suppliers tab
  @override
  void onInit() {
    super.onInit();
    // Set initial amounts for suppliers tab (will be updated when tab changes)
    amountToGive.value = 10888.0; // Customers tab default
    amountToGet.value = 0.0;
    updateSummaryAmounts();

    // Listen to search focus changes
    searchFocusNode.addListener(() {
      isSearchFocused.value = searchFocusNode.hasFocus;
    });
  }

  void changeTab(int index) {
    selectedTab.value = index;
    searchQuery.value = ''; // Clear search when switching tabs
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

  void toggleAccountModal() {
    showAccountModal.value = !showAccountModal.value;
  }

  void closeAccountModal() {
    showAccountModal.value = false;
  }

  void selectAccount(int index) {
    if (index >= 0 && index < accountsList.length) {
      // Update all accounts to unselected
      for (var account in accountsList) {
        account['isSelected'] = false;
      }
      // Select the chosen account
      accountsList[index]['isSelected'] = true;
      storeName.value = accountsList[index]['name'] as String;
      closeAccountModal();
    }
  }

  void addNewAccount(String name) {
    // Unselect all accounts
    for (var account in accountsList) {
      account['isSelected'] = false;
    }

    // Add new account and select it
    final newAccount = {'name': name, 'customerCount': 0, 'isSelected': true};
    accountsList.add(newAccount);
    storeName.value = name;

    // Close account modal if it's open
    if (showAccountModal.value) {
      closeAccountModal();
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Get current list based on selected tab
  List<Map<String, dynamic>> getCurrentList() {
    return selectedTab.value == 0 ? customersList : suppliersList;
  }

  // Update summary amounts based on current list
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

  // Get filtered and sorted list
  List<Map<String, dynamic>> getFilteredList() {
    var list = List<Map<String, dynamic>>.from(getCurrentList());

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      list = list.where((item) {
        final name = (item['name'] ?? '').toString().toLowerCase();
        return name.contains(searchQuery.value.toLowerCase());
      }).toList();
    }

    // Apply filter
    if (selectedFilter.value != 'All') {
      switch (selectedFilter.value) {
        case 'You will give':
          list = list.where((item) => item['type'] == 'give').toList();
          break;
        case 'You will get':
          list = list.where((item) => item['type'] == 'get').toList();
          break;
        case 'Settled':
          // TODO: Implement settled filter
          break;
        case 'Due Today':
          // TODO: Implement due today filter
          break;
        case 'Upcoming':
          // TODO: Implement upcoming filter
          break;
        case 'No Due Date':
          // TODO: Implement no due date filter
          break;
      }
    }

    // Apply sort
    switch (selectedSort.value) {
      case 'Most Recent':
        // Keep original order (most recent first)
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
        // Reverse order for oldest
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

  @override
  void onReady() {
    super.onReady();
    // Update amounts when tab changes
    ever(selectedTab, (_) {
      updateSummaryAmounts();
    });
  }

  @override
  void onClose() {
    searchFocusNode.dispose();
    super.onClose();
  }
}

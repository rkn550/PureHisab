import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purehisab/app/utils/snacks_bar.dart';
import 'package:purehisab/controllers/navigation_controller.dart';
import 'package:purehisab/data/model/party_model.dart';
import 'package:purehisab/data/services/party_repo.dart';
import 'package:purehisab/data/services/transaction_repo.dart';

class HomeController extends GetxController {
  PartyRepository get _partyRepository => Get.find<PartyRepository>();
  TransactionRepository get _transactionRepository =>
      Get.find<TransactionRepository>();

  final searchFocusNode = FocusNode();
  final RxInt _selectedTabIndex = 0.obs;
  int get selectedTabIndex => _selectedTabIndex.value;

  final RxString _businessId = ''.obs;
  String get businessId => _businessId.value;

  final RxString _selectedFilter = 'All'.obs;
  String get selectedFilter => _selectedFilter.value;

  final RxString _selectedSort = 'Most Recent'.obs;
  String get selectedSort => _selectedSort.value;

  final RxBool _showFilterModal = false.obs;
  bool get showFilterModal => _showFilterModal.value;

  final RxBool _isSearchFocused = false.obs;
  bool get isSearchFocused => _isSearchFocused.value;

  final RxDouble _amountToGive = 0.0.obs;
  final RxDouble _amountToGet = 0.0.obs;
  double get amountToGive => _amountToGive.value;
  double get amountToGet => _amountToGet.value;

  final RxString _searchQuery = ''.obs;
  String get searchQuery => _searchQuery.value;

  final RxList<Map<String, dynamic>> _customersList =
      <Map<String, dynamic>>[].obs;
  List<Map<String, dynamic>> get customersList => _customersList;

  final RxList<Map<String, dynamic>> _suppliersList =
      <Map<String, dynamic>>[].obs;
  List<Map<String, dynamic>> get suppliersList => _suppliersList;

  @override
  void onInit() {
    super.onInit();
    _setupBusinessIdListener();
  }

  void _setupBusinessIdListener() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (Get.isRegistered<NavigationController>()) {
        final navController = Get.find<NavigationController>();
        ever(navController.businessIdRx, (String newBusinessId) {
          if (newBusinessId.isNotEmpty && newBusinessId != _businessId.value) {
            _businessId.value = newBusinessId;
            _loadPartiesFromDatabase(newBusinessId);
          }
        });
        if (navController.businessId.isNotEmpty &&
            navController.businessId != _businessId.value) {
          _businessId.value = navController.businessId;
          _loadPartiesFromDatabase(navController.businessId);
        }
      }
    });
  }

  Future<void> _loadPartiesFromDatabase(String businessId) async {
    if (businessId.isEmpty) return;
    _businessId.value = businessId;
    try {
      final parties = await _partyRepository.getPartiesByBusiness(businessId);
      _customersList.clear();
      _suppliersList.clear();
      for (var party in parties) {
        final partyData = await _convertPartyToHomeFormat(party);
        if (party.type == 'customer') {
          _customersList.add(partyData);
        } else {
          _suppliersList.add(partyData);
        }
      }
      updateSummaryAmounts();
    } catch (e) {
      SnacksBar.showSnackbar(
        title: 'Error',
        message: 'Failed to load parties. Please try again.',
        type: SnacksBarType.ERROR,
      );
    }
  }

  Future<Map<String, dynamic>> _convertPartyToHomeFormat(
    PartyModel party,
  ) async {
    final transactions = await _transactionRepository.getTransactionsByPartyId(
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
      'phone': party.phoneNumber,
      'amount': totalAmount,
      'type': type,
      'time': timeText,
      'hasRequest': false,
      'address': party.address,
      'photoUrl': party.partiesPhotoUrl,
    };
  }

  void changeTab(int index) {
    _selectedTabIndex.value = index;
    _searchQuery.value = '';
    updateSummaryAmounts();
  }

  void selectFilter(String filter) {
    _selectedFilter.value = filter;
  }

  void selectSort(String sort) {
    _selectedSort.value = sort;
  }

  void toggleFilterModal() {
    _showFilterModal.value = !_showFilterModal.value;
  }

  void closeFilterModal() {
    _showFilterModal.value = false;
  }

  void updateSearchQuery(String query) {
    _searchQuery.value = query;
  }

  List<Map<String, dynamic>> getCurrentList() {
    return selectedTabIndex == 0 ? customersList : suppliersList;
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

    _amountToGive.value = give;
    _amountToGet.value = get;
  }

  Future<void> refreshData() async {
    if (_businessId.value.isNotEmpty) {
      await _loadPartiesFromDatabase(_businessId.value);
      updateSummaryAmounts();
    } else if (Get.isRegistered<NavigationController>()) {
      final navController = Get.find<NavigationController>();
      if (navController.businessId.isNotEmpty) {
        await _loadPartiesFromDatabase(navController.businessId);
        updateSummaryAmounts();
      }
    }
  }

  List<Map<String, dynamic>> getFilteredList() {
    var list = List<Map<String, dynamic>>.from(getCurrentList());

    if (searchQuery.isNotEmpty) {
      list = list.where((item) {
        final name = (item['name'] ?? '').toString().toLowerCase();
        return name.contains(searchQuery.toLowerCase());
      }).toList();
    }

    if (selectedFilter != 'All') {
      switch (selectedFilter) {
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

    switch (selectedSort) {
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
}

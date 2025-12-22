import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:purehisab/data/services/party_repo.dart';
import 'package:purehisab/data/services/transaction_repo.dart';
import 'package:purehisab/data/model/party_model.dart';
import 'package:purehisab/controllers/home_controller.dart';

class AnalyticsController extends GetxController {
  PartyRepository get _partyRepository => Get.find<PartyRepository>();
  TransactionRepository get _transactionRepository =>
      Get.find<TransactionRepository>();

  final RxDouble totalBalance = 0.0.obs;
  final RxDouble totalToGive = 0.0.obs;
  final RxDouble totalToGet = 0.0.obs;
  final RxInt totalTransactions = 0.obs;
  final RxInt totalCustomers = 0.obs;
  final RxInt totalSuppliers = 0.obs;

  final RxDouble thisMonthIncome = 0.0.obs;
  final RxDouble thisMonthExpense = 0.0.obs;
  final RxDouble thisMonthToGive = 0.0.obs;
  final RxDouble thisMonthToGet = 0.0.obs;
  final RxInt thisMonthTransactions = 0.obs;

  final RxDouble thisWeekIncome = 0.0.obs;
  final RxDouble thisWeekExpense = 0.0.obs;
  final RxInt thisWeekTransactions = 0.obs;

  final RxList<Map<String, dynamic>> topCustomers =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> topSuppliers =
      <Map<String, dynamic>>[].obs;

  Worker? _homeControllerWorker;
  bool _isLoading = false;

  @override
  void onInit() {
    super.onInit();
    // Start loading data immediately when controller is initialized
    _setupHomeControllerListener();
    // Load data immediately if HomeController is ready
    Future.microtask(() {
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        if (homeController.selectedBusinessId.value.isNotEmpty) {
          _loadAnalyticsData();
        }
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    // Refresh data when screen is ready to ensure latest data is shown
    Future.delayed(const Duration(milliseconds: 100), () {
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        if (homeController.selectedBusinessId.value.isNotEmpty) {
          _loadAnalyticsData();
        }
      }
    });
  }

  void _setupHomeControllerListener() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        _homeControllerWorker = ever(homeController.selectedBusinessId, (_) {
          if (homeController.selectedBusinessId.value.isNotEmpty) {
            _loadAnalyticsData();
          }
        });
      }
    });
  }

  @override
  void onClose() {
    _homeControllerWorker?.dispose();
    super.onClose();
  }

  Future<void> refreshAnalytics() async {
    await _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    if (_isLoading) return;
    if (!Get.isRegistered<HomeController>()) {
      return;
    }

    try {
      _isLoading = true;
      final homeController = Get.find<HomeController>();
      if (homeController.selectedBusinessId.value.isEmpty) {
        _isLoading = false;
        return;
      }

      final businessId = homeController.selectedBusinessId.value;

      // Load data in parallel where possible
      final parties = await _partyRepository.getPartiesByBusiness(businessId);
      final transactions = await _transactionRepository
          .getTransactionsByBusiness(businessId);

      // Process data in batches to avoid blocking main thread
      await Future.microtask(() {
        final customers = parties.where((p) => p.type == 'customer').toList();
        final suppliers = parties.where((p) => p.type == 'supplier').toList();

        totalCustomers.value = customers.length;
        totalSuppliers.value = suppliers.length;
        totalTransactions.value = transactions.length;

        final partyBalances = <String, double>{};

        for (var tx in transactions) {
          final partyId = tx.partyId;
          partyBalances[partyId] =
              (partyBalances[partyId] ?? 0.0) +
              (tx.direction == 'gave' ? -tx.amount : tx.amount);
        }

        double totalGive = 0.0;
        double totalGet = 0.0;

        for (var balance in partyBalances.values) {
          if (balance < 0) {
            totalGive += balance.abs();
          } else {
            totalGet += balance;
          }
        }

        totalToGive.value = totalGive;
        totalToGet.value = totalGet;
        totalBalance.value = totalGet - totalGive;
      });

      // Calculate stats in separate microtasks to avoid blocking
      await Future.microtask(() => _calculateThisMonthData(transactions));
      await Future.microtask(() => _calculateThisWeekData(transactions));
      await Future.microtask(() {
        final customers = parties.where((p) => p.type == 'customer').toList();
        final suppliers = parties.where((p) => p.type == 'supplier').toList();
        _calculateTopParties(customers, suppliers, transactions);
      });
    } catch (e) {
      // Log error but don't crash
      debugPrint('Error loading analytics data: $e');
    } finally {
      _isLoading = false;
    }
  }

  void _calculateThisMonthData(List transactions) {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    double income = 0.0;
    double expense = 0.0;
    int transactionCount = 0;

    for (var tx in transactions) {
      try {
        final date = DateTime.fromMillisecondsSinceEpoch(tx.date);
        final txMonth = date.month;
        final txYear = date.year;

        if (txMonth == currentMonth && txYear == currentYear) {
          if (tx.direction == 'got') {
            income += tx.amount;
          } else if (tx.direction == 'gave') {
            expense += tx.amount;
          }
          transactionCount++;
        }
      } catch (e) {
        // Skip invalid transaction
        continue;
      }
    }

    thisMonthIncome.value = income;
    thisMonthExpense.value = expense;
    thisMonthTransactions.value = transactionCount;

    final netBalance = income - expense;
    if (netBalance > 0) {
      thisMonthToGet.value = netBalance;
      thisMonthToGive.value = 0.0;
    } else {
      thisMonthToGive.value = netBalance.abs();
      thisMonthToGet.value = 0.0;
    }
  }

  void _calculateThisWeekData(List transactions) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    final weekStart = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    final weekEnd = DateTime(
      endOfWeek.year,
      endOfWeek.month,
      endOfWeek.day,
      23,
      59,
      59,
    );

    double income = 0.0;
    double expense = 0.0;
    int transactionCount = 0;

    final weekStartMs = weekStart.millisecondsSinceEpoch;
    final weekEndMs = weekEnd.millisecondsSinceEpoch;

    for (var tx in transactions) {
      try {
        final date = DateTime.fromMillisecondsSinceEpoch(tx.date);
        final transactionDate = DateTime(date.year, date.month, date.day);
        final txMs = transactionDate.millisecondsSinceEpoch;

        if (txMs >= weekStartMs && txMs <= weekEndMs) {
          if (tx.direction == 'got') {
            income += tx.amount;
          } else if (tx.direction == 'gave') {
            expense += tx.amount;
          }
          transactionCount++;
        }
      } catch (e) {
        // Skip invalid transaction
        continue;
      }
    }

    thisWeekIncome.value = income;
    thisWeekExpense.value = expense;
    thisWeekTransactions.value = transactionCount;
  }

  void _calculateTopParties(List customers, List suppliers, List transactions) {
    // Use Maps for O(1) lookup instead of firstWhere O(n)
    final customerMap = <String, PartyModel>{};
    final supplierMap = <String, PartyModel>{};

    for (var customer in customers) {
      customerMap[customer.id] = customer;
    }
    for (var supplier in suppliers) {
      supplierMap[supplier.id] = supplier;
    }

    final customerBalances = <String, double>{};
    final supplierBalances = <String, double>{};

    for (var tx in transactions) {
      final partyId = tx.partyId;

      if (customerMap.containsKey(partyId)) {
        customerBalances[partyId] =
            (customerBalances[partyId] ?? 0.0) +
            (tx.direction == 'gave' ? tx.amount : -tx.amount);
      } else if (supplierMap.containsKey(partyId)) {
        supplierBalances[partyId] =
            (supplierBalances[partyId] ?? 0.0) +
            (tx.direction == 'got' ? -tx.amount : tx.amount);
      }
    }

    final topCustomersList = <Map<String, dynamic>>[];
    for (var customer in customers) {
      final balance = customerBalances[customer.id]?.abs() ?? 0.0;
      if (balance > 0) {
        topCustomersList.add({
          'id': customer.id,
          'name': customer.partyName,
          'amount': balance,
          'type': customerBalances[customer.id]! < 0 ? 'give' : 'get',
        });
      }
    }
    topCustomersList.sort(
      (a, b) => (b['amount'] as num).compareTo(a['amount'] as num),
    );

    final topSuppliersList = <Map<String, dynamic>>[];
    for (var supplier in suppliers) {
      final balance = supplierBalances[supplier.id]?.abs() ?? 0.0;
      if (balance > 0) {
        topSuppliersList.add({
          'id': supplier.id,
          'name': supplier.partyName,
          'amount': balance,
          'type': supplierBalances[supplier.id]! < 0 ? 'give' : 'get',
        });
      }
    }
    topSuppliersList.sort(
      (a, b) => (b['amount'] as num).compareTo(a['amount'] as num),
    );

    topCustomers.value = topCustomersList.take(5).toList();
    topSuppliers.value = topSuppliersList.take(5).toList();
  }

  String formatAmount(double amount) {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }

  String formatAmountFull(double amount) {
    final formatter = amount.toStringAsFixed(0);
    final parts = formatter.split('.');
    final integerPart = parts[0];
    final reversed = integerPart.split('').reversed.join();
    final formatted = reversed.replaceAllMapped(
      RegExp(r'(\d{3})(?=\d)'),
      (match) => '${match.group(0)},',
    );
    return '₹${formatted.split('').reversed.join()}';
  }
}

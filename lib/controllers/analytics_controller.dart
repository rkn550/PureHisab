import 'package:get/get.dart';
import 'package:purehisab/controllers/navigation_controller.dart';
import 'package:purehisab/data/services/party_repo.dart';
import 'package:purehisab/data/services/transaction_repo.dart';
import 'package:purehisab/data/model/party_model.dart';

class AnalyticsController extends GetxController {
  PartyRepository get _partyRepository => Get.find<PartyRepository>();
  TransactionRepository get _transactionRepository =>
      Get.find<TransactionRepository>();
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final RxString _businessId = ''.obs;
  String get businessId => _businessId.value;

  final RxDouble _totalBalance = 0.0.obs;
  final RxDouble _totalToGive = 0.0.obs;
  final RxDouble _totalToGet = 0.0.obs;
  final RxInt _totalTransactions = 0.obs;
  double get totalBalance => _totalBalance.value;
  double get totalToGive => _totalToGive.value;
  double get totalToGet => _totalToGet.value;
  int get totalTransactions => _totalTransactions.value;

  final RxInt _totalCustomers = 0.obs;
  final RxInt _totalSuppliers = 0.obs;
  int get totalCustomers => _totalCustomers.value;
  int get totalSuppliers => _totalSuppliers.value;

  final RxDouble _thisMonthIncome = 0.0.obs;
  final RxDouble _thisMonthExpense = 0.0.obs;
  final RxDouble _thisMonthToGive = 0.0.obs;
  final RxDouble _thisMonthToGet = 0.0.obs;
  final RxInt _thisMonthTransactions = 0.obs;
  double get thisMonthIncome => _thisMonthIncome.value;
  double get thisMonthExpense => _thisMonthExpense.value;
  double get thisMonthToGive => _thisMonthToGive.value;
  double get thisMonthToGet => _thisMonthToGet.value;
  int get thisMonthTransactions => _thisMonthTransactions.value;

  final RxDouble _thisWeekIncome = 0.0.obs;
  final RxDouble _thisWeekExpense = 0.0.obs;
  final RxInt _thisWeekTransactions = 0.obs;
  double get thisWeekIncome => _thisWeekIncome.value;
  double get thisWeekExpense => _thisWeekExpense.value;
  int get thisWeekTransactions => _thisWeekTransactions.value;

  final RxList<Map<String, dynamic>> _topCustomers =
      <Map<String, dynamic>>[].obs;
  List<Map<String, dynamic>> get topCustomers => _topCustomers;
  final RxList<Map<String, dynamic>> _topSuppliers =
      <Map<String, dynamic>>[].obs;
  List<Map<String, dynamic>> get topSuppliers => _topSuppliers;

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
            _loadAnalyticsData(newBusinessId);
          }
        });
        if (navController.businessId.isNotEmpty &&
            navController.businessId != _businessId.value) {
          _businessId.value = navController.businessId;
          _loadAnalyticsData(navController.businessId);
        }
      }
    });
  }

  Future<void> reloadAnalyticsData() async {
    if (_businessId.value.isEmpty) {
      if (Get.isRegistered<NavigationController>()) {
        final navController = Get.find<NavigationController>();
        if (navController.businessId.isNotEmpty) {
          _businessId.value = navController.businessId;
        }
      }
    }

    if (_businessId.value.isEmpty) return;

    await _loadAnalyticsData(_businessId.value);
  }

  Future<void> reloadAnalyticsDataWithBusinessId(String businessId) async {
    if (businessId.isEmpty) return;
    await _loadAnalyticsData(businessId);
  }

  Future<void> _loadAnalyticsData(String businessId) async {
    if (businessId.isEmpty) return;
    _businessId.value = businessId;
    _isLoading.value = true;
    try {
      final parties = await _partyRepository.getPartiesByBusiness(businessId);
      final transactions = await _transactionRepository
          .getTransactionsByBusiness(businessId);

      await Future.microtask(() {
        final customers = parties.where((p) => p.type == 'customer').toList();
        final suppliers = parties.where((p) => p.type == 'supplier').toList();

        _totalCustomers.value = customers.length;
        _totalSuppliers.value = suppliers.length;
        _totalTransactions.value = transactions.length;

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

        _totalToGive.value = totalGive;
        _totalToGet.value = totalGet;
        _totalBalance.value = totalGet - totalGive;
      });

      await Future.microtask(() => _calculateThisMonthData(transactions));
      await Future.microtask(() => _calculateThisWeekData(transactions));
      await Future.microtask(() {
        final customers = parties.where((p) => p.type == 'customer').toList();
        final suppliers = parties.where((p) => p.type == 'supplier').toList();
        _calculateTopParties(customers, suppliers, transactions);
      });
    } catch (e) {
    } finally {
      _isLoading.value = false;
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
        continue;
      }
    }

    _thisMonthIncome.value = income;
    _thisMonthExpense.value = expense;
    _thisMonthTransactions.value = transactionCount;

    final netBalance = income - expense;
    if (netBalance > 0) {
      _thisMonthToGet.value = netBalance;
      _thisMonthToGive.value = 0.0;
    } else {
      _thisMonthToGive.value = netBalance.abs();
      _thisMonthToGet.value = 0.0;
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
        continue;
      }
    }

    _thisWeekIncome.value = income;
    _thisWeekExpense.value = expense;
    _thisWeekTransactions.value = transactionCount;
  }

  void _calculateTopParties(List customers, List suppliers, List transactions) {
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

    _topCustomers.value = topCustomersList.take(5).toList();
    _topSuppliers.value = topSuppliersList.take(5).toList();
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

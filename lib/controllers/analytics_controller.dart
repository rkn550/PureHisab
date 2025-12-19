import 'package:get/get.dart';
import 'package:purehisab/data/services/party_repo.dart';
import 'package:purehisab/data/services/transaction_repo.dart';
import 'package:purehisab/controllers/home_controller.dart';

class AnalyticsController extends GetxController {
  final PartyRepository _partyRepository = PartyRepository();
  final TransactionRepository _transactionRepository = TransactionRepository();

  final RxDouble totalBalance = 0.0.obs;
  final RxDouble totalToGive = 0.0.obs;
  final RxDouble totalToGet = 0.0.obs;
  final RxInt totalTransactions = 0.obs;
  final RxInt totalCustomers = 0.obs;
  final RxInt totalSuppliers = 0.obs;

  // Monthly stats
  final RxDouble thisMonthIncome = 0.0.obs; // You Got
  final RxDouble thisMonthExpense = 0.0.obs; // You Gave
  final RxDouble thisMonthToGive = 0.0.obs; // Amount to give this month
  final RxDouble thisMonthToGet = 0.0.obs; // Amount to get this month
  final RxInt thisMonthTransactions = 0.obs;

  // Weekly stats
  final RxDouble thisWeekIncome = 0.0.obs; // You Got
  final RxDouble thisWeekExpense = 0.0.obs; // You Gave
  final RxInt thisWeekTransactions = 0.obs;

  // Top customers/suppliers
  final RxList<Map<String, dynamic>> topCustomers =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> topSuppliers =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    Future.delayed(const Duration(milliseconds: 300), () {
      _loadAnalyticsData();
    });
    if (Get.isRegistered<HomeController>()) {
      final homeController = Get.find<HomeController>();
      ever(homeController.selectedBusinessId, (_) {
        if (homeController.selectedBusinessId.value.isNotEmpty) {
          _loadAnalyticsData();
        }
      });
    }
  }

  Future<void> refreshAnalytics() async {
    await _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    if (!Get.isRegistered<HomeController>()) {
      return;
    }

    try {
      final homeController = Get.find<HomeController>();
      if (homeController.selectedBusinessId.value.isEmpty) {
        return;
      }

      final businessId = homeController.selectedBusinessId.value;

      final parties = await _partyRepository.getPartiesByBusiness(businessId);
      final customers = parties.where((p) => p.type == 'customer').toList();
      final suppliers = parties.where((p) => p.type == 'supplier').toList();

      totalCustomers.value = customers.length;
      totalSuppliers.value = suppliers.length;

      final transactions = await _transactionRepository
          .getTransactionsByBusiness(businessId);

      totalTransactions.value = transactions.length;

      double give = 0.0;
      double get = 0.0;

      for (var tx in transactions) {
        if (tx.direction == 'gave') {
          give += tx.amount;
        } else {
          get += tx.amount;
        }
      }

      totalToGive.value = give;
      totalToGet.value = get;
      totalBalance.value = get - give;

      _calculateThisMonthData(transactions);
      _calculateThisWeekData(transactions);
      _calculateTopParties(customers, suppliers, transactions);
    } catch (e) {
      // Error handling
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

        // Check if transaction is in current month
        if (txMonth == currentMonth && txYear == currentYear) {
          if (tx.direction == 'got') {
            income += tx.amount;
          } else if (tx.direction == 'gave') {
            expense += tx.amount;
          }
          transactionCount++;
        }
      } catch (e) {
        // Error handling
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

    // Normalize to start of day for comparison
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

    for (var tx in transactions) {
      try {
        final date = DateTime.fromMillisecondsSinceEpoch(tx.date);
        final transactionDate = DateTime(date.year, date.month, date.day);

        final txMs = transactionDate.millisecondsSinceEpoch;
        final weekStartMs = weekStart.millisecondsSinceEpoch;
        final weekEndMs = weekEnd.millisecondsSinceEpoch;

        if (txMs >= weekStartMs && txMs <= weekEndMs) {
          if (tx.direction == 'got') {
            income += tx.amount;
          } else if (tx.direction == 'gave') {
            expense += tx.amount;
          }
          transactionCount++;
        }
      } catch (e) {
        // Error handling
      }
    }

    thisWeekIncome.value = income;
    thisWeekExpense.value = expense;
    thisWeekTransactions.value = transactionCount;
  }

  void _calculateTopParties(List customers, List suppliers, List transactions) {
    final customerBalances = <String, double>{};
    final supplierBalances = <String, double>{};

    for (var tx in transactions) {
      final partyId = tx.partyId;
      final customer = customers.firstWhere(
        (c) => c.id == partyId,
        orElse: () => null,
      );
      final supplier = suppliers.firstWhere(
        (s) => s.id == partyId,
        orElse: () => null,
      );

      if (customer != null) {
        customerBalances[partyId] =
            (customerBalances[partyId] ?? 0.0) +
            (tx.direction == 'gave' ? tx.amount : -tx.amount);
      } else if (supplier != null) {
        supplierBalances[partyId] =
            (supplierBalances[partyId] ?? 0.0) +
            (tx.direction == 'got' ? -tx.amount : tx.amount);
      }
    }

    final topCustomersList =
        customers.map((c) {
            final balance = customerBalances[c.id]?.abs() ?? 0.0;
            return {
              'id': c.id,
              'name': c.partyName,
              'amount': balance,
              'type': balance >= 0 ? 'give' : 'get',
            };
          }).toList()
          ..sort((a, b) => (b['amount'] as num).compareTo(a['amount'] as num));

    final topSuppliersList =
        suppliers.map((s) {
            final balance = supplierBalances[s.id]?.abs() ?? 0.0;
            return {
              'id': s.id,
              'name': s.partyName,
              'amount': balance,
              'type': balance >= 0 ? 'get' : 'give',
            };
          }).toList()
          ..sort((a, b) => (b['amount'] as num).compareTo(a['amount'] as num));

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

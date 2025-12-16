import 'package:get/get.dart';

class AnalyticsController extends GetxController {
  // Summary stats
  final RxDouble totalBalance = 0.0.obs;
  final RxDouble totalToGive = 10888.0.obs;
  final RxDouble totalToGet = 0.0.obs;
  final RxInt totalTransactions = 0.obs;
  final RxInt totalCustomers = 5.obs;
  final RxInt totalSuppliers = 3.obs;

  // Monthly stats
  final RxDouble thisMonthIncome = 0.0.obs; // You Got
  final RxDouble thisMonthExpense = 0.0.obs; // You Gave
  final RxDouble thisMonthToGive = 0.0.obs; // Amount to give this month
  final RxDouble thisMonthToGet = 0.0.obs; // Amount to get this month
  final RxInt thisMonthTransactions = 0.obs;

  // Weekly stats
  final RxDouble thisWeekIncome = 0.0.obs; // You Got
  final RxDouble thisWeekExpense = 0.0.obs; // You Gave

  // Top customers/suppliers
  final RxList<Map<String, dynamic>> topCustomers =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> topSuppliers =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadAnalyticsData();
  }

  void _loadAnalyticsData() {
    // Calculate total balance
    totalBalance.value = totalToGet.value - totalToGive.value;

    // Calculate this month's data
    _calculateThisMonthData();

    // Calculate weekly data
    _calculateThisWeekData();

    // Mock top customers
    topCustomers.value = [
      {'name': 'Suman', 'amount': 5333.0, 'type': 'give'},
      {'name': 'Rajiv', 'amount': 5555.0, 'type': 'give'},
      {'name': 'Amit', 'amount': 2500.0, 'type': 'get'},
    ];

    // Mock top suppliers
    topSuppliers.value = [
      {'name': 'Surya', 'amount': 289311.0, 'type': 'get'},
      {'name': 'Gddh', 'amount': 555.0, 'type': 'give'},
      {'name': 'Gdhdbd', 'amount': 55.0, 'type': 'get'},
    ];
  }

  void _calculateThisMonthData() {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    // Get all transactions from mock data (this would come from a central store in real app)
    final allTransactions = _getAllTransactions();

    double income = 0.0; // You Got
    double expense = 0.0; // You Gave
    int transactionCount = 0;

    for (var transaction in allTransactions) {
      final date = transaction['date'] as DateTime;

      // Check if transaction is in current month
      if (date.month == currentMonth && date.year == currentYear) {
        if (transaction['type'] == 'get') {
          income += (transaction['amount'] as num).toDouble();
        } else if (transaction['type'] == 'give') {
          expense += (transaction['amount'] as num).toDouble();
        }
        transactionCount++;
      }
    }

    thisMonthIncome.value = income;
    thisMonthExpense.value = expense;
    thisMonthTransactions.value = transactionCount;

    // Calculate net balance for this month
    final netBalance = income - expense;
    if (netBalance > 0) {
      // User will get money
      thisMonthToGet.value = netBalance;
      thisMonthToGive.value = 0.0;
    } else {
      // User will give money
      thisMonthToGive.value = netBalance.abs();
      thisMonthToGet.value = 0.0;
    }
  }

  void _calculateThisWeekData() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    // Get all transactions from mock data
    final allTransactions = _getAllTransactions();

    double income = 0.0; // You Got
    double expense = 0.0; // You Gave

    for (var transaction in allTransactions) {
      final date = transaction['date'] as DateTime;
      final transactionDate = DateTime(date.year, date.month, date.day);
      final weekStart = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day,
      );
      final weekEnd = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day);

      // Check if transaction is in current week
      if (transactionDate.isAfter(
            weekStart.subtract(const Duration(days: 1)),
          ) &&
          transactionDate.isBefore(weekEnd.add(const Duration(days: 1)))) {
        if (transaction['type'] == 'get') {
          income += (transaction['amount'] as num).toDouble();
        } else if (transaction['type'] == 'give') {
          expense += (transaction['amount'] as num).toDouble();
        }
      }
    }

    thisWeekIncome.value = income;
    thisWeekExpense.value = expense;
  }

  // Get all transactions from mock data
  // In a real app, this would fetch from a central database/service
  List<Map<String, dynamic>> _getAllTransactions() {
    final allTransactions = <Map<String, dynamic>>[];

    // Mock transactions for different customers/suppliers
    // These would come from a central transaction store in a real app
    final now = DateTime.now();

    // Add some mock transactions for current month
    allTransactions.addAll([
      {
        'id': '1',
        'date': DateTime(now.year, now.month, 1, 10, 30),
        'type': 'get',
        'amount': 5000.0,
        'note': 'Payment received',
      },
      {
        'id': '2',
        'date': DateTime(now.year, now.month, 5, 14, 15),
        'type': 'give',
        'amount': 3000.0,
        'note': 'Goods delivered',
      },
      {
        'id': '3',
        'date': DateTime(now.year, now.month, 10, 9, 0),
        'type': 'get',
        'amount': 2000.0,
        'note': '',
      },
      {
        'id': '4',
        'date': DateTime(now.year, now.month, 15, 11, 20),
        'type': 'give',
        'amount': 1500.0,
        'note': 'Purchase',
      },
      {
        'id': '5',
        'date': DateTime(now.year, now.month, 20, 16, 45),
        'type': 'get',
        'amount': 4000.0,
        'note': 'Sale',
      },
    ]);

    // Add transactions from customer detail mock data if they're in current month
    final customerTransactions = [
      {
        'id': 'c1',
        'date': DateTime(2025, 12, 12, 22, 52),
        'type': 'give',
        'amount': 10000.0,
        'note': '',
      },
      {
        'id': 'c2',
        'date': DateTime(2025, 12, 2, 7, 21),
        'type': 'get',
        'amount': 5555.0,
        'note': 'gdbdbdbdbd',
      },
      {
        'id': 'c3',
        'date': DateTime(2025, 12, 12, 7, 22),
        'type': 'give',
        'amount': 555.0,
        'note': 'fgfbdbdb',
      },
      {
        'id': 'c4',
        'date': DateTime(2025, 12, 12, 7, 19),
        'type': 'get',
        'amount': 5888.0,
        'note': '',
      },
      {
        'id': 'c5',
        'date': DateTime(2025, 12, 12, 10, 30),
        'type': 'give',
        'amount': 5000.0,
        'note': 'Payment received',
      },
      {
        'id': 'c6',
        'date': DateTime(2025, 12, 10, 14, 15),
        'type': 'get',
        'amount': 3000.0,
        'note': 'Goods delivered',
      },
      {
        'id': 'c7',
        'date': DateTime(2025, 12, 8, 9, 0),
        'type': 'give',
        'amount': 2000.0,
        'note': '',
      },
    ];

    // Filter transactions for current month
    for (var transaction in customerTransactions) {
      final date = transaction['date'] as DateTime;
      if (date.month == now.month && date.year == now.year) {
        allTransactions.add(transaction);
      }
    }

    return allTransactions;
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

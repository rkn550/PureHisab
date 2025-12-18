import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:purehisab/data/services/party_repo.dart';
import 'package:purehisab/data/services/transaction_repo.dart';
import 'home_controller.dart';
import '../app/routes/app_pages.dart';

class CustomerDetailController extends GetxController {
  final PartyRepository _partyRepository = PartyRepository();
  final TransactionRepository _transactionRepository = TransactionRepository();

  final RxString customerName = ''.obs;
  final RxString customerPhone = ''.obs;
  final RxString customerId = ''.obs;
  final RxBool isCustomer = true.obs;

  // Summary amounts
  final RxDouble amountToGive = 0.0.obs; // Amount user will give (green)
  final RxDouble amountToGet = 0.0.obs; // Amount user will get (red)

  // Collection reminder
  final RxString collectionReminderDate = ''.obs;
  final RxBool hasReminder = false.obs;

  // Store name
  final RxString storeName = ''.obs;

  // Transaction list
  final RxList<Map<String, dynamic>> transactions =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadCustomerData().then((_) {
      loadTransactions();
    });
  }

  Future<void> _loadCustomerData() async {
    final args = Get.arguments;
    String? partyId;

    if (args != null && args is Map<String, dynamic>) {
      partyId = args['id']?.toString();
    }

    if (partyId == null || partyId.isEmpty) {
      return;
    }

    try {
      final party = await _partyRepository.getPartyById(partyId);
      if (party != null) {
        customerId.value = party.id;
        customerName.value = party.partyName;
        customerPhone.value = party.phoneNumber ?? '';
        isCustomer.value = party.type == 'customer';
      }
    } catch (e) {
      print('Error loading party data: $e');
    }

    if (Get.isRegistered<HomeController>()) {
      try {
        final homeController = Get.find<HomeController>();
        storeName.value = homeController.storeName.value;
      } catch (e) {
        print('Error getting store name: $e');
      }
    }
  }

  Future<void> loadTransactions() async {
    if (customerId.value.isEmpty) return;

    try {
      final txList = await _transactionRepository.getTransactionsByParty(
        customerId.value,
      );

      transactions.clear();

      for (var tx in txList) {
        transactions.add({
          'id': tx.id,
          'amount': tx.amount,
          'type': tx.direction == 'gave' ? 'give' : 'get',
          'date': DateTime.fromMillisecondsSinceEpoch(tx.date),
          'description': tx.description,
          'balance': 0.0,
        });
      }

      transactions.sort((a, b) {
        final dateA = a['date'] as DateTime;
        final dateB = b['date'] as DateTime;
        return dateB.compareTo(dateA);
      });

      calculateSummary();
    } catch (e) {
      print('Error loading transactions: $e');
    }
  }

  void calculateSummary() {
    _calculateSummary();
    _calculateBalances();
  }

  void _calculateSummary() {
    double give = 0.0;
    double get = 0.0;

    for (var transaction in transactions) {
      if (transaction['type'] == 'give') {
        give += (transaction['amount'] as num).toDouble();
      } else {
        get += (transaction['amount'] as num).toDouble();
      }
    }

    // Calculate net balance
    final netBalance = get - give;

    if (netBalance > 0) {
      // User will get money
      amountToGet.value = netBalance;
      amountToGive.value = 0.0;
    } else {
      // User will give money
      amountToGive.value = netBalance.abs();
      amountToGet.value = 0.0;
    }
  }

  void _calculateBalances() {
    // Sort transactions by date (oldest first for balance calculation)
    final sortedTransactions = List<Map<String, dynamic>>.from(transactions);
    sortedTransactions.sort((a, b) {
      final dateA = a['date'] as DateTime;
      final dateB = b['date'] as DateTime;
      return dateA.compareTo(dateB);
    });

    double runningBalance = 0.0;

    // Calculate running balance for each transaction
    for (var transaction in sortedTransactions) {
      if (transaction['type'] == 'give') {
        runningBalance -= (transaction['amount'] as num).toDouble();
      } else {
        runningBalance += (transaction['amount'] as num).toDouble();
      }
      transaction['balance'] = runningBalance.abs();
    }

    // Sort back to most recent first for display
    transactions.sort((a, b) {
      final dateA = a['date'] as DateTime;
      final dateB = b['date'] as DateTime;
      return dateB.compareTo(dateA);
    });
  }

  // Group transactions by date
  Map<String, List<Map<String, dynamic>>> getGroupedTransactions() {
    final grouped = <String, List<Map<String, dynamic>>>{};

    for (var transaction in transactions) {
      final date = transaction['date'] as DateTime;
      final dateKey = _formatDateKey(date);

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);
    }

    return grouped;
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final transactionDate = DateTime(date.year, date.month, date.day);

    final difference = today.difference(transactionDate).inDays;

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

    final day = date.day;
    final month = months[date.month - 1];
    final year = date.year.toString().substring(2);

    if (difference == 0) {
      return '$day $month $year • Today';
    } else if (difference == 1) {
      return '$day $month $year • 1 day ago';
    } else if (difference < 7) {
      return '$day $month $year • $difference days ago';
    } else {
      return '$day $month $year';
    }
  }

  String formatTransactionTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  void setCollectionReminder(DateTime date) {
    collectionReminderDate.value = _formatDateKey(date);
    hasReminder.value = true;
  }

  void removeCollectionReminder() {
    collectionReminderDate.value = '';
    hasReminder.value = false;
  }

  void onReportTap() {
    // TODO: Implement report generation
    Get.snackbar('Report', 'Generating report...');
  }

  void onReminderTap() {
    // TODO: Implement reminder functionality
    Get.snackbar('Reminder', 'Sending reminder...');
  }

  String _getPaymentReminderMessage() {
    final amount = amountToGet.value > 0
        ? amountToGet.value
        : amountToGive.value;
    final formattedAmount = _formatAmount(amount);

    // Get date - use reminder date if set, otherwise use today
    String dateText;
    if (hasReminder.value && collectionReminderDate.value.isNotEmpty) {
      try {
        final parts = collectionReminderDate.value.split('-');
        if (parts.length == 3) {
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final day = int.parse(parts[2]);
          final date = DateTime(year, month, day);
          dateText = _formatDateForMessage(date);
        } else {
          dateText = _formatDateForMessage(DateTime.now());
        }
      } catch (e) {
        dateText = _formatDateForMessage(DateTime.now());
      }
    } else {
      dateText = _formatDateForMessage(DateTime.now());
    }

    // Get store phone number (you can get this from HomeController or use a default)
    String storePhone = '7991152422'; // Default store phone
    if (Get.isRegistered<HomeController>()) {
      try {
        // You can add store phone to HomeController if needed
      } catch (e) {
        // Use default
      }
    }

    final messageType = amountToGet.value > 0 ? 'payment' : 'collection';

    return '$storeName ($storePhone) has requested a $messageType of ₹ $formattedAmount on $dateText. Please visit https://purehisab.com/payment to view details';
  }

  String _formatDateForMessage(DateTime date) {
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
    return '${date.day} ${months[date.month - 1]} ${date.year.toString().substring(2)}';
  }

  String _formatAmount(double amount) {
    final formatter = amount.toStringAsFixed(0);
    final parts = formatter.split('.');
    final integerPart = parts[0];
    final reversed = integerPart.split('').reversed.join();
    final formatted = reversed.replaceAllMapped(
      RegExp(r'(\d{3})(?=\d)'),
      (match) => '${match.group(0)},',
    );
    return formatted.split('').reversed.join();
  }

  Future<void> onSMSTap() async {
    if (customerPhone.value.isEmpty) {
      Get.snackbar(
        'No Phone Number',
        'Phone number is not available for this contact',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Clean phone number (remove spaces, dashes, etc.)
    final cleanedPhone = customerPhone.value.replaceAll(RegExp(r'[^\d+]'), '');

    // If phone doesn't start with +, add +91 for India
    final phoneNumber = cleanedPhone.startsWith('+')
        ? cleanedPhone
        : '+91$cleanedPhone';

    // Create message
    final message = _getPaymentReminderMessage();

    // Create SMS URI with phone and message body
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: {'body': message},
    );

    try {
      final launched = await launchUrl(
        smsUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        Get.snackbar(
          'SMS',
          'Could not open SMS app. Phone: $phoneNumber',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'SMS',
        'Could not open SMS app. Phone: $phoneNumber',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> onWhatsAppTap() async {
    if (customerPhone.value.isEmpty) {
      Get.snackbar(
        'No Phone Number',
        'Phone number is not available for this contact',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      // Create and share the payment reminder card
      await _sharePaymentCardToWhatsApp();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not share card. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> _sharePaymentCardToWhatsApp() async {
    if (customerPhone.value.isEmpty) {
      Get.snackbar(
        'No Phone Number',
        'Phone number is not available for this contact',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Clean phone number (remove spaces, dashes, etc., but keep +)
    String cleanedPhone = customerPhone.value.replaceAll(RegExp(r'[^\d+]'), '');

    // Ensure country code is present (add +91 for India if not present)
    if (!cleanedPhone.startsWith('+')) {
      // Remove leading 0 if present
      if (cleanedPhone.startsWith('0')) {
        cleanedPhone = cleanedPhone.substring(1);
      }
      cleanedPhone = '+91$cleanedPhone';
    }

    // Remove + for WhatsApp (it needs just the digits with country code)
    final phoneNumber = cleanedPhone.replaceAll('+', '');

    // Create message with payment reminder details
    final message = Uri.encodeComponent(_getPaymentReminderMessage());

    try {
      // Try native WhatsApp URI first (whatsapp://send?phone=&text=)
      final nativeUri = Uri.parse(
        'whatsapp://send?phone=$phoneNumber&text=$message',
      );

      try {
        final launched = await launchUrl(
          nativeUri,
          mode: LaunchMode.externalApplication,
        );

        if (launched) {
          return; // Successfully opened WhatsApp
        }
      } catch (e) {
        // Native URI failed, try web link
      }

      // Fallback: Try web-based WhatsApp link (https://wa.me/?phone=&text=)
      final webUri = Uri.parse('https://wa.me/$phoneNumber?text=$message');
      final launched = await launchUrl(
        webUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        Get.snackbar(
          'WhatsApp',
          'WhatsApp not installed. Phone: +$phoneNumber',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'WhatsApp',
        'Could not open WhatsApp. Phone: +$phoneNumber\nPlease install WhatsApp or try again.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    }
  }

  void onYouGaveTap() {
    Get.toNamed(
      Routes.transactionEntry,
      arguments: {
        'type': 'give',
        'customerName': customerName.value,
        'customerId': customerId.value,
      },
    )?.then((result) {
      if (result != null &&
          result is Map<String, dynamic> &&
          result['success'] == true) {
        // Refresh transaction list
        loadTransactions();
        _calculateSummary();
      }
    });
  }

  void onYouGotTap() {
    Get.toNamed(
      Routes.transactionEntry,
      arguments: {
        'type': 'get',
        'customerName': customerName.value,
        'customerId': customerId.value,
      },
    )?.then((result) {
      if (result != null &&
          result is Map<String, dynamic> &&
          result['success'] == true) {
        // Refresh transaction list
        loadTransactions();
        _calculateSummary();
      }
    });
  }

  Future<void> makePhoneCall() async {
    if (customerPhone.value.isEmpty) {
      Get.snackbar(
        'No Phone Number',
        'Phone number is not available for this contact',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Clean phone number (remove spaces, dashes, etc.)
    final cleanedPhone = customerPhone.value.replaceAll(RegExp(r'[^\d+]'), '');

    // If phone doesn't start with +, add +91 for India
    final phoneNumber = cleanedPhone.startsWith('+')
        ? cleanedPhone
        : '+91$cleanedPhone';

    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    try {
      // Try to launch the phone dialer
      // Note: This may not work in emulators as they don't have phone functionality
      final launched = await launchUrl(
        phoneUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        // If launch failed, show the phone number so user can manually dial
        Get.snackbar(
          'Phone Dialer',
          'Phone number: $phoneNumber\n(Note: May not work in emulator)',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      // Show error with phone number so user can manually dial
      Get.snackbar(
        'Phone Dialer',
        'Could not open dialer. Phone: $phoneNumber\n(Note: Emulators may not support phone calls)',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    }
  }
}

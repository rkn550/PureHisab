import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:purehisab/data/services/party_repo.dart';
import 'package:purehisab/data/services/transaction_repo.dart';
import 'package:purehisab/data/services/reminder_notification_service.dart';
import 'home_controller.dart';
import '../app/routes/app_pages.dart';

class CustomerDetailController extends GetxController {
  PartyRepository get _partyRepository => Get.find<PartyRepository>();
  TransactionRepository get _transactionRepository =>
      Get.find<TransactionRepository>();
  ReminderNotificationService get _reminderNotificationService =>
      Get.find<ReminderNotificationService>();

  final RxString customerName = ''.obs;
  final RxString customerPhone = ''.obs;
  final RxString customerId = ''.obs;
  final RxBool isCustomer = true.obs;

  final RxDouble amountToGive = 0.0.obs;
  final RxDouble amountToGet = 0.0.obs;

  final RxString collectionReminderDate = ''.obs;
  final RxBool hasReminder = false.obs;

  final RxString storeName = ''.obs;

  final RxString smsLanguage = 'English'.obs;

  final RxList<Map<String, dynamic>> transactions =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCustomerData().then((_) {
      loadTransactions();
    });
  }

  Future<void> loadCustomerData() async {
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

        smsLanguage.value = party.smsLanguage ?? 'English';

        if (party.reminderDate != null) {
          final reminderDateTime = DateTime.fromMillisecondsSinceEpoch(
            party.reminderDate!,
          );
          collectionReminderDate.value = _formatDateKey(reminderDateTime);
          hasReminder.value = true;
        } else {
          collectionReminderDate.value = '';
          hasReminder.value = false;
        }
      }
    } catch (e) {
      debugPrint('Error loading customer data: $e');
    }

    if (Get.isRegistered<HomeController>()) {
      try {
        final homeController = Get.find<HomeController>();
        storeName.value = homeController.storeName.value;
      } catch (e) {
        debugPrint('Error loading store name: $e');
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
      debugPrint('Error loading transactions: $e');
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

    final netBalance = get - give;

    if (netBalance > 0) {
      amountToGet.value = netBalance;
      amountToGive.value = 0.0;
    } else {
      amountToGive.value = netBalance.abs();
      amountToGet.value = 0.0;
    }
  }

  void _calculateBalances() {
    final sortedTransactions = List<Map<String, dynamic>>.from(transactions);
    sortedTransactions.sort((a, b) {
      final dateA = a['date'] as DateTime;
      final dateB = b['date'] as DateTime;
      return dateA.compareTo(dateB);
    });

    double runningBalance = 0.0;

    for (var transaction in sortedTransactions) {
      if (transaction['type'] == 'give') {
        runningBalance -= (transaction['amount'] as num).toDouble();
      } else {
        runningBalance += (transaction['amount'] as num).toDouble();
      }
      transaction['balance'] = runningBalance.abs();
    }

    transactions.sort((a, b) {
      final dateA = a['date'] as DateTime;
      final dateB = b['date'] as DateTime;
      return dateB.compareTo(dateA);
    });
  }

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

  Future<void> setCollectionReminder(DateTime date) async {
    if (customerId.value.isEmpty) return;

    try {
      final party = await _partyRepository.getPartyById(customerId.value);
      if (party != null) {
        final reminderTimestamp = date.millisecondsSinceEpoch;
        final updatedParty = party.copyWith(
          reminderDate: reminderTimestamp,
          reminderType: 'collection',
        );
        await _partyRepository.updateParty(updatedParty);

        collectionReminderDate.value = _formatDateKey(date);
        hasReminder.value = true;

        final amount = amountToGet.value > 0
            ? amountToGet.value
            : amountToGive.value;
        final type = amountToGet.value > 0 ? 'get' : 'give';
        final notificationId = customerId.value.hashCode.abs() % 2147483647;

        await _reminderNotificationService.scheduleReminderNotification(
          notificationId: notificationId,
          partyId: customerId.value,
          partyName: customerName.value,
          reminderDate: date,
          amount: amount,
          type: type,
        );

        Get.snackbar(
          'Reminder Set',
          'You will receive a notification on ${_formatDateForMessage(date)}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to set reminder. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  Future<void> removeCollectionReminder() async {
    if (customerId.value.isEmpty) return;

    try {
      final party = await _partyRepository.getPartyById(customerId.value);
      if (party != null) {
        final updatedParty = party.copyWith(
          reminderDate: null,
          reminderType: null,
        );
        await _partyRepository.updateParty(updatedParty);

        collectionReminderDate.value = '';
        hasReminder.value = false;

        final notificationId = customerId.value.hashCode.abs() % 2147483647;
        await _reminderNotificationService.cancelReminderNotification(
          notificationId,
        );

        Get.snackbar(
          'Reminder Removed',
          'Notification has been cancelled',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade900,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to remove reminder. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  void onReportTap() {
    Get.snackbar('Report', 'Generating report...');
  }

  void onReminderTap() {
    Get.snackbar('Reminder', 'Sending reminder...');
  }

  String _getPaymentReminderMessage() {
    final amount = amountToGet.value > 0
        ? amountToGet.value
        : amountToGive.value;
    final formattedAmount = _formatAmount(amount);

    String dateText;
    if (hasReminder.value && collectionReminderDate.value.isNotEmpty) {
      try {
        final parts = collectionReminderDate.value.split('-');
        if (parts.length == 3) {
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final day = int.parse(parts[2]);
          final date = DateTime(year, month, day);
          dateText = smsLanguage.value == 'Hindi'
              ? _formatDateForMessageHindi(date)
              : _formatDateForMessage(date);
        } else {
          dateText = smsLanguage.value == 'Hindi'
              ? _formatDateForMessageHindi(DateTime.now())
              : _formatDateForMessage(DateTime.now());
        }
      } catch (e) {
        dateText = smsLanguage.value == 'Hindi'
            ? _formatDateForMessageHindi(DateTime.now())
            : _formatDateForMessage(DateTime.now());
      }
    } else {
      dateText = smsLanguage.value == 'Hindi'
          ? _formatDateForMessageHindi(DateTime.now())
          : _formatDateForMessage(DateTime.now());
    }

    String storePhone = '';
    if (Get.isRegistered<HomeController>()) {
      try {
        final homeController = Get.find<HomeController>();
        if (homeController.selectedBusinessId.value.isNotEmpty) {}
      } catch (e) {
        debugPrint('Error getting store phone: $e');
      }
    }

    final phoneText = storePhone.isNotEmpty ? ' ($storePhone)' : '';

    final messageType = amountToGet.value > 0 ? 'payment' : 'collection';

    if (smsLanguage.value == 'Hindi') {
      if (messageType == 'payment') {
        return '$storeName$phoneText ने ₹ $formattedAmount की राशि का भुगतान $dateText को करने का अनुरोध किया है। विवरण देखने के लिए कृपया https://purehisab.com/payment पर जाएं।';
      } else {
        return '$storeName$phoneText ने ₹ $formattedAmount की राशि की वसूली $dateText को करने का अनुरोध किया है। विवरण देखने के लिए कृपया https://purehisab.com/payment पर जाएं।';
      }
    } else {
      return '$storeName$phoneText has requested a $messageType of ₹ $formattedAmount on $dateText. Please visit https://purehisab.com/payment to view details';
    }
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

  String _formatDateForMessageHindi(DateTime date) {
    final months = [
      'जनवरी',
      'फरवरी',
      'मार्च',
      'अप्रैल',
      'मई',
      'जून',
      'जुलाई',
      'अगस्त',
      'सितंबर',
      'अक्टूबर',
      'नवंबर',
      'दिसंबर',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
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

    final cleanedPhone = customerPhone.value.replaceAll(RegExp(r'[^\d+]'), '');

    final phoneNumber = cleanedPhone.startsWith('+')
        ? cleanedPhone
        : '+91$cleanedPhone';

    final message = _getPaymentReminderMessage();

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

    String cleanedPhone = customerPhone.value.replaceAll(RegExp(r'[^\d+]'), '');

    if (!cleanedPhone.startsWith('+')) {
      if (cleanedPhone.startsWith('0')) {
        cleanedPhone = cleanedPhone.substring(1);
      }
      cleanedPhone = '+91$cleanedPhone';
    }

    final phoneNumber = cleanedPhone.replaceAll('+', '');

    final message = Uri.encodeComponent(_getPaymentReminderMessage());

    try {
      final nativeUri = Uri.parse(
        'whatsapp://send?phone=$phoneNumber&text=$message',
      );

      try {
        final launched = await launchUrl(
          nativeUri,
          mode: LaunchMode.externalApplication,
        );

        if (launched) {
          return;
        }
      } catch (e) {
        debugPrint('Error opening WhatsApp: $e');
      }

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

    final cleanedPhone = customerPhone.value.replaceAll(RegExp(r'[^\d+]'), '');

    final phoneNumber = cleanedPhone.startsWith('+')
        ? cleanedPhone
        : '+91$cleanedPhone';

    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    try {
      final launched = await launchUrl(
        phoneUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        Get.snackbar(
          'Phone Dialer',
          'Phone number: $phoneNumber\n(Note: May not work in emulator)',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Phone Dialer',
        'Could not open dialer. Phone: $phoneNumber\n(Note: Emulators may not support phone calls)',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    }
  }
}

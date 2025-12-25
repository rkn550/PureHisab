import 'package:get/get.dart';
import 'package:purehisab/controllers/navigation_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:purehisab/app/utils/snacks_bar.dart';
import 'package:purehisab/data/services/party_repo.dart';
import 'package:purehisab/data/services/transaction_repo.dart';
import 'package:purehisab/data/services/reminder_notification_service.dart';
import '../app/routes/app_pages.dart';

class PartiesDetailController extends GetxController {
  PartyRepository get _partyRepository => Get.find<PartyRepository>();
  TransactionRepository get _transactionRepository =>
      Get.find<TransactionRepository>();
  ReminderNotificationService get _reminderNotificationService =>
      Get.find<ReminderNotificationService>();

  final RxBool _isLoading = false.obs;
  final RxString _partyId = ''.obs;
  final RxString _partyName = ''.obs;
  final RxString _partyPhone = ''.obs;
  final RxString _partyType = ''.obs;
  final RxString _smsLanguage = 'english'.obs;
  final RxBool _hasReminder = false.obs;
  final RxString _collectionReminderDate = ''.obs;
  final RxBool _smsSetting = false.obs;
  final RxString _businessId = ''.obs;
  final RxDouble _amountToGet = 0.0.obs;
  final RxDouble _amountToGive = 0.0.obs;
  final RxList<Map<String, dynamic>> _transactions =
      <Map<String, dynamic>>[].obs;

  bool get isLoading => _isLoading.value;
  String get partyId => _partyId.value;
  String get partyName => _partyName.value;
  String get partyPhone => _partyPhone.value;
  String get partyType => _partyType.value;
  String get smsLanguage => _smsLanguage.value;
  bool get hasReminder => _hasReminder.value;
  String get collectionReminderDate => _collectionReminderDate.value;
  bool get smsSetting => _smsSetting.value;
  String get businessId => _businessId.value;
  double get amountToGet => _amountToGet.value;
  double get amountToGive => _amountToGive.value;
  List<Map<String, dynamic>> get transactions => _transactions;

  @override
  void onInit() {
    super.onInit();
    loadPartyIdFromArguments();
    Future.microtask(() => reloadPartyData());
  }

  void loadPartyIdFromArguments() {
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      _partyId.value =
          args['partyId']?.toString() ?? args['id']?.toString() ?? '';
    }
  }

  Future<void> loadPartyData() async {
    if (partyId.isEmpty) return;
    try {
      final party = await _partyRepository.getPartyById(partyId);
      if (party != null) {
        _partyName.value = party.partyName;
        _partyPhone.value = party.phoneNumber;
        _partyType.value = party.type;
        _smsLanguage.value = party.smsLanguage ?? 'english';
        _hasReminder.value = party.reminderDate != null;
        _smsSetting.value = party.smsSetting;
        _businessId.value = party.businessId;
        _collectionReminderDate.value = party.reminderDate != null
            ? _formatDateKey(
                DateTime.fromMillisecondsSinceEpoch(party.reminderDate!),
              )
            : '';
      }
    } catch (e) {}
  }

  Future<void> reloadPartyData() async {
    _isLoading.value = true;
    await loadPartyData();
    await loadTransactions();
    _isLoading.value = false;
  }

  Future<void> loadTransactions() async {
    if (partyId.isEmpty) return;
    try {
      final txList = await _transactionRepository.getTransactionsByPartyId(
        partyId,
      );
      _transactions.clear();
      for (var tx in txList) {
        _transactions.add({
          'id': tx.id,
          'amount': tx.amount,
          'type': tx.direction == 'gave' ? 'give' : 'get',
          'date': DateTime.fromMillisecondsSinceEpoch(tx.date),
          'transaction_photo_url': tx.transactionPhotoUrl,
          'description': tx.description,
          'balance': 0.0,
        });
      }

      _transactions.sort((a, b) {
        final dateA = a['date'] as DateTime;
        final dateB = b['date'] as DateTime;
        return dateB.compareTo(dateA);
      });
      calculateSummary();
    } catch (e) {}
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
      _amountToGet.value = netBalance;
      _amountToGive.value = 0.0;
    } else {
      _amountToGive.value = netBalance.abs();
      _amountToGet.value = 0.0;
    }
  }

  void _calculateBalances() {
    final sortedTransactions = List<Map<String, dynamic>>.from(_transactions);
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
    for (var sortedTx in sortedTransactions) {
      final index = _transactions.indexWhere(
        (tx) => tx['id'] == sortedTx['id'],
      );
      if (index != -1) {
        _transactions[index]['balance'] = sortedTx['balance'];
      }
    }

    _transactions.sort((a, b) {
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
    if (partyId.isEmpty) return;

    try {
      final party = await _partyRepository.getPartyById(partyId);
      if (party != null) {
        final reminderTimestamp = date.millisecondsSinceEpoch;
        final updatedParty = party.copyWith(
          reminderDate: reminderTimestamp,
          reminderType: 'collection',
        );
        await _partyRepository.updateParty(updatedParty);
        await loadPartyData();

        _collectionReminderDate.value = _formatDateKey(date);
        _hasReminder.value = true;

        final amount = amountToGet > 0 ? amountToGet : amountToGive;
        final type = amountToGet > 0 ? 'get' : 'give';
        final notificationId = partyId.hashCode.abs() % 2147483647;

        await _reminderNotificationService.scheduleReminderNotification(
          notificationId: notificationId,
          partyId: partyId,
          partyName: partyName,
          reminderDate: date,
          amount: amount,
          type: type,
        );

        SnacksBar.showSnackbar(
          title: 'Reminder Set',
          message:
              'You will receive a notification on ${_formatDateForMessage(date)}',
          type: SnacksBarType.SUCCESS,
        );
      }
    } catch (e) {
      SnacksBar.showSnackbar(
        title: 'Error',
        message: 'Failed to set reminder. Please try again.',
        type: SnacksBarType.ERROR,
      );
    }
  }

  Future<void> removeCollectionReminder() async {
    if (partyId.isEmpty) return;

    try {
      final party = await _partyRepository.getPartyById(partyId);
      if (party != null) {
        final updatedParty = party.copyWith(
          reminderDate: null,
          reminderType: null,
        );
        await _partyRepository.updateParty(updatedParty);
        await loadPartyData();
        _collectionReminderDate.value = '';
        _hasReminder.value = false;
        final notificationId = partyId.hashCode.abs() % 2147483647;
        await _reminderNotificationService.cancelReminderNotification(
          notificationId,
        );
        SnacksBar.showSnackbar(
          title: 'Reminder Removed',
          message: 'Notification has been cancelled',
          type: SnacksBarType.SUCCESS,
        );
      }
    } catch (e) {
      SnacksBar.showSnackbar(
        title: 'Error',
        message: 'Failed to remove reminder. Please try again.',
        type: SnacksBarType.ERROR,
      );
    }
  }

  void onReportTap() {
    SnacksBar.showSnackbar(
      title: 'Report',
      message: 'Generating report...',
      type: SnacksBarType.INFO,
    );
  }

  void onReminderTap() {
    SnacksBar.showSnackbar(
      title: 'Reminder',
      message: 'Sending reminder...',
      type: SnacksBarType.INFO,
    );
  }

  String _getPaymentReminderMessage() {
    final amount = amountToGet > 0 ? amountToGet : amountToGive;
    final formattedAmount = _formatAmount(amount);

    String dateText;
    if (hasReminder && collectionReminderDate.isNotEmpty) {
      try {
        final parts = collectionReminderDate.split('-');
        if (parts.length == 3) {
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final day = int.parse(parts[2]);
          final date = DateTime(year, month, day);
          dateText = smsLanguage.toLowerCase() == 'hindi'
              ? _formatDateForMessageHindi(date)
              : _formatDateForMessage(date);
        } else {
          dateText = smsLanguage.toLowerCase() == 'hindi'
              ? _formatDateForMessageHindi(DateTime.now())
              : _formatDateForMessage(DateTime.now());
        }
      } catch (e) {
        dateText = smsLanguage.toLowerCase() == 'hindi'
            ? _formatDateForMessageHindi(DateTime.now())
            : _formatDateForMessage(DateTime.now());
      }
    } else {
      dateText = smsLanguage.toLowerCase() == 'hindi'
          ? _formatDateForMessageHindi(DateTime.now())
          : _formatDateForMessage(DateTime.now());
    }

    final messageType = amountToGet > 0 ? 'payment' : 'collection';
    String ownerName = '';
    String ownerPhone = '';
    if (Get.isRegistered<NavigationController>()) {
      try {
        final navController = Get.find<NavigationController>();
        final business = navController.businesses
            .where((b) => b.id == businessId)
            .firstOrNull;
        ownerName = business?.ownerName ?? '';
        ownerPhone = business?.phoneNumber ?? '';
      } catch (e) {
        ownerName = '';
        ownerPhone = '';
      }
    }

    if (smsLanguage.toLowerCase() == 'hindi') {
      final messageTypeHindi = messageType == 'payment' ? 'भुगतान' : 'वसूली';
      return '$ownerName ने ₹ $formattedAmount की राशि की $messageTypeHindi $dateText को करने का अनुरोध किया है। अधिक जानकारी के लिए कृपया $ownerPhone पर कॉल करें।';
    } else {
      return '$ownerName has requested a $messageType of ₹ $formattedAmount on $dateText. Please call at $ownerPhone to know more details.';
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
    if (partyPhone.isEmpty) {
      SnacksBar.showSnackbar(
        title: 'No Phone Number',
        message: 'Phone number is not available for this contact',
        type: SnacksBarType.WARNING,
      );
      return;
    }

    final cleanedPhone = partyPhone.replaceAll(RegExp(r'[^\d+]'), '');

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
        SnacksBar.showSnackbar(
          title: 'SMS',
          message: 'Could not open SMS app. Phone: $phoneNumber',
          type: SnacksBarType.WARNING,
        );
      }
    } catch (e) {
      SnacksBar.showSnackbar(
        title: 'SMS',
        message: 'Could not open SMS app. Phone: $phoneNumber',
        type: SnacksBarType.WARNING,
      );
    }
  }

  Future<void> onWhatsAppTap() async {
    if (partyPhone.isEmpty) {
      SnacksBar.showSnackbar(
        title: 'No Phone Number',
        message: 'Phone number is not available for this contact',
        type: SnacksBarType.WARNING,
      );
      return;
    }

    try {
      await _sharePaymentCardToWhatsApp();
    } catch (e) {
      SnacksBar.showSnackbar(
        title: 'Error',
        message: 'Could not share card. Please try again.',
        type: SnacksBarType.ERROR,
      );
    }
  }

  Future<void> _sharePaymentCardToWhatsApp() async {
    if (partyPhone.isEmpty) {
      SnacksBar.showSnackbar(
        title: 'No Phone Number',
        message: 'Phone number is not available for this contact',
        type: SnacksBarType.WARNING,
      );
      return;
    }

    String cleanedPhone = partyPhone.replaceAll(RegExp(r'[^\d+]'), '');

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
      } catch (e) {}

      final webUri = Uri.parse('https://wa.me/$phoneNumber?text=$message');
      final launched = await launchUrl(
        webUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        SnacksBar.showSnackbar(
          title: 'WhatsApp',
          message: 'WhatsApp not installed. Phone: +$phoneNumber',
          type: SnacksBarType.WARNING,
        );
      }
    } catch (e) {
      SnacksBar.showSnackbar(
        title: 'WhatsApp',
        message:
            'Could not open WhatsApp. Phone: +$phoneNumber\nPlease install WhatsApp or try again.',
        type: SnacksBarType.ERROR,
      );
    }
  }

  void onYouGaveTap() async {
    await Get.toNamed(
      Routes.transactionEntry,
      arguments: {'type': 'give', 'partyId': partyId, 'businessId': businessId},
    );
    await reloadPartyData();
  }

  void onYouGotTap() async {
    await Get.toNamed(
      Routes.transactionEntry,
      arguments: {'type': 'get', 'partyId': partyId, 'businessId': businessId},
    );
    await reloadPartyData();
  }

  Future<void> makePhoneCall() async {
    if (partyPhone.isEmpty) {
      SnacksBar.showSnackbar(
        title: 'No Phone Number',
        message: 'Phone number is not available for this contact',
        type: SnacksBarType.WARNING,
      );
      return;
    }

    final cleanedPhone = partyPhone.replaceAll(RegExp(r'[^\d+]'), '');

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
        SnacksBar.showSnackbar(
          title: 'Phone Dialer',
          message:
              'Phone number: $phoneNumber\n(Note: May not work in emulator)',
          type: SnacksBarType.INFO,
        );
      }
    } catch (e) {
      SnacksBar.showSnackbar(
        title: 'Phone Dialer',
        message:
            'Could not open dialer. Phone: $phoneNumber\n(Note: Emulators may not support phone calls)',
        type: SnacksBarType.WARNING,
      );
    }
  }
}

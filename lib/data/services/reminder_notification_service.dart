import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:purehisab/data/services/party_repo.dart';
import 'package:purehisab/data/services/business_repo.dart';
import 'package:purehisab/data/services/transaction_repo.dart';
import 'package:purehisab/app/routes/app_pages.dart';

class ReminderNotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  PartyRepository get _partyRepository => Get.find<PartyRepository>();
  BusinessRepository get _businessRepository => Get.find<BusinessRepository>();
  TransactionRepository get _transactionRepository =>
      Get.find<TransactionRepository>();

  bool _isInitialized = false;

  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(milliseconds: 500), () {
      _initializeNotifications();
    });
  }

  Future<void> _initializeNotifications() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    } catch (e) {
      try {
        tz.setLocalLocation(tz.UTC);
      } catch (e2) {
        return;
      }
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Initialization settings
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      // Initialize plugin
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Request permissions
      await _requestPermissions();

      _isInitialized = true;
    } catch (e) {}
  }

  Future<void> _requestPermissions() async {
    try {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
      }

      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (iosPlugin != null) {
        await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    } catch (e) {}
  }

  void _onNotificationTapped(NotificationResponse response) {
    final partyId = response.payload;

    if (partyId != null && partyId.isNotEmpty) {
      try {
        Get.toNamed(Routes.partiesDetails, arguments: {'partyId': partyId});
      } catch (e) {}
    }
  }

  Future<void> scheduleReminderNotification({
    required int notificationId,
    required String partyId,
    required String partyName,
    required DateTime reminderDate,
    required double amount,
    required String type,
  }) async {
    if (!_isInitialized) {
      await _initializeNotifications();
    }
    await cancelReminderNotification(notificationId);
    final scheduledDate = tz.TZDateTime(
      tz.local,
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      9,
      0,
    );

    final now = tz.TZDateTime.now(tz.local);

    if (scheduledDate.isBefore(now)) {
      return;
    }

    final amountText = _formatAmount(amount);
    final messageType = type == 'give' ? 'collection' : 'payment';
    final title = 'Reminder: $messageType from $partyName';
    final body =
        'You have a $messageType of ₹ $amountText scheduled for today.';

    const androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Collection Reminders',
      channelDescription: 'Notifications for collection reminders',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.zonedSchedule(
        notificationId,
        title,
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: partyId,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancelReminderNotification(int notificationId) async {
    try {
      await _notifications.cancel(notificationId);
    } catch (e) {}
  }

  Future<void> cancelAllReminders() async {
    try {
      await _notifications.cancelAll();
    } catch (e) {}
  }

  Future<void> checkAndScheduleAllReminders() async {
    if (!_isInitialized) {
      await _initializeNotifications();
    }

    if (!_isInitialized) {
      return;
    }

    try {
      if (!Get.isRegistered<BusinessRepository>() ||
          !Get.isRegistered<PartyRepository>() ||
          !Get.isRegistered<TransactionRepository>()) {
        return;
      }

      final businesses = await _businessRepository.getBusinesses();

      for (var business in businesses) {
        final parties = await _partyRepository.getPartiesByBusiness(
          business.id,
        );

        for (var party in parties) {
          if (party.reminderDate != null && party.reminderDate! > 0) {
            final reminderDate = DateTime.fromMillisecondsSinceEpoch(
              party.reminderDate!,
            );

            double amount = 0.0;
            String type = 'give';
            try {
              final transactions = await _transactionRepository
                  .getTransactionsByPartyId(party.id);
              double give = 0.0;
              double get = 0.0;

              for (var tx in transactions) {
                if (tx.direction == 'gave') {
                  give += tx.amount;
                } else {
                  get += tx.amount;
                }
              }

              final netBalance = get - give;
              if (netBalance > 0) {
                amount = netBalance;
                type = 'get';
              } else {
                amount = netBalance.abs();
                type = 'give';
              }
            } catch (e) {}

            if (amount > 0) {
              final notificationId = party.id.hashCode.abs() % 2147483647;

              try {
                await scheduleReminderNotification(
                  notificationId: notificationId,
                  partyId: party.id,
                  partyName: party.partyName,
                  reminderDate: reminderDate,
                  amount: amount,
                  type: type,
                );
              } catch (e) {}
            }
          }
        }
      }
    } catch (e) {}
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

  Future<void> debugPendingNotifications() async {
    try {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlugin != null) {
        await androidPlugin.pendingNotificationRequests();
      }
    } catch (e) {}
  }
}

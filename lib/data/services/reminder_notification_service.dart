import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:purehisab/data/services/party_repo.dart';
import 'package:purehisab/data/services/business_repo.dart';
import 'package:purehisab/data/services/transaction_repo.dart';

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
    // Initialize asynchronously to avoid blocking app startup
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
      debugPrint('Error initializing timezone: $e');
      // Fallback to UTC if timezone initialization fails
      try {
        tz.setLocalLocation(tz.UTC);
      } catch (e2) {
        debugPrint('Error setting UTC timezone: $e2');
        return;
      }
    }

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS initialization settings
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
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
      // Don't block app startup if notifications fail to initialize
    }
  }

  Future<void> _requestPermissions() async {
    try {
      // Android 13+ requires notification permission
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
      }

      // iOS permissions
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
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - can navigate to customer detail screen
    // For now, just log it
    debugPrint('Notification tapped: ${response.payload}');
  }

  Future<void> scheduleReminderNotification({
    required int notificationId,
    required String partyId,
    required String partyName,
    required DateTime reminderDate,
    required double amount,
    required String type, // 'give' or 'get'
  }) async {
    if (!_isInitialized) {
      await _initializeNotifications();
    }

    // Cancel existing notification for this party if any
    await cancelReminderNotification(notificationId);

    // Schedule notification for reminder date at 9 AM
    final scheduledDate = tz.TZDateTime(
      tz.local,
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      9, // 9 AM
      0,
    );

    // Don't schedule if date is in the past
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    final amountText = _formatAmount(amount);
    final messageType = type == 'give' ? 'collection' : 'payment';
    final title = 'Reminder: $messageType from $partyName';
    final body =
        'You have a $messageType of ₹ $amountText scheduled for today.';

    // Android notification details
    const androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Collection Reminders',
      channelDescription: 'Notifications for collection reminders',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    // iOS notification details
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // Notification details
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule notification
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
  }

  Future<void> cancelReminderNotification(int notificationId) async {
    await _notifications.cancel(notificationId);
  }

  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }

  // Check and schedule all reminders from database
  Future<void> checkAndScheduleAllReminders() async {
    if (!_isInitialized) {
      await _initializeNotifications();
    }

    if (!_isInitialized) {
      debugPrint('Notifications not initialized, skipping reminder scheduling');
      return;
    }

    try {
      // Check if repositories are available
      if (!Get.isRegistered<BusinessRepository>() ||
          !Get.isRegistered<PartyRepository>() ||
          !Get.isRegistered<TransactionRepository>()) {
        debugPrint('Repositories not available, skipping reminder scheduling');
        return;
      }

      // Get all businesses for current user
      final businesses = await _businessRepository.getBusinesses();

      for (var business in businesses) {
        // Get all parties for this business
        final parties = await _partyRepository.getPartiesByBusiness(
          business.id,
        );

        for (var party in parties) {
          if (party.reminderDate != null && party.reminderDate! > 0) {
            final reminderDate = DateTime.fromMillisecondsSinceEpoch(
              party.reminderDate!,
            );

            // Calculate amount from transactions
            double amount = 0.0;
            String type = 'give';
            try {
              final transactions = await _transactionRepository
                  .getTransactionsByParty(party.id);
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
            } catch (e) {
              debugPrint('Error calculating amount for reminder: $e');
            }

            // Only schedule if amount > 0
            if (amount > 0) {
              // Use party ID hash as notification ID
              final notificationId = party.id.hashCode.abs() % 2147483647;

              await scheduleReminderNotification(
                notificationId: notificationId,
                partyId: party.id,
                partyName: party.partyName,
                reminderDate: reminderDate,
                amount: amount,
                type: type,
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error scheduling reminders: $e');
    }
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
}

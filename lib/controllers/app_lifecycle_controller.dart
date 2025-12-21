import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purehisab/data/services/app_lock_service.dart';
import 'package:purehisab/data/services/reminder_notification_service.dart';
import '../app/routes/app_pages.dart';

class AppLifecycleController extends GetxController
    with WidgetsBindingObserver {
  AppLockService get _appLockService => Get.find<AppLockService>();
  ReminderNotificationService get _reminderNotificationService =>
      Get.find<ReminderNotificationService>();
  bool _isLockScreenShown = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _checkInitialLockState();
    _scheduleAllReminders();
  }

  Future<void> _scheduleAllReminders() async {
    Future.delayed(const Duration(seconds: 2), () {
      _reminderNotificationService.checkAndScheduleAllReminders();
    });
  }

  Future<void> _checkInitialLockState() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final isLockEnabled = await _appLockService.isLockEnabled();
    if (isLockEnabled && Get.currentRoute != Routes.appLock) {
      final shouldLock = await _appLockService.shouldShowLock();
      if (shouldLock) {
        _isLockScreenShown = true;
        Get.toNamed(Routes.appLock);
      }
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAndShowLock();
      // Check and reschedule reminders when app resumes
      _reminderNotificationService.checkAndScheduleAllReminders();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _isLockScreenShown = false;
    }
  }

  Future<void> _checkAndShowLock() async {
    if (_isLockScreenShown) return;

    final shouldLock = await _appLockService.shouldShowLock();
    if (shouldLock && Get.currentRoute != Routes.appLock) {
      _isLockScreenShown = true;
      Get.toNamed(Routes.appLock);
    }
  }

  void onUnlockSuccess() {
    _isLockScreenShown = false;
  }
}

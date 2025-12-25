import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLockService extends GetxService {
  static const String _lockEnabledKey = 'app_lock_enabled';
  static const String _pinKey = 'app_lock_pin';
  static const String _lastUnlockTimeKey = 'app_lock_last_unlock';
  static const int _lockTimeoutSeconds = 120;

  Future<bool> isLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_lockEnabledKey) ?? false;
  }

  Future<void> setLockEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_lockEnabledKey, enabled);
  }

  Future<bool> hasPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pinKey) != null;
  }

  Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, pin);
  }

  Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString(_pinKey);
    if (savedPin == null) return false;
    return savedPin == pin;
  }

  Future<bool> shouldShowLock() async {
    final isEnabled = await isLockEnabled();
    if (!isEnabled) return false;

    final prefs = await SharedPreferences.getInstance();
    final lastUnlockTime = prefs.getInt(_lastUnlockTimeKey);
    if (lastUnlockTime == null) return true;

    final now = DateTime.now().millisecondsSinceEpoch;
    final timeSinceUnlock = (now - lastUnlockTime) ~/ 1000;

    return timeSinceUnlock >= _lockTimeoutSeconds;
  }

  Future<void> _updateLastUnlockTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _lastUnlockTimeKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<void> onUnlockSuccess() async {
    await _updateLastUnlockTime();
  }

  Future<void> clearPin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinKey);
  }
}

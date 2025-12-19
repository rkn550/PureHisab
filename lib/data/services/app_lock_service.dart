import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLockService extends GetxService {
  static const String _lockEnabledKey = 'app_lock_enabled';
  static const String _pinKey = 'app_lock_pin';
  static const String _lastUnlockTimeKey = 'app_lock_last_unlock';
  static const int _lockTimeoutSeconds = 120;

  final LocalAuthentication _localAuth = LocalAuthentication();

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

  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable || isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to unlock PureHisab',
      );

      if (authenticated) {
        await _updateLastUnlockTime();
      }

      return authenticated;
    } catch (e) {
      return false;
    }
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

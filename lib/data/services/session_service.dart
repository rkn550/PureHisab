import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:purehisab/data/model/user_model.dart';

class SessionService extends GetxService {
  final _box = GetStorage();
  static const String _sessionKey = 'current_user';

  Future<void> saveSession(UserModel user) async {
    await _box.write(_sessionKey, user.toMap());
  }

  Future<UserModel?> getSession() async {
    final user = _box.read(_sessionKey);
    if (user == null) return null;
    if (user is! Map<String, dynamic>) return null;
    return UserModel.fromMap(user, user['uid'] ?? '');
  }

  Future<void> clearSession() async {
    await _box.remove(_sessionKey);
  }

  bool get isLoggedIn => _box.hasData(_sessionKey);
}

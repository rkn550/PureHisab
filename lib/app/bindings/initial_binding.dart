import 'package:get/get.dart';
import 'package:purehisab/controllers/app_lifecycle_controller.dart';
import 'package:purehisab/data/services/app_lock_service.dart';
import 'package:purehisab/data/services/auth_service.dart';
import 'package:purehisab/data/services/business_repo.dart';
import 'package:purehisab/data/services/party_repo.dart';
import 'package:purehisab/data/services/reminder_notification_service.dart';
import 'package:purehisab/data/services/session_service.dart';
import 'package:purehisab/data/services/transaction_repo.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AppLifecycleController());
    Get.put(AppLockService(), permanent: true);
    Get.put(AuthService(), permanent: true);
    Get.put(SessionService(), permanent: true);
    Get.lazyPut(() => BusinessRepository(), fenix: true);
    Get.lazyPut(() => PartyRepository(), fenix: true);
    Get.lazyPut(() => TransactionRepository(), fenix: true);
    Get.lazyPut(() => ReminderNotificationService(), fenix: true);
  }
}

import 'package:get/get.dart';
import '../../controllers/app_lock_controller.dart';

class AppLockBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AppLockController>(() => AppLockController());
  }
}

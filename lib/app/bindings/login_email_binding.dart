import 'package:get/get.dart';
import 'package:purehisab/controllers/login_email_controller.dart';

class LoginEmailBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<LoginEmailController>(LoginEmailController());
  }
}

import 'package:get/get.dart';
import '../../controllers/business_profile_controller.dart';

class CreateAccountBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BusinessProfileController>(() => BusinessProfileController());
  }
}

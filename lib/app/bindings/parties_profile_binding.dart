import 'package:get/get.dart';
import '../../controllers/parties_profile_controller.dart';

class PartiesProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PartiesProfileController>(() => PartiesProfileController());
  }
}

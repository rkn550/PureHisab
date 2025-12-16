import 'package:get/get.dart';
import '../../controllers/add_party_controller.dart';

class AddPartyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddPartyController>(() => AddPartyController());
  }
}

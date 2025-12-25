import 'package:get/get.dart';
import '../../controllers/parties_detail_controller.dart';

class PartiesDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PartiesDetailController>(() => PartiesDetailController());
  }
}

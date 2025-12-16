import 'package:get/get.dart';
import '../../controllers/navigation_controller.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/business_profile_controller.dart';
import '../../controllers/analytics_controller.dart';

class NavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavigationController>(() => NavigationController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<BusinessProfileController>(() => BusinessProfileController());
    Get.lazyPut<AnalyticsController>(() => AnalyticsController());
  }
}

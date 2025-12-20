import 'package:get/get.dart';
import 'business_profile_controller.dart';
import 'home_controller.dart';
import 'analytics_controller.dart';

class NavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final RxString phoneNumber = ''.obs;
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _getArguments();

    ever(currentIndex, (index) {
      if (index == 2) {
        _loadSelectedBusinessProfile();
      } else if (index == 0) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (Get.isRegistered<AnalyticsController>()) {
            Get.find<AnalyticsController>().refreshAnalytics();
          }
        });
      }
    });
  }

  void _getArguments() {
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      if (args.containsKey('initialTab')) {
        currentIndex.value = args['initialTab'] as int? ?? 0;
      }

      if (args.containsKey('phoneNumber')) {
        phoneNumber.value = args['phoneNumber'] as String? ?? '';
      }
      if (args.containsKey('userName')) {
        userName.value = args['userName'] as String? ?? '';
      }
      if (args.containsKey('userEmail')) {
        userEmail.value = args['userEmail'] as String? ?? '';
      }
    }
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }

  void _loadSelectedBusinessProfile() {
    if (Get.isRegistered<HomeController>()) {
      try {
        final homeController = Get.find<HomeController>();
        for (var account in homeController.accountsList) {
          if (account['isSelected'] == true) {
            final businessId = account['id']?.toString();
            if (businessId != null && businessId.isNotEmpty) {
              if (Get.isRegistered<BusinessProfileController>()) {
                final businessProfileController =
                    Get.find<BusinessProfileController>();
                businessProfileController.loadBusinessById(businessId);
              }
              return;
            }
          }
        }
      } catch (e) {
        throw Exception('Error loading selected business profile: $e');
      }
    }
  }
}

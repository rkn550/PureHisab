import 'package:get/get.dart';

class NavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final RxString phoneNumber = ''.obs;
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _getArguments();
  }

  void _getArguments() {
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      // Get initial tab index if provided
      if (args.containsKey('initialTab')) {
        currentIndex.value = args['initialTab'] as int? ?? 0;
      }

      // Get user data if provided
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
}

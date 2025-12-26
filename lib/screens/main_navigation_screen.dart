import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purehisab/screens/business_profile_screen.dart';
import '../controllers/navigation_controller.dart';
import '../app/utils/app_colors.dart';
import 'widgets/common_app_bar.dart';
import '../app/routes/app_pages.dart';
import 'analytics_screen.dart';
import 'home_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  final int? initialTab;
  final Map<String, dynamic>? arguments;

  const MainNavigationScreen({super.key, this.initialTab, this.arguments});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NavigationController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setInitialTab(initialTab ?? 1);
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _showExitConfirmationDialog(context);
        }
      },
      child: Scaffold(
        appBar: _ReactiveAppBar(),
        body: Obx(
          () => IndexedStack(
            index: controller.currentIndex,
            children: const [
              AnalyticsScreen(),
              HomeScreen(),
              BusinessProfileScreen(),
            ],
          ),
        ),
        bottomNavigationBar: Obx(
          () => BottomNavigationBar(
            currentIndex: controller.currentIndex,
            onTap: controller.setInitialTab,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            selectedFontSize: 14,
            unselectedFontSize: 12,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics_outlined),
                activeIcon: Icon(Icons.analytics),
                label: 'Analytics',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExitConfirmationDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Exit App',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to exit the app?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ),
          const SizedBox(width: 4),
          TextButton(
            onPressed: () {
              Get.back();
              SystemNavigator.pop();
            },
            child: const Text(
              'Exit',
              style: TextStyle(fontSize: 16, color: AppColors.primary),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}

class _ReactiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ReactiveAppBar();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NavigationController>();

    return CommonAppBar(
      showBackButton: false,
      showDropdown: true,
      onTitleTap: () => controller.openBusinessListBottomSheet(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CreateBusinessBottomSheet extends StatelessWidget {
  const CreateBusinessBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Icon(Icons.business, size: 60, color: AppColors.primary),
          const SizedBox(height: 20),
          const Text(
            'Create Your First Business',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Start managing your accounts by creating your first business profile',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 26),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed(Routes.createBusiness);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'CREATE BUSINESS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BusinessListBottomSheet extends StatelessWidget {
  const BusinessListBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NavigationController>();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Account',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Flexible(
            child: Obx(
              () => ListView.builder(
                shrinkWrap: true,
                itemCount: controller.businesses.length,
                itemBuilder: (context, index) {
                  final business = controller.businesses[index];
                  final name = business.businessName;
                  final isSelected = business.id == controller.businessId;
                  final customerCount = controller.getCustomerCount(
                    business.id,
                  );

                  return InkWell(
                    onTap: () {
                      controller.businessId = business.id;
                      Get.back();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                name.isNotEmpty
                                    ? name
                                          .split(' ')
                                          .map(
                                            (w) => w.isNotEmpty
                                                ? w[0].toUpperCase()
                                                : '',
                                          )
                                          .take(2)
                                          .join()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$customerCount ${customerCount == 1 ? 'Customer' : 'Customers'}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey.shade400,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                Get.back();
                Get.toNamed(Routes.createBusiness);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'CREATE NEW BUSINESS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

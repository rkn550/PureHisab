import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purehisab/screens/business_profile_screen.dart';
import '../controllers/navigation_controller.dart';
import '../controllers/home_controller.dart';
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
    final homeController = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : null;

    return Scaffold(
      appBar: _ReactiveAppBar(),
      body: Stack(
        children: [
          Obx(
            () => IndexedStack(
              index: controller.currentIndex.value,
              children: const [
                AnalyticsScreen(),
                HomeScreen(),
                BusinessProfileScreen(),
              ],
            ),
          ),
          if (homeController != null)
            Obx(
              () => homeController.showAccountModal.value
                  ? _buildAccountModal(context, homeController)
                  : const SizedBox.shrink(),
            ),
        ],
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
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
    );
  }

  Widget _buildAccountModal(BuildContext context, HomeController controller) {
    return GestureDetector(
      onTap: () {
        controller.closeAccountModal();
      },
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Align(
          alignment: .bottomCenter,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: .only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: .only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: .circular(2),
                    ),
                  ),
                  Padding(
                    padding: .all(16),
                    child: Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        const Text(
                          'Select Account',
                          style: TextStyle(fontSize: 18, fontWeight: .bold),
                        ),
                        IconButton(
                          onPressed: () {
                            controller.closeAccountModal();
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Obx(
                      () => ListView.builder(
                        shrinkWrap: true,
                        itemCount: controller.accountsList.length,
                        itemBuilder: (context, index) {
                          final account = controller.accountsList[index];
                          final name = account['name']?.toString() ?? '';
                          final customerCount =
                              account['customerCount'] as int? ?? 0;
                          final isSelected =
                              account['isSelected'] as bool? ?? false;

                          return InkWell(
                            onTap: () {
                              controller.selectAccount(index);
                            },
                            child: Container(
                              padding: .symmetric(horizontal: 16, vertical: 12),
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
                                                    (word) => word.isNotEmpty
                                                        ? word[0].toUpperCase()
                                                        : '',
                                                  )
                                                  .take(2)
                                                  .join()
                                            : '?',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: .bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: .start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: .w500,
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
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle,
                                      color: AppColors.primary,
                                      size: 24,
                                    )
                                  else
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.grey.shade400,
                                          width: 2,
                                        ),
                                      ),
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
                    margin: .all(16),
                    child: ElevatedButton(
                      onPressed: () {
                        controller.closeAccountModal();
                        Get.toNamed(Routes.createAccount);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: .symmetric(vertical: 16),
                      ),
                      child: Row(
                        mainAxisAlignment: .center,
                        children: const [
                          Icon(Icons.add, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'CREATE NEW ACCOUNT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: .bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReactiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ReactiveAppBar();

  @override
  Widget build(BuildContext context) {
    final homeController = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : null;

    return CommonAppBar(
      showBackButton: false,
      showDropdown: true,
      onTitleTap: homeController != null
          ? () => homeController.toggleAccountModal()
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

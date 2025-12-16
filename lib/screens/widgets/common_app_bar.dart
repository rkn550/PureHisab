import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/utils/app_colors.dart';
import '../../controllers/home_controller.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final VoidCallback? onTitleTap;
  final bool showDropdown;

  const CommonAppBar({
    super.key,
    this.showBackButton = false,
    this.onTitleTap,
    this.showDropdown = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryDark,
      elevation: 0,
      automaticallyImplyLeading: showBackButton,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            )
          : null,
      title: _buildTitle(),
    );
  }

  Widget _buildTitle() {
    // Try to get store name from HomeController
    String storeName = 'PureHisab';
    if (Get.isRegistered<HomeController>()) {
      try {
        final homeController = Get.find<HomeController>();
        return Obx(
          () => InkWell(
            onTap: onTitleTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/pure_hisab_logo.png',
                  color: Colors.white,
                  width: 60,
                  height: 60,
                ),
                const SizedBox(width: 8),
                Text(
                  homeController.storeName.value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (showDropdown)
                  const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white,
                    size: 20,
                  ),
              ],
            ),
          ),
        );
      } catch (e) {
        // HomeController not available
      }
    }

    // Fallback if HomeController not available
    return InkWell(
      onTap: onTitleTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/pure_hisab_logo.png',
            color: Colors.white,
            width: 60,
            height: 60,
          ),
          const SizedBox(width: 8),
          Text(
            storeName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (showDropdown)
            const Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

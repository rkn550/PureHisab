import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';
import '../app/utils/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SplashController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: controller.animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: controller.fadeAnimation,
                    child: ScaleTransition(
                      scale: controller.scaleAnimation,
                      child: _buildLogo(),
                    ),
                  );
                },
              ),
              FadeTransition(
                opacity: controller.fadeAnimation,
                child: const Text(
                  'PureHisab',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/pure_hisab_logo.png',
      width: 150,
      height: 150,
      fit: BoxFit.contain,
      color: AppColors.primaryDark,
    );
  }
}

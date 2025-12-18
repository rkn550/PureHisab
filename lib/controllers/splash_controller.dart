import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/routes/app_pages.dart';
import '../data/services/auth_service.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<double> scaleAnimation;
  final AuthService _authService = AuthService();

  @override
  void onInit() {
    super.onInit();
    _initAnimations();
    _startAnimation();
    _checkAuthAndNavigate();
  }

  void _initAnimations() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
  }

  void _startAnimation() {
    animationController.forward();
  }

  void _checkAuthAndNavigate() {
    Future.delayed(const Duration(seconds: 3), () {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        Get.offNamed(Routes.home, arguments: {'initialTab': 1});
      } else {
        Get.offNamed(Routes.login);
      }
    });
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}

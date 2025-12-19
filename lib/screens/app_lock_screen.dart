import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/utils/app_colors.dart';
import '../controllers/app_lock_controller.dart';

class AppLockScreen extends StatelessWidget {
  const AppLockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppLockController>();

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: .all(24),
            child: Column(
              mainAxisAlignment: .center,
              children: [
                const SizedBox(height: 60),
                Container(
                  padding: .all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'App Locked',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: .bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter PIN to unlock',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 48),
                Obx(() => _buildPinDots(controller)),
                Obx(
                  () => controller.errorMessage.value.isNotEmpty
                      ? Column(
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              controller.errorMessage.value,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 48),
                Obx(
                  () =>
                      controller.showBiometric.value &&
                          !controller.isAuthenticating.value
                      ? Column(
                          children: [
                            IconButton(
                              onPressed: controller.onBiometricTap,
                              icon: const Icon(
                                Icons.fingerprint_rounded,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Use biometric',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
                _buildKeypad(controller),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinDots(AppLockController controller) {
    return Row(
      mainAxisAlignment: .center,
      children: List.generate(4, (index) {
        final isFilled = index < controller.enteredPin.value.length;
        return Container(
          margin: .symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled
                ? Colors.white
                : Colors.white.withValues(alpha: 0.3),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildKeypad(AppLockController controller) {
    return Column(
      children: [
        _buildKeypadRow(controller, ['1', '2', '3']),
        const SizedBox(height: 16),
        _buildKeypadRow(controller, ['4', '5', '6']),
        const SizedBox(height: 16),
        _buildKeypadRow(controller, ['7', '8', '9']),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: .center,
          children: [
            const SizedBox(width: 80),
            _buildKeypadButton(
              controller,
              '0',
              onTap: () => controller.onPinDigitTap('0'),
            ),
            const SizedBox(width: 16),
            _buildBackspaceButton(controller),
          ],
        ),
      ],
    );
  }

  Widget _buildKeypadRow(AppLockController controller, List<String> digits) {
    return Row(
      mainAxisAlignment: .center,
      children: digits.map((digit) {
        return Padding(
          padding: .symmetric(horizontal: 8),
          child: _buildKeypadButton(
            controller,
            digit,
            onTap: () => controller.onPinDigitTap(digit),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKeypadButton(
    AppLockController controller,
    String digit, {
    required VoidCallback onTap,
  }) {
    return Obx(
      () => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: controller.isAuthenticating.value ? null : onTap,
          borderRadius: .circular(40),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.1),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                digit,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: .w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton(AppLockController controller) {
    return Obx(
      () => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: controller.isAuthenticating.value
              ? null
              : controller.onBackspace,
          borderRadius: .circular(40),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.1),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.backspace_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}

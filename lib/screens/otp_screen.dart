import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/otp_controller.dart';
import '../app/utils/app_colors.dart';
import 'widgets/widgets.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OtpController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: KeyboardDismisser(
          child: SingleChildScrollView(
            padding: .symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
                const SizedBox(height: 20),
                const AppLogo(),
                const SizedBox(height: 40),
                _buildHeader(controller),
                const SizedBox(height: 40),
                _buildOtpInputs(controller),
                const SizedBox(height: 30),
                _buildVerifyButton(controller),
                const SizedBox(height: 20),
                _buildResendOtp(controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(OtpController controller) {
    return Obx(
      () => SectionHeader(
        title: 'Enter Verification Code',
        subtitle:
            'We sent a 6-digit code to your mobile number ${controller.phoneNumber.value}',
      ),
    );
  }

  Widget _buildOtpInputs(OtpController controller) {
    return Obx(
      () => Row(
        mainAxisAlignment: .spaceEvenly,
        children: List.generate(
          6,
          (index) => OtpInputField(
            controller: controller.otpControllers[index],
            focusNode: controller.focusNodes[index],
            index: index,
            totalFields: 6,
            isFilled: controller.otp.value.length > index,
            onChanged: (value) => controller.updateOtp(value, index),
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyButton(OtpController controller) {
    return Obx(
      () => PrimaryButton(
        text: 'Verify OTP',
        onPressed:
            controller.isLoading.value || controller.otp.value.length != 6
            ? null
            : controller.verifyOtp,
        isLoading: controller.isLoading.value,
      ),
    );
  }

  Widget _buildResendOtp(OtpController controller) {
    return Obx(
      () => ResendTimer(
        canResend: controller.canResend.value,
        timer: controller.resendTimer.value,
        onResend: controller.resendOtp,
        prefixText: "Didn't receive the code? ",
      ),
    );
  }
}

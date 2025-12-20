import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/business_profile_controller.dart';
import '../app/utils/app_colors.dart';
import 'widgets/widgets.dart';

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BusinessProfileController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.resetFormForCreate();
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Create New Account',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: .w700,
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: .all(24.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
                const SizedBox(height: 40),
                CustomTextField(
                  controller: controller.nameController,
                  label: 'Business Name',
                  hintText: 'Enter business name',
                  validator: controller.validateName,
                  borderRadius: 8,
                  focusedBorderColor: AppColors.primary,
                  enabledBorderColor: AppColors.primary,
                ),
                const Spacer(),
                Obx(
                  () => PrimaryButton(
                    text: 'CREATE',
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.createAccount(),
                    isLoading: controller.isLoading.value,
                    height: 50,
                    fontSize: 16,
                    backgroundColor: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purehisab/controllers/create_business_controller.dart';
import '../app/utils/app_colors.dart';
import 'widgets/widgets.dart';

class CreateBusinessScreen extends StatelessWidget {
  const CreateBusinessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateBusinessController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Create New Business',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                CustomTextField(
                  controller: controller.businessNameController,
                  label: 'Business Name',
                  hintText: 'Enter business name',
                  validator: controller.validateBusinessName,
                  borderRadius: 8,
                  focusedBorderColor: AppColors.primary,
                  enabledBorderColor: AppColors.primary,
                ),
                const Spacer(),
                Obx(
                  () => PrimaryButton(
                    text: 'CREATE',
                    onPressed: controller.isLoading
                        ? null
                        : controller.createBusiness,
                    isLoading: controller.isLoading,
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/parties_profile_controller.dart';
import '../app/utils/app_colors.dart';
import 'widgets/widgets.dart';

class PartiesProfileScreen extends StatelessWidget {
  const PartiesProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PartiesProfileController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(controller),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileSection(controller),
              _buildDetailsSection(controller, context),
              _buildSettingsSection(controller, context),
              _buildDeleteButton(controller),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar(PartiesProfileController controller) {
    return AppBar(
      backgroundColor: AppColors.primaryDark,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      title: Obx(
        () => Text(
          controller.partyType == 'customer'
              ? 'Customer Profile'
              : 'Supplier Profile',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: .w500,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(PartiesProfileController controller) {
    return Container(
      padding: .all(24),
      child: Column(
        children: [
          Stack(
            children: [
              Obx(
                () => CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: controller.profileImageFile != null
                      ? FileImage(controller.profileImageFile!)
                      : null,
                  child: controller.profileImageFile == null
                      ? Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey.shade600,
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: controller.addPhoto,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (controller.profileImageFile == null)
            GestureDetector(
              onTap: controller.addPhoto,
              child: Text(
                'Add photo',
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 14,
                  fontWeight: .w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(
    PartiesProfileController controller,
    BuildContext context,
  ) {
    return Padding(
      padding: .symmetric(horizontal: 16),
      child: Column(
        children: [
          Obx(
            () => _buildDetailItem(
              icon: Icons.person_outline,
              label: 'Name',
              value: controller.partyName,
              onTap: () => _showEditDialog(
                context,
                'Edit Name',
                controller.partyName,
                (value) => controller.updateName(value),
              ),
            ),
          ),
          Obx(
            () => _buildDetailItem(
              icon: Icons.phone_outlined,
              label: 'Mobile Number',
              value: controller.partyPhoneNumber,
              onTap: () => _showEditDialog(
                context,
                'Edit Mobile Number',
                controller.partyPhoneNumber,
                (value) => controller.updatePhone(value),
              ),
            ),
          ),
          Obx(
            () => _buildDetailItem(
              icon: Icons.location_on_outlined,
              label: 'Address',
              value: controller.address.isEmpty ? null : controller.address,
              onTap: () => _showEditDialog(
                context,
                controller.address.isEmpty ? 'Add Address' : 'Edit Address',
                controller.address,
                (value) => controller.updateAddress(value),
                maxLines: 3,
              ),
            ),
          ),
          Obx(
            () => _buildDetailItem(
              icon: Icons.swap_horiz,
              label: controller.partyType == 'customer'
                  ? 'Change to Supplier'
                  : 'Change to Customer',
              value: null,
              onTap: controller.changeToCustomerOrSupplier,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    String? value,
    required VoidCallback onTap,
  }) {
    return ListItem(
      title: value ?? label,
      subtitle: value != null ? label : null,
      leadingIcon: icon,
      onTap: onTap,
    );
  }

  Widget _buildSettingsSection(
    PartiesProfileController controller,
    BuildContext context,
  ) {
    return Padding(
      padding: .symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          CustomDivider(color: Colors.grey.shade300, thickness: 1),
          const SizedBox(height: 8),
          Obx(
            () => Text(
              controller.partyType == 'customer'
                  ? 'Customer Settings'
                  : 'Supplier Settings',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontWeight: .w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildSmsSettingsItem(controller),
          _buildSmsLanguageItem(controller, context),
        ],
      ),
    );
  }

  Widget _buildSmsSettingsItem(PartiesProfileController controller) {
    return Container(
      padding: .symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.sms_outlined,
                      color: Colors.grey.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Obx(
                        () => Text(
                          controller.partyType == 'customer'
                              ? 'Customer SMS Settings'
                              : 'Supplier SMS Settings',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                            fontWeight: .w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'SMS will be sent on each entry',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Obx(
            () => CustomSwitch(
              value: controller.smsEnabled,
              onChanged: (_) => controller.toggleSmsEnabled(),
              activeColor: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmsLanguageItem(
    PartiesProfileController controller,
    BuildContext context,
  ) {
    return Container(
      padding: .symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Row(
                  children: [
                    Icon(Icons.language, color: Colors.grey.shade700, size: 24),
                    const SizedBox(width: 16),
                    const Text(
                      'SMS Language',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: .w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Obx(
                  () => Row(
                    children: [
                      CustomRadio<String>(
                        value: 'english',
                        groupValue: controller.smsLanguage,
                        onChanged: (value) {
                          if (value != null) {
                            controller.setSmsLanguage(value);
                          }
                        },
                        label: 'English',
                        activeColor: AppColors.primaryDark,
                      ),
                      const SizedBox(width: 24),
                      CustomRadio<String>(
                        value: 'hindi',
                        groupValue: controller.smsLanguage,
                        onChanged: (value) {
                          if (value != null) {
                            controller.setSmsLanguage(value);
                          }
                        },
                        label: 'Hindi',
                        activeColor: AppColors.primaryDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(PartiesProfileController controller) {
    return Padding(
      padding: .all(16),
      child: Container(
        width: double.infinity,
        padding: .symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red, width: 1.5),
          borderRadius: .circular(8),
        ),
        child: InkWell(
          onTap: controller.deleteCustomerOrSupplier,
          child: Row(
            mainAxisAlignment: .center,
            children: [
              Icon(Icons.delete_outline, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Obx(
                () => Text(
                  controller.partyType == 'customer'
                      ? 'DELETE CUSTOMER'
                      : 'DELETE SUPPLIER',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 15,
                    fontWeight: .w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    String title,
    String initialValue,
    Function(String) onSave, {
    int maxLines = 1,
  }) {
    final textController = TextEditingController(text: initialValue);
    final formKey = GlobalKey<FormState>();
    final isPhone =
        title.toLowerCase().contains('phone') ||
        title.toLowerCase().contains('mobile') ||
        title.toLowerCase().contains('number');

    Get.dialog(
      CustomDialog(
        title: title,
        confirmText: 'Save',
        cancelText: 'Cancel',
        onConfirm: () {
          if (formKey.currentState!.validate()) {
            onSave(textController.text.trim());
            Get.back();
          }
        },
        onCancel: () => Get.back(),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: textController,
            maxLines: maxLines,
            keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
            textInputAction: TextInputAction.done,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Enter ${title.toLowerCase()}',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.grey.shade50,
              prefixIcon: Icon(
                isPhone ? Icons.phone_rounded : Icons.edit_rounded,
                color: AppColors.primary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 1),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red.shade300, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red, width: 1),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            style: const TextStyle(fontSize: 16, color: Colors.black87),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter ${title.toLowerCase()}';
              }
              if (isPhone && value.length < 10) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }
}

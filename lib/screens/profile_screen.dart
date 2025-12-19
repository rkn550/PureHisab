import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../app/utils/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(controller),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileSection(controller),
            _buildDetailsSection(controller, context),
            _buildSettingsSection(controller, context),
            _buildDeleteButton(controller),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ProfileController controller) {
    return AppBar(
      backgroundColor: AppColors.primaryDark,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      title: Obx(
        () => Text(
          controller.isCustomer.value ? 'Customer Profile' : 'Supplier Profile',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: .w500,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(ProfileController controller) {
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
                  backgroundImage: controller.profileImageFile.value != null
                      ? FileImage(controller.profileImageFile.value!)
                      : null,
                  child: controller.profileImageFile.value == null
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
    ProfileController controller,
    BuildContext context,
  ) {
    return Padding(
      padding: .symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildDetailItem(
            icon: Icons.person_outline,
            label: 'Name',
            value: controller.customerName.value,
            onTap: () => _showEditDialog(
              context,
              'Edit Name',
              controller.customerName.value,
              (value) => controller.updateName(value),
            ),
          ),
          _buildDetailItem(
            icon: Icons.phone_outlined,
            label: 'Mobile Number',
            value: controller.customerPhone.value,
            onTap: () => _showEditDialog(
              context,
              'Edit Mobile Number',
              controller.customerPhone.value,
              (value) => controller.updatePhone(value),
            ),
          ),
          Obx(
            () => _buildDetailItem(
              icon: Icons.location_on_outlined,
              label: 'Address',
              value: controller.address.value.isEmpty
                  ? null
                  : controller.address.value,
              onTap: () => _showEditDialog(
                context,
                controller.address.value.isEmpty
                    ? 'Add Address'
                    : 'Edit Address',
                controller.address.value,
                (value) => controller.updateAddress(value),
                maxLines: 3,
              ),
            ),
          ),
          Obx(
            () => _buildDetailItem(
              icon: Icons.swap_horiz,
              label: controller.isCustomer.value
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
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: .symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade700, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  if (value != null)
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  if (value != null) const SizedBox(height: 4),
                  Text(
                    value ?? label,
                    style: TextStyle(
                      color: value != null ? Colors.black87 : Colors.black,
                      fontSize: value != null ? 16 : 15,
                      fontWeight: value != null ? .normal : .w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
    ProfileController controller,
    BuildContext context,
  ) {
    return Padding(
      padding: .symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Divider(color: Colors.grey.shade300, thickness: 1),
          const SizedBox(height: 8),
          Obx(
            () => Text(
              controller.isCustomer.value
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

  Widget _buildSmsSettingsItem(ProfileController controller) {
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
                          controller.isCustomer.value
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
            () => Tooltip(
              message: controller.smsEnabled.value
                  ? 'SMS is ON - SMS will be sent on each entry'
                  : 'SMS is OFF - SMS will not be sent',
              child: Switch(
                value: controller.smsEnabled.value,
                onChanged: (_) => controller.toggleSmsEnabled(),
                activeThumbColor: AppColors.success,
                activeTrackColor: AppColors.success.withOpacity(0.5),
                inactiveThumbColor: Colors.grey.shade400,
                inactiveTrackColor: Colors.grey.shade300,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmsLanguageItem(
    ProfileController controller,
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
                      Radio<String>(
                        value: 'English',
                        groupValue: controller.smsLanguage.value,
                        onChanged: (value) {
                          if (value != null) {
                            controller.setSmsLanguage(value);
                          }
                        },
                        activeColor: AppColors.primaryDark,
                      ),
                      const Text(
                        'English',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(width: 24),
                      Radio<String>(
                        value: 'Hindi',
                        groupValue: controller.smsLanguage.value,
                        onChanged: (value) {
                          if (value != null) {
                            controller.setSmsLanguage(value);
                          }
                        },
                        activeColor: AppColors.primaryDark,
                      ),
                      const Text(
                        'Hindi',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
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

  Widget _buildDeleteButton(ProfileController controller) {
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
                  controller.isCustomer.value
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
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: .circular(24)),
        elevation: 8,
        child: Container(
          padding: .all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            borderRadius: .circular(24),
            color: Colors.white,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: .start,
              spacing: 20,
              children: [
                Row(
                  mainAxisAlignment: .center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: .w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),

                TextFormField(
                  controller: textController,
                  maxLines: maxLines,
                  keyboardType: isPhone
                      ? TextInputType.phone
                      : TextInputType.text,
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
                      borderRadius: .circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: .circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: .circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 1,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: .circular(12),
                      borderSide: BorderSide(
                        color: Colors.red.shade300,
                        width: 1,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: .circular(12),
                      borderSide: BorderSide(color: Colors.red, width: 1),
                    ),
                    contentPadding: .symmetric(horizontal: 12, vertical: 12),
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

                Row(
                  mainAxisAlignment: .end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: .symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: .circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          fontWeight: .w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          onSave(textController.text.trim());
                          Get.back();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: .symmetric(horizontal: 24, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: .circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(fontSize: 14, fontWeight: .w500),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

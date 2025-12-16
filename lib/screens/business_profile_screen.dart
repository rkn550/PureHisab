import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../controllers/business_profile_controller.dart';
import '../app/utils/app_colors.dart';

class BusinessProfileScreen extends StatelessWidget {
  const BusinessProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller if not already registered
    if (!Get.isRegistered<BusinessProfileController>()) {
      Get.put(BusinessProfileController());
    }
    final controller = Get.find<BusinessProfileController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileSection(controller),
            _buildDetailsSection(controller, context),
            _buildSettingsSection(controller),
            _buildHelpSupportSection(controller),
            _buildAboutSection(controller),
            _buildVersionAndShareSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BusinessProfileController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
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
                          Icons.business,
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
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(
    BusinessProfileController controller,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildDetailItem(
            icon: Icons.person_outlined,
            label: 'Owner Name',
            value: controller.businessName.value,
            onTap: () => _showEditDialog(
              context,
              'Edit Owner Name',
              controller.businessName.value,
              (value) => controller.updateBusinessName(value),
            ),
          ),
          _buildDetailItem(
            icon: Icons.phone_outlined,
            label: 'Mobile Number',
            value: controller.businessPhone.value,
            onTap: () => _showEditDialog(
              context,
              'Edit Mobile Number',
              controller.businessPhone.value,
              (value) => controller.updateBusinessPhone(value),
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
        padding: const EdgeInsets.symmetric(vertical: 16),
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      fontWeight: value != null
                          ? FontWeight.normal
                          : FontWeight.w500,
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

  Widget _buildHelpSupportSection(BusinessProfileController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Divider(color: Colors.grey.shade300, thickness: 1),

          Obx(
            () => ExpansionTile(
              initiallyExpanded: controller.helpSupportExpanded.value,
              onExpansionChanged: (expanded) {
                controller.helpSupportExpanded.value = expanded;
              },
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 0,
                vertical: 0,
              ),
              childrenPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.help_outline,
                color: controller.helpSupportExpanded.value
                    ? AppColors.primaryDark
                    : Colors.grey.shade700,
                size: 24,
              ),
              title: Text(
                'Help & Support',
                style: TextStyle(
                  color: controller.helpSupportExpanded.value
                      ? AppColors.primaryDark
                      : Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              children: [
                // Help on WhatsApp
                _buildSettingsItem(
                  icon: Icons.chat_outlined,
                  title: 'Help on WhatsApp',
                  onTap: () {
                    // TODO: Open WhatsApp with help number
                    Get.snackbar(
                      'Help on WhatsApp',
                      'Coming soon',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
                // Call Us
                _buildSettingsItem(
                  icon: Icons.phone_outlined,
                  title: 'Call Us',
                  onTap: () {
                    // TODO: Open phone dialer with support number
                    Get.snackbar(
                      'Call Us',
                      'Coming soon',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BusinessProfileController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Divider(color: Colors.grey.shade300, thickness: 1),

          Obx(
            () => ExpansionTile(
              initiallyExpanded: controller.aboutExpanded.value,
              onExpansionChanged: (expanded) {
                controller.aboutExpanded.value = expanded;
              },
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 0,
                vertical: 0,
              ),
              childrenPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.info_outline,
                color: controller.aboutExpanded.value
                    ? AppColors.primaryDark
                    : Colors.grey.shade700,
                size: 24,
              ),
              title: Text(
                'About Us',
                style: TextStyle(
                  color: controller.aboutExpanded.value
                      ? AppColors.primaryDark
                      : Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              children: [
                // About PureHisab
                _buildSettingsItem(
                  icon: Icons.business_outlined,
                  title: 'About PureHisab',
                  onTap: () {
                    Get.snackbar(
                      'About PureHisab',
                      'Coming soon',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
                // Privacy Policy
                _buildSettingsItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () {
                    Get.snackbar(
                      'Privacy Policy',
                      'Coming soon',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
                // Terms & Conditions
                _buildSettingsItem(
                  icon: Icons.description_outlined,
                  title: 'Terms & Conditions',
                  onTap: () {
                    Get.snackbar(
                      'Terms & Conditions',
                      'Coming soon',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BusinessProfileController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Divider(color: Colors.grey.shade300, thickness: 1),

          Obx(
            () => ExpansionTile(
              initiallyExpanded: controller.settingsExpanded.value,
              onExpansionChanged: (expanded) {
                controller.settingsExpanded.value = expanded;
              },
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 0,
                vertical: 0,
              ),
              childrenPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.settings,
                color: controller.settingsExpanded.value
                    ? AppColors.primaryDark
                    : Colors.grey.shade700,
                size: 24,
              ),
              title: Text(
                'Settings',
                style: TextStyle(
                  color: controller.settingsExpanded.value
                      ? AppColors.primaryDark
                      : Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              children: [
                // App Lock
                _buildAppLockItem(controller),
                // Manage App Lock (shown when App Lock is enabled)
                Obx(
                  () => controller.appLockEnabled.value
                      ? _buildSettingsItem(
                          icon: Icons.lock_outline,
                          title: 'Manage App Lock',
                          titleColor: AppColors.primaryDark,
                          onTap: () {
                            Get.snackbar(
                              'Manage App Lock',
                              'Coming soon',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        )
                      : const SizedBox.shrink(),
                ),
                // Backup Information
                _buildSettingsItem(
                  icon: Icons.backup_outlined,
                  title: 'Backup Information',
                  onTap: () {
                    Get.snackbar(
                      'Backup Information',
                      'Coming soon',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
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
              child: Text(
                title,
                style: TextStyle(
                  color: titleColor ?? Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildAppLockItem(BusinessProfileController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline, color: Colors.grey.shade700, size: 24),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'App Lock',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Obx(
            () => Switch(
              value: controller.appLockEnabled.value,
              onChanged: (value) => controller.toggleAppLock(),
              activeThumbColor: AppColors.success,
              activeTrackColor: AppColors.success.withValues(alpha: 0.5),
              inactiveThumbColor: Colors.grey.shade400,
              inactiveTrackColor: Colors.grey.shade300,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionAndShareSection() {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.hasData ? snapshot.data!.version : '1.0.0';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              // Share App
              _buildSettingsItem(
                icon: Icons.share_outlined,
                title: 'Share App',
                onTap: () {
                  _shareApp(context);
                },
              ),
              const SizedBox(height: 24),
              // App Version
              Center(
                child: Text(
                  'V $version',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ),
              const SizedBox(height: 8),
              // App Logo/Name
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/pure_hisab_logo.png',
                    width: 50,
                    height: 50,
                    fit: BoxFit.contain,
                    color: AppColors.primaryDark,
                  ),

                  Text(
                    'PureHisab',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Future<void> _shareApp(BuildContext context) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final appName = packageInfo.appName;
      final version = packageInfo.version;

      final shareText =
          'Check out $appName - Version $version\n\n'
          'Download now and manage your business accounts easily!';

      // Use Share.share with proper context
      final box = context.findRenderObject() as RenderBox?;
      await Share.share(
        shareText,
        subject: 'Share $appName',
        sharePositionOrigin: box != null
            ? box.localToGlobal(Offset.zero) & box.size
            : null,
      );
    } catch (e) {
      // Show detailed error message for debugging
      Get.snackbar(
        'Error',
        'Failed to share app. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 3),
      );
      // Print error for debugging
      // Error logged silently
    }
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                // Text Field
                TextFormField(
                  controller: textController,
                  maxLines: maxLines,
                  keyboardType: isPhone
                      ? TextInputType.phone
                      : TextInputType.text,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: 'Enter ${title.toLowerCase()}',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: Colors.grey.shade50,
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
                      borderSide: BorderSide(
                        color: AppColors.primaryDark,
                        width: 2,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: maxLines > 1 ? 16 : 16,
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
                const SizedBox(height: 32),
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
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
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
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

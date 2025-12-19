import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../controllers/business_profile_controller.dart';
import '../app/utils/app_colors.dart';
import 'widgets/widgets.dart';

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
            _buildVersionAndShareSection(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BusinessProfileController controller) {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      padding: .all(24),
      child: Column(
        children: [
          Stack(
            children: [
              Obx(
                () => AvatarWidget(
                  imagePath: controller.profileImageFile.value?.path,
                  name: controller.businessName.value,
                  size: 100,
                  backgroundColor: Colors.grey.shade300,
                  fallbackIcon: Icons.business,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: controller.addPhoto,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: AppColors.primary,
                      size: 20,
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
          const SizedBox(height: 12),
          Obx(
            () => Text(
              controller.businessName.value,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 24,
                fontWeight: .w500,
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
      padding: .fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          _buildDetailItem(
            icon: Icons.person_outlined,
            label: 'Owner Name',
            value: controller.ownerName.value.isEmpty
                ? 'Not set'
                : controller.ownerName.value,
            onTap: () => _showEditDialog(
              context,
              'Edit Owner Name',
              controller.ownerName.value,
              (value) async {
                controller.updateOwnerName(value);
                if (controller.businessId.value.isNotEmpty) {
                  await controller.updateBusinessProfile();
                }
              },
            ),
          ),
          const SizedBox(height: 8),
          _buildDetailItem(
            icon: Icons.phone_outlined,
            label: 'Mobile Number',
            value: controller.businessPhone.value.isEmpty
                ? 'Not set'
                : controller.businessPhone.value,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    String? value,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: .symmetric(horizontal: 4, vertical: 3),
          padding: .all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: .circular(12),
            border: Border.all(color: Colors.grey.shade200, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: .all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: .circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                        fontWeight: .w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      value ?? 'Not set',
                      style: TextStyle(
                        color: value != null
                            ? Colors.black87
                            : Colors.grey.shade400,
                        fontSize: 16,
                        fontWeight: value != null ? .w600 : .normal,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpSupportSection(BusinessProfileController controller) {
    return Padding(
      padding: .symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Obx(
            () => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: .circular(16),
                border: Border.all(
                  color: controller.helpSupportExpanded.value
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : Colors.grey.shade200,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ExpansionTile(
                initiallyExpanded: controller.helpSupportExpanded.value,
                onExpansionChanged: (expanded) {
                  controller.helpSupportExpanded.value = expanded;
                },
                tilePadding: .symmetric(horizontal: 16, vertical: 8),
                childrenPadding: .zero,
                leading: Container(
                  padding: .all(8),
                  decoration: BoxDecoration(
                    color: controller.helpSupportExpanded.value
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : Colors.grey.shade100,
                    borderRadius: .circular(10),
                  ),
                  child: Icon(
                    Icons.help_outline_rounded,
                    color: controller.helpSupportExpanded.value
                        ? AppColors.primary
                        : Colors.grey.shade700,
                    size: 22,
                  ),
                ),
                title: Text(
                  'Help & Support',
                  style: TextStyle(
                    color: controller.helpSupportExpanded.value
                        ? AppColors.primary
                        : Colors.black87,
                    fontSize: 16,
                    fontWeight: .w600,
                  ),
                ),
                children: [
                  Padding(
                    padding: .symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _buildSettingsItem(
                          icon: Icons.wechat_sharp,
                          title: 'Help on WhatsApp',
                          onTap: () {
                            controller.openWhatsApp();
                          },
                        ),
                        _buildSettingsItem(
                          icon: Icons.email_outlined,
                          title: 'Email Us',
                          onTap: () {
                            controller.sendEmail();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BusinessProfileController controller) {
    return Padding(
      padding: .symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Obx(
            () => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: .circular(16),
                border: Border.all(
                  color: controller.aboutExpanded.value
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : Colors.grey.shade200,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ExpansionTile(
                initiallyExpanded: controller.aboutExpanded.value,
                onExpansionChanged: (expanded) {
                  controller.aboutExpanded.value = expanded;
                },
                tilePadding: .symmetric(horizontal: 16, vertical: 8),
                childrenPadding: .zero,
                leading: Container(
                  padding: .all(8),
                  decoration: BoxDecoration(
                    color: controller.aboutExpanded.value
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : Colors.grey.shade100,
                    borderRadius: .circular(10),
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: controller.aboutExpanded.value
                        ? AppColors.primary
                        : Colors.grey.shade700,
                    size: 22,
                  ),
                ),
                title: Text(
                  'About Us',
                  style: TextStyle(
                    color: controller.aboutExpanded.value
                        ? AppColors.primary
                        : Colors.black87,
                    fontSize: 16,
                    fontWeight: .w600,
                  ),
                ),
                children: [
                  Padding(
                    padding: .symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _buildSettingsItem(
                          icon: Icons.business_rounded,
                          title: 'About PureHisab',
                          onTap: () {
                            Get.snackbar(
                              'About PureHisab',
                              'Coming soon',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        ),
                        _buildSettingsItem(
                          icon: Icons.privacy_tip_rounded,
                          title: 'Privacy Policy',
                          onTap: () {
                            Get.snackbar(
                              'Privacy Policy',
                              'Coming soon',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        ),
                        _buildSettingsItem(
                          icon: Icons.description_rounded,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BusinessProfileController controller) {
    return Padding(
      padding: .symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Obx(
            () => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: .circular(16),
                border: Border.all(
                  color: controller.settingsExpanded.value
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : Colors.grey.shade200,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ExpansionTile(
                initiallyExpanded: controller.settingsExpanded.value,
                onExpansionChanged: (expanded) {
                  controller.settingsExpanded.value = expanded;
                },
                tilePadding: .symmetric(horizontal: 16, vertical: 8),
                childrenPadding: .zero,
                leading: Container(
                  padding: .all(8),
                  decoration: BoxDecoration(
                    color: controller.settingsExpanded.value
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : Colors.grey.shade100,
                    borderRadius: .circular(10),
                  ),
                  child: Icon(
                    Icons.settings_rounded,
                    color: controller.settingsExpanded.value
                        ? AppColors.primary
                        : Colors.grey.shade700,
                    size: 22,
                  ),
                ),
                title: Text(
                  'Settings',
                  style: TextStyle(
                    color: controller.settingsExpanded.value
                        ? AppColors.primary
                        : Colors.black87,
                    fontSize: 16,
                    fontWeight: .w600,
                  ),
                ),
                children: [
                  Padding(
                    padding: .symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _buildAppLockItem(controller),
                        Obx(
                          () => controller.appLockEnabled.value
                              ? _buildSettingsItem(
                                  icon: Icons.lock_clock_outlined,
                                  title: 'Manage App Lock',
                                  titleColor: AppColors.primary,
                                  onTap: () {
                                    controller.manageAppLock();
                                  },
                                )
                              : const SizedBox.shrink(),
                        ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: .circular(10),
        child: Container(
          padding: .symmetric(vertical: 14, horizontal: 4),
          margin: .only(bottom: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: .circular(10),
          ),
          child: Row(
            children: [
              Container(
                padding: .all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: .circular(8),
                ),
                child: Icon(
                  icon,
                  color: titleColor ?? AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: titleColor ?? Colors.black87,
                    fontSize: 15,
                    fontWeight: .w500,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade400,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppLockItem(BusinessProfileController controller) {
    return Obx(
      () => Container(
        padding: .symmetric(vertical: 14, horizontal: 4),
        margin: .only(bottom: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: .circular(10),
        ),
        child: Row(
          children: [
            Container(
              padding: .all(8),
              decoration: BoxDecoration(
                color: controller.appLockEnabled.value
                    ? AppColors.success.withValues(alpha: 0.15)
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: .circular(8),
              ),
              child: Icon(
                controller.appLockEnabled.value
                    ? Icons.lock_rounded
                    : Icons.lock_open_rounded,
                color: controller.appLockEnabled.value
                    ? AppColors.success
                    : AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'App Lock',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: .w500,
                ),
              ),
            ),
            Obx(
              () => CustomSwitch(
                value: controller.appLockEnabled.value,
                onChanged: (value) => controller.toggleAppLock(),
                activeColor: AppColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionAndShareSection(BusinessProfileController controller) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.hasData ? snapshot.data!.version : '1.0.0';

        return Padding(
          padding: .fromLTRB(16, 8, 16, 24),
          child: Column(
            children: [
              Container(
                padding: .all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: .circular(16),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSettingsItem(
                      icon: Icons.share_rounded,
                      title: 'Share App',
                      onTap: () {
                        _shareApp(context);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisSize: .min,
                children: [
                  // Container(
                  //   decoration: BoxDecoration(
                  //     color: AppColors.primary.withValues(alpha: 0.1),
                  //     shape: BoxShape.circle,
                  //   ),
                  //   child:
                  Image.asset(
                    'assets/images/pure_hisab_logo.png',
                    color: AppColors.primary,
                    height: 70,
                    width: 70,
                    // ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    spacing: 3,
                    children: [
                      Text(
                        'PureHisab',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: .bold,
                          letterSpacing: 0.5,
                        ),
                      ),

                      Text(
                        'Version $version',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: .w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 25),
            ],
          ),
        );
      },
    );
  }

  Future<void> _shareApp(BuildContext context) async {
    try {
      final box = context.findRenderObject() as RenderBox?;
      final sharePositionOrigin = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : null;

      final packageInfo = await PackageInfo.fromPlatform();
      final appName = packageInfo.appName;
      final version = packageInfo.version;

      final shareText =
          'Check out $appName - Version $version\n\n'
          'Download now and manage your business accounts easily!';

      await SharePlus.instance.share(
        ShareParams(
          text: shareText,
          subject: 'Share $appName',
          sharePositionOrigin: sharePositionOrigin,
        ),
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

                CustomTextField(
                  controller: textController,
                  hintText: 'Enter ${title.toLowerCase()}',
                  keyboardType: isPhone
                      ? TextInputType.phone
                      : TextInputType.text,
                  maxLines: maxLines,
                  prefixIcon: Icon(
                    isPhone ? Icons.phone_rounded : Icons.edit_rounded,
                    color: AppColors.primary,
                  ),
                  borderRadius: 12,
                  focusedBorderColor: AppColors.primary,
                  enabledBorderColor: Colors.grey.shade300,
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
                    CustomTextButton(
                      text: 'Cancel',
                      onPressed: () => Get.back(),
                      textColor: Colors.grey.shade700,
                    ),
                    const SizedBox(width: 12),
                    PrimaryButton(
                      text: 'Save',
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          onSave(textController.text.trim());
                          Get.back();
                        }
                      },
                      height: 40,
                      fontSize: 14,
                      backgroundColor: AppColors.primary,
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

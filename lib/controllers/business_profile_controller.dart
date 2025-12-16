import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../app/utils/app_colors.dart';

class BusinessProfileController extends GetxController {
  // Business information
  final RxString businessName = ''.obs; // Owner Name
  final RxString businessPhone = ''.obs;
  final Rx<File?> profileImageFile = Rx<File?>(null);

  // Settings section expanded state
  final RxBool settingsExpanded = true.obs;

  // App Lock state
  final RxBool appLockEnabled = false.obs;

  // About section expanded state
  final RxBool aboutExpanded = false.obs;

  // Help & Support section expanded state
  final RxBool helpSupportExpanded = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadBusinessData();
  }

  void _loadBusinessData() {
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      businessName.value = args['name']?.toString() ?? 'Unknown';
      businessPhone.value = args['phone']?.toString() ?? '';
    }
  }

  void updateBusinessName(String name) {
    businessName.value = name;
    // TODO: Save to backend/mock data
  }

  void updateBusinessPhone(String phone) {
    businessPhone.value = phone;
    // TODO: Save to backend/mock data
  }

  void toggleSettingsExpanded() {
    settingsExpanded.value = !settingsExpanded.value;
  }

  void toggleAppLock() {
    appLockEnabled.value = !appLockEnabled.value;
    // TODO: Implement app lock functionality
  }

  void toggleAboutExpanded() {
    aboutExpanded.value = !aboutExpanded.value;
  }

  void toggleHelpSupportExpanded() {
    helpSupportExpanded.value = !helpSupportExpanded.value;
  }

  Future<void> addPhoto() async {
    final ImagePicker picker = ImagePicker();

    // Show bottom sheet with options
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text(
                  'Select Photo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Camera option
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppColors.primaryDark),
                title: const Text('Take Photo'),
                onTap: () async {
                  Get.back(); // Close bottom sheet
                  await _pickImageFromCamera(picker);
                },
              ),
              // Gallery option
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: AppColors.primaryDark,
                ),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Get.back(); // Close bottom sheet
                  await _pickImageFromGallery(picker);
                },
              ),
              // Remove photo option (if photo exists)
              Obx(
                () => profileImageFile.value != null
                    ? ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: const Text('Remove Photo'),
                        onTap: () {
                          Get.back(); // Close bottom sheet
                          profileImageFile.value = null;
                          Get.snackbar(
                            'Success',
                            'Photo removed',
                            snackPosition: SnackPosition.BOTTOM,
                            duration: const Duration(seconds: 2),
                          );
                        },
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
    );
  }

  Future<void> _pickImageFromCamera(ImagePicker picker) async {
    try {
      // Check camera permission
      final cameraStatus = await Permission.camera.status;
      if (!cameraStatus.isGranted) {
        final result = await Permission.camera.request();
        if (!result.isGranted) {
          Get.snackbar(
            'Permission Denied',
            'Camera permission is required to take photos',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange.shade50,
            colorText: Colors.orange.shade900,
            duration: const Duration(seconds: 3),
          );
          return;
        }
      }

      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (image != null) {
        profileImageFile.value = File(image.path);
        Get.snackbar(
          'Success',
          'Photo added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green.shade900,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to take photo. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> _pickImageFromGallery(ImagePicker picker) async {
    try {
      // Note: image_picker handles permissions automatically on most platforms
      // But we can still check and request if needed
      PermissionStatus? photoStatus;

      if (Platform.isAndroid) {
        // Try photos permission first (Android 13+)
        try {
          photoStatus = await Permission.photos.status;
          if (!photoStatus.isGranted) {
            photoStatus = await Permission.photos.request();
          }
        } catch (e) {
          // Fallback to storage permission for older Android
          photoStatus = await Permission.storage.status;
          if (!photoStatus.isGranted) {
            photoStatus = await Permission.storage.request();
          }
        }
      } else if (Platform.isIOS) {
        // For iOS
        photoStatus = await Permission.photos.status;
        if (!photoStatus.isGranted) {
          photoStatus = await Permission.photos.request();
        }
      }

      // If permission is denied, show message but still try (image_picker may handle it)
      if (photoStatus != null &&
          !photoStatus.isGranted &&
          photoStatus.isPermanentlyDenied) {
        Get.snackbar(
          'Permission Denied',
          'Please enable photo library permission in settings',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade50,
          colorText: Colors.orange.shade900,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (image != null) {
        profileImageFile.value = File(image.path);
        Get.snackbar(
          'Success',
          'Photo added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green.shade900,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick photo. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 3),
      );
    }
  }
}

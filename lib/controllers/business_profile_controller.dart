import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:purehisab/data/services/business_repo.dart';
import '../app/utils/app_colors.dart';
import 'home_controller.dart';

class BusinessProfileController extends GetxController {
  final BusinessRepository _businessRepository = BusinessRepository();
  // Mode: 'create' for creating new business, 'edit' for editing existing
  final RxString mode = 'edit'.obs; // 'create' or 'edit'

  // Form controllers for create account screen
  final nameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final RxBool isLoading = false.obs;

  // Business information
  final RxString businessId = ''.obs; // Business ID from database
  final RxString businessName = ''.obs; // Business Name
  final RxString ownerName = ''.obs; // Owner Name (editable)
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

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  void _loadBusinessData() async {
    final args = Get.arguments;

    if (args != null && args is Map<String, dynamic>) {
      if (args['mode'] == 'create') {
        mode.value = 'create';
        _resetFormForCreate();
        return;
      }
    }

    mode.value = 'edit';

    String? businessIdToLoad;

    if (args != null && args is Map<String, dynamic>) {
      businessIdToLoad = args['businessId']?.toString();
    }

    if (businessIdToLoad == null || businessIdToLoad.isEmpty) {
      if (Get.isRegistered<HomeController>()) {
        try {
          final homeController = Get.find<HomeController>();
          businessIdToLoad = homeController.selectedBusinessId.value;
        } catch (e) {
          print('Error getting business ID from HomeController: $e');
        }
      }
    }

    if (businessIdToLoad != null && businessIdToLoad.isNotEmpty) {
      await _loadBusinessFromDatabase(businessIdToLoad);
    } else {
      _resetFormForCreate();
    }
  }

  /// Reset form fields when entering create mode
  void resetFormForCreate() {
    nameController.clear();
    businessName.value = '';
    ownerName.value = '';
    businessPhone.value = '';
    businessId.value = '';
    profileImageFile.value = null;
    // Reset form validation state
    formKey.currentState?.reset();
  }

  /// Reset form fields when entering create mode (private alias)
  void _resetFormForCreate() {
    resetFormForCreate();
  }

  /// Load business data from database (public method for external calls)
  Future<void> loadBusinessById(String id) async {
    if (id.isEmpty) return;
    await _loadBusinessFromDatabase(id);
  }

  /// Load business data from database
  Future<void> _loadBusinessFromDatabase(String id) async {
    try {
      isLoading.value = true;
      final business = await _businessRepository.getBusinessById(id);
      if (business != null) {
        businessId.value = business.id;
        businessName.value = business.businessName;
        ownerName.value = business.ownerName ?? '';
        businessPhone.value = business.phoneNumber ?? '';
        print('Loaded business phone number: ${business.phoneNumber}');
        print('Set businessPhone.value to: ${businessPhone.value}');
      } else {
        // Business not found
        Get.snackbar(
          'Error',
          'Business not found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load business data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void updateBusinessName(String name) {
    businessName.value = name;
  }

  void updateOwnerName(String name) {
    ownerName.value = name;
  }

  // void updateBusinessPhone(String phone) {
  //   businessPhone.value = phone;
  // }

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

  // ==================== CREATE ACCOUNT FUNCTIONALITY ====================

  /// Create a new business account
  Future<void> createAccount() async {
    if (formKey.currentState?.validate() ?? false) {
      final name = nameController.text.trim();
      if (name.isEmpty) {
        Get.snackbar(
          'Error',
          'Please enter a name',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
        return;
      }

      isLoading.value = true;

      try {
        // Create business in database using BusinessRepository
        // Only business name is provided, phone number auto-filled from repo
        final business = await _businessRepository.createBusiness(
          businessName: name,
          ownerName: null, // Owner name will be added later when editing
          photoUrl: null, // TODO: Upload photo and get URL
        );

        // Verify business was created
        if (business.id.isEmpty) {
          throw Exception('Business creation failed: Invalid business ID');
        }

        // Reset form after successful creation
        resetFormForCreate();

        // Navigate back first to avoid widget rebuild conflicts
        Get.back();

        // Wait for navigation to complete, then update state
        await Future.delayed(const Duration(milliseconds: 100));

        // Get HomeController and add new account
        if (Get.isRegistered<HomeController>()) {
          final homeController = Get.find<HomeController>();
          homeController.addNewAccountFromBusiness(business);
        }

        // Show success message after state update
        Future.delayed(const Duration(milliseconds: 200), () {
          if (Get.isSnackbarOpen == false) {
            Get.snackbar(
              'Success',
              'Business account created successfully',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green.shade100,
              colorText: Colors.green.shade900,
              duration: const Duration(seconds: 2),
            );
          }
        });
      } catch (e) {
        // Log the full error for debugging
        print('Error creating business: $e');
        print('Error stack trace: ${StackTrace.current}');

        final errorMessage = e.toString().replaceAll('Exception: ', '');
        Get.snackbar(
          'Error',
          errorMessage.isNotEmpty
              ? errorMessage
              : 'Failed to create account. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          duration: const Duration(seconds: 4),
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  /// Update business profile
  Future<void> updateBusinessProfile() async {
    if (businessId.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Business ID not found',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    isLoading.value = true;

    try {
      // Get current business from database
      final business = await _businessRepository.getBusinessById(
        businessId.value,
      );
      if (business == null) {
        throw Exception('Business not found');
      }

      print(
        'Updating owner name from: ${business.ownerName} to: ${ownerName.value}',
      );

      final updatedBusiness = business.copyWith(
        ownerName: ownerName.value.isNotEmpty ? ownerName.value : null,
      );

      print('Updated business data: ${updatedBusiness.toMap()}');
      await _businessRepository.updateBusiness(updatedBusiness);
      print('Business updated in database');

      // Reload business data from database to ensure UI is in sync
      await _loadBusinessFromDatabase(businessId.value);

      // Refresh HomeController accounts list
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        await homeController.refreshBusinesses();
      }

      Get.snackbar(
        'Success',
        'Business profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        errorMessage.isNotEmpty
            ? errorMessage
            : 'Failed to update business profile. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Validate business name
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
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

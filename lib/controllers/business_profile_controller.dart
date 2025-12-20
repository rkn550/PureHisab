import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:purehisab/data/services/business_repo.dart';
import 'package:purehisab/data/services/app_lock_service.dart';
import '../app/utils/app_colors.dart';
import 'home_controller.dart';

class BusinessProfileController extends GetxController {
  BusinessRepository get _businessRepository => Get.find<BusinessRepository>();
  AppLockService get _appLockService => Get.find<AppLockService>();
  final RxString mode = 'edit'.obs;

  final nameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final RxBool isLoading = false.obs;

  final RxString businessId = ''.obs;
  final RxString businessName = ''.obs;
  final RxString ownerName = ''.obs;
  final RxString businessPhone = ''.obs;
  final Rx<File?> profileImageFile = Rx<File?>(null);

  final RxBool settingsExpanded = false.obs;
  final RxBool appLockEnabled = false.obs;
  final RxBool aboutExpanded = false.obs;
  final RxBool helpSupportExpanded = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadBusinessData();
    _loadAppLockState();
    _setupHomeControllerListener();
  }

  void _setupHomeControllerListener() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (Get.isRegistered<HomeController>()) {
        try {
          final homeController = Get.find<HomeController>();
          // Listen to selectedBusinessId changes and reload business data
          ever(homeController.selectedBusinessId, (String newBusinessId) {
            if (newBusinessId.isNotEmpty &&
                newBusinessId != businessId.value &&
                mode.value == 'edit') {
              loadBusinessById(newBusinessId);
            }
          });

          // Also check if there's already a selected business
          if (homeController.selectedBusinessId.value.isNotEmpty &&
              businessId.value.isEmpty &&
              mode.value == 'edit') {
            loadBusinessById(homeController.selectedBusinessId.value);
          }
        } catch (e) {
          // HomeController might not be ready yet, ignore
        }
      }
    });
  }

  Future<void> _loadAppLockState() async {
    appLockEnabled.value = await _appLockService.isLockEnabled();
  }

  @override
  void onClose() {
    try {
      nameController.dispose();
    } catch (e) {
      // Controller might already be disposed, ignore
    }
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

          // If businessId is still empty, wait a bit for HomeController to finish loading
          if (businessIdToLoad.isEmpty) {
            // Wait for HomeController to finish loading businesses
            for (int i = 0; i < 10; i++) {
              await Future.delayed(const Duration(milliseconds: 100));
              businessIdToLoad = homeController.selectedBusinessId.value;
              if (businessIdToLoad.isNotEmpty) {
                break;
              }
            }
          }
        } catch (e) {
          throw Exception('Error loading business data: $e');
        }
      }
    }

    if (businessIdToLoad != null && businessIdToLoad.isNotEmpty) {
      await _loadBusinessFromDatabase(businessIdToLoad);
    } else {
      // Don't reset form if we're in edit mode - wait for HomeController notification
      // Only reset if we're sure there's no business to load
      if (mode.value == 'create') {
        _resetFormForCreate();
      }
    }
  }

  void resetFormForCreate() {
    nameController.clear();
    businessName.value = '';
    ownerName.value = '';
    businessPhone.value = '';
    businessId.value = '';
    profileImageFile.value = null;
    formKey.currentState?.reset();
  }

  void _resetFormForCreate() {
    resetFormForCreate();
  }

  Future<void> loadBusinessById(String id) async {
    if (id.isEmpty) return;
    await _loadBusinessFromDatabase(id);
  }

  Future<void> _loadBusinessFromDatabase(String id) async {
    try {
      isLoading.value = true;
      final business = await _businessRepository.getBusinessById(id);
      if (business != null) {
        businessId.value = business.id;
        businessName.value = business.businessName;
        ownerName.value = business.ownerName ?? '';
        businessPhone.value = business.phoneNumber ?? '';
      } else {
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

  void toggleSettingsExpanded() {
    settingsExpanded.value = !settingsExpanded.value;
  }

  Future<void> toggleAppLock() async {
    if (appLockEnabled.value) {
      await _disableAppLock();
    } else {
      await _enableAppLock();
    }
  }

  Future<void> _enableAppLock() async {
    final hasPin = await _appLockService.hasPin();
    if (!hasPin) {
      final pin = await _showPinSetupDialog('Set PIN');
      if (pin == null || pin.length != 4) {
        Get.snackbar(
          'Error',
          'PIN is required to enable app lock',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade50,
          colorText: Colors.red.shade900,
        );
        return;
      }
      await _appLockService.setPin(pin);
    }

    await _appLockService.setLockEnabled(true);
    appLockEnabled.value = true;
    Get.snackbar(
      'Success',
      'App lock enabled',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade50,
      colorText: Colors.green.shade900,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> _disableAppLock() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Disable App Lock'),
        content: const Text('Are you sure you want to disable app lock?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Disable'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _appLockService.setLockEnabled(false);
      appLockEnabled.value = false;
      Get.snackbar(
        'Success',
        'App lock disabled',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade900,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> manageAppLock() async {
    await Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: .circular(20)),
        child: Padding(
          padding: .all(24),
          child: Column(
            mainAxisSize: .min,
            children: [
              const Text(
                'Manage App Lock',
                style: TextStyle(fontSize: 20, fontWeight: .bold),
              ),
              const SizedBox(height: 24),
              ListTile(
                contentPadding: .zero,
                leading: const Icon(
                  Icons.lock_outline,
                  color: AppColors.primary,
                ),
                title: const Text('Change PIN'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  Get.back();
                  await _changePin();
                },
              ),
              const Divider(),
              FutureBuilder<bool>(
                future: _appLockService.isBiometricAvailable(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data == true) {
                    return ListTile(
                      contentPadding: .zero,
                      leading: const Icon(
                        Icons.fingerprint,
                        color: AppColors.primary,
                      ),
                      title: const Text('Test Biometric'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        Get.back();
                        final authenticated = await _appLockService
                            .authenticateWithBiometrics();
                        Get.snackbar(
                          authenticated ? 'Success' : 'Failed',
                          authenticated
                              ? 'Biometric authentication successful'
                              : 'Biometric authentication failed',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: authenticated
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          colorText: authenticated
                              ? Colors.green.shade900
                              : Colors.red.shade900,
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: .end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _changePin() async {
    final currentPin = await _showPinVerificationDialog('Enter current PIN');
    if (currentPin == null) return;

    final isValid = await _appLockService.verifyPin(currentPin);
    if (!isValid) {
      Get.snackbar(
        'Error',
        'Incorrect PIN. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
      return;
    }

    final newPin = await _showPinSetupDialog('Enter new PIN');
    if (newPin == null || newPin.length != 4) {
      Get.snackbar(
        'Error',
        'Please enter a valid 4-digit PIN',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
      return;
    }

    final confirmPin = await _showPinSetupDialog('Confirm new PIN');
    if (confirmPin != newPin) {
      Get.snackbar(
        'Error',
        'PINs do not match. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
      return;
    }

    await _appLockService.setPin(newPin);
    Get.snackbar(
      'Success',
      'PIN changed successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade50,
      colorText: Colors.green.shade900,
      duration: const Duration(seconds: 2),
    );
  }

  Future<String?> _showPinVerificationDialog(String title) async {
    String? pin;
    await Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: .circular(20)),
        child: Padding(
          padding: .all(24),
          child: Column(
            mainAxisSize: .min,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: .bold),
              ),
              const SizedBox(height: 24),
              TextField(
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                textAlign: TextAlign.center,
                autofocus: true,
                style: const TextStyle(fontSize: 24, letterSpacing: 8),
                decoration: const InputDecoration(
                  hintText: '0000',
                  counterText: '',
                ),
                onChanged: (value) {
                  pin = value;
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: .end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (pin != null && pin!.length == 4) {
                        Get.back();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Verify'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return pin;
  }

  Future<String?> _showPinSetupDialog(String title) async {
    String? pin;
    await Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: .circular(20)),
        child: Padding(
          padding: .all(24),
          child: Column(
            mainAxisSize: .min,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: .bold),
              ),
              const SizedBox(height: 16),
              const Text('Enter a 4-digit PIN', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              TextField(
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                textAlign: TextAlign.center,
                autofocus: true,
                style: const TextStyle(fontSize: 24, letterSpacing: 8),
                decoration: const InputDecoration(
                  hintText: '0000',
                  counterText: '',
                ),
                onChanged: (value) {
                  pin = value;
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: .end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (pin != null && pin!.length == 4) {
                        Get.back();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Set PIN'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return pin;
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
          await homeController.addNewAccountFromBusiness(business);
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

      final updatedBusiness = business.copyWith(
        ownerName: ownerName.value.isNotEmpty ? ownerName.value : null,
      );

      await _businessRepository.updateBusiness(updatedBusiness);

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

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const .only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: .symmetric(vertical: 20),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: .only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: .circular(2),
                ),
              ),
              const Padding(
                padding: .symmetric(horizontal: 24, vertical: 8),
                child: Text(
                  'Select Photo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: .bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppColors.primaryDark),
                title: const Text('Take Photo'),
                onTap: () async {
                  Get.back();
                  await _pickImageFromCamera(picker);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: AppColors.primaryDark,
                ),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Get.back();
                  await _pickImageFromGallery(picker);
                },
              ),
              Obx(
                () => profileImageFile.value != null
                    ? ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: const Text('Remove Photo'),
                        onTap: () {
                          Get.back();
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
      PermissionStatus? photoStatus;

      if (Platform.isAndroid) {
        try {
          photoStatus = await Permission.photos.status;
          if (!photoStatus.isGranted) {
            photoStatus = await Permission.photos.request();
          }
        } catch (e) {
          photoStatus = await Permission.storage.status;
          if (!photoStatus.isGranted) {
            photoStatus = await Permission.storage.request();
          }
        }
      } else if (Platform.isIOS) {
        photoStatus = await Permission.photos.status;
        if (!photoStatus.isGranted) {
          photoStatus = await Permission.photos.request();
        }
      }

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

  static const String supportPhoneNumber = '+919155776919';
  static const String supportEmail = 'purehisab1@gmail.com';

  Future<void> openWhatsApp() async {
    try {
      final phoneNumber = supportPhoneNumber.replaceAll(RegExp(r'[^\d]'), '');

      final whatsappUrl = Uri.parse('https://wa.me/$phoneNumber');

      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'WhatsApp is not installed on your device',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade50,
          colorText: Colors.orange.shade900,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open WhatsApp. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> sendEmail() async {
    try {
      final emailUrl = Uri.parse('mailto:$supportEmail');
      final launched = await launchUrl(
        emailUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        Get.snackbar(
          'Error',
          'Unable to open email app. Please check if an email app is installed.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade50,
          colorText: Colors.orange.shade900,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open email app. Please make sure an email app is installed.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 3),
      );
    }
  }
}

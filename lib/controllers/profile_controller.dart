import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:purehisab/data/services/party_repo.dart';
import 'package:purehisab/controllers/home_controller.dart';
import '../app/utils/app_colors.dart';

class ProfileController extends GetxController {
  final PartyRepository _partyRepository = PartyRepository();

  final RxString customerName = ''.obs;
  final RxString customerPhone = ''.obs;
  final RxString customerId = ''.obs;
  final RxBool isCustomer = true.obs;
  final RxString address = ''.obs;
  final Rx<File?> profileImageFile = Rx<File?>(null);
  final RxBool isLoading = false.obs;

  // SMS Settings
  final RxBool smsEnabled = true.obs; // SMS will be sent on each entry
  final RxString smsLanguage = 'English'.obs; // 'English' or 'Hindi'

  @override
  void onInit() {
    super.onInit();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final args = Get.arguments;
    String? partyId;

    if (args != null && args is Map<String, dynamic>) {
      partyId = args['id']?.toString();
    }

    if (partyId == null || partyId.isEmpty) return;

    try {
      isLoading.value = true;
      final party = await _partyRepository.getPartyById(partyId);
      if (party != null) {
        customerId.value = party.id;
        customerName.value = party.partyName;
        customerPhone.value = party.phoneNumber ?? '';
        address.value = party.address ?? '';
        isCustomer.value = party.type == 'customer';

        // Load photo if photoUrl exists
        if (party.photoUrl != null && party.photoUrl!.isNotEmpty) {
          final photoFile = File(party.photoUrl!);
          if (await photoFile.exists()) {
            profileImageFile.value = photoFile;
          }
        }
      }
    } catch (e) {
      // Error handling
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateName(String name) async {
    if (customerId.value.isEmpty) return;

    try {
      isLoading.value = true;
      final party = await _partyRepository.getPartyById(customerId.value);
      if (party != null) {
        await _partyRepository.updateParty(party.copyWith(partyName: name));
        customerName.value = name;

        if (Get.isRegistered<HomeController>()) {
          await Get.find<HomeController>().loadPartiesFromDatabase();
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePhone(String phone) async {
    if (customerId.value.isEmpty) return;

    try {
      isLoading.value = true;
      final party = await _partyRepository.getPartyById(customerId.value);
      if (party != null) {
        await _partyRepository.updateParty(party.copyWith(phoneNumber: phone));
        customerPhone.value = phone;

        if (Get.isRegistered<HomeController>()) {
          await Get.find<HomeController>().loadPartiesFromDatabase();
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update phone',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateAddress(String newAddress) async {
    if (customerId.value.isEmpty) return;

    try {
      isLoading.value = true;
      final party = await _partyRepository.getPartyById(customerId.value);
      if (party != null) {
        await _partyRepository.updateParty(party.copyWith(address: newAddress));
        address.value = newAddress;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update address',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void toggleSmsEnabled() {
    smsEnabled.value = !smsEnabled.value;
  }

  void setSmsLanguage(String language) {
    smsLanguage.value = language;
  }

  Future<void> changeToCustomerOrSupplier() async {
    if (customerId.value.isEmpty) return;

    Get.bottomSheet(
      _ChangeTypeBottomSheet(
        customerName: customerName.value,
        customerPhone: customerPhone.value,
        isCurrentlyCustomer: isCustomer.value,
        onConfirm: () async {
          try {
            isLoading.value = true;
            final party = await _partyRepository.getPartyById(customerId.value);
            if (party != null) {
              final newType = party.type == 'customer'
                  ? 'supplier'
                  : 'customer';
              await _partyRepository.updateParty(party.copyWith(type: newType));
              isCustomer.value = newType == 'customer';

              if (Get.isRegistered<HomeController>()) {
                await Get.find<HomeController>().loadPartiesFromDatabase();
              }

              Get.back();
              Get.snackbar(
                'Success',
                '${customerName.value} has been changed to ${isCustomer.value ? "Customer" : "Supplier"}',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green.shade100,
                colorText: Colors.green.shade900,
              );
            }
          } catch (e) {
            Get.snackbar(
              'Error',
              'Failed to change type',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.shade100,
              colorText: Colors.red.shade900,
            );
          } finally {
            isLoading.value = false;
          }
        },
      ),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
    );
  }

  Future<void> deleteCustomerOrSupplier() async {
    if (customerId.value.isEmpty) return;

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const .only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: .only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(Get.context!).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: .start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: .only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: .circular(2),
                ),
              ),
            ),
            Text(
              'Delete ${customerName.value}?',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: .bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'This will delete the ${isCustomer.value ? 'customer' : 'supplier'} from your book.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppColors.primaryDark,
                        width: 1.5,
                      ),
                      foregroundColor: AppColors.primaryDark,
                      padding: .symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: .circular(10),
                      ),
                    ),
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: .w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        isLoading.value = true;
                        await _partyRepository.deleteParty(customerId.value);

                        if (Get.isRegistered<HomeController>()) {
                          await Get.find<HomeController>()
                              .loadPartiesFromDatabase();
                        }

                        Get.back();
                        Get.back();
                        Get.snackbar(
                          isCustomer.value
                              ? 'Customer Deleted'
                              : 'Supplier Deleted',
                          '${customerName.value} has been deleted',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green.shade100,
                          colorText: Colors.green.shade900,
                          duration: const Duration(seconds: 2),
                        );
                      } catch (e) {
                        Get.snackbar(
                          'Error',
                          'Failed to delete',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red.shade100,
                          colorText: Colors.red.shade900,
                        );
                      } finally {
                        isLoading.value = false;
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      padding: .symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: .circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'CONFIRM',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: .w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
    );
  }

  void shareBusinessCard() {
    // TODO: Implement business card sharing
    Get.snackbar(
      'Share Business Card',
      'Business card sharing feature coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> addPhoto() async {
    final ImagePicker picker = ImagePicker();

    // Show bottom sheet with options
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
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: .only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: .circular(2),
                ),
              ),
              // Title
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
                        onTap: () async {
                          Get.back(); // Close bottom sheet

                          // Remove photoUrl from database
                          if (customerId.value.isNotEmpty) {
                            try {
                              final party = await _partyRepository.getPartyById(
                                customerId.value,
                              );
                              if (party != null) {
                                await _partyRepository.updateParty(
                                  party.copyWith(clearPhotoUrl: true),
                                );

                                if (Get.isRegistered<HomeController>()) {
                                  await Get.find<HomeController>()
                                      .loadPartiesFromDatabase();
                                }
                              }
                            } catch (e) {
                              // Error handling
                            }
                          }

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
        final imageFile = File(image.path);
        profileImageFile.value = imageFile;

        // Save photoUrl to database
        if (customerId.value.isNotEmpty) {
          try {
            final party = await _partyRepository.getPartyById(customerId.value);
            if (party != null) {
              await _partyRepository.updateParty(
                party.copyWith(photoUrl: image.path),
              );

              if (Get.isRegistered<HomeController>()) {
                await Get.find<HomeController>().loadPartiesFromDatabase();
              }
            }
          } catch (e) {
            // Error handling
          }
        }

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
        final imageFile = File(image.path);
        profileImageFile.value = imageFile;

        // Save photoUrl to database
        if (customerId.value.isNotEmpty) {
          try {
            final party = await _partyRepository.getPartyById(customerId.value);
            if (party != null) {
              await _partyRepository.updateParty(
                party.copyWith(photoUrl: image.path),
              );

              if (Get.isRegistered<HomeController>()) {
                await Get.find<HomeController>().loadPartiesFromDatabase();
              }
            }
          } catch (e) {
            // Error handling
          }
        }

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

class _ChangeTypeBottomSheet extends StatelessWidget {
  final String customerName;
  final String customerPhone;
  final bool isCurrentlyCustomer;
  final VoidCallback onConfirm;

  const _ChangeTypeBottomSheet({
    required this.customerName,
    required this.customerPhone,
    required this.isCurrentlyCustomer,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final newType = isCurrentlyCustomer ? 'Supplier' : 'Customer';
    final currentType = isCurrentlyCustomer ? 'Customer' : 'Supplier';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const .only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: .only(
        left: 28,
        right: 28,
        top: 28,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: .start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: .only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: .circular(2),
              ),
            ),
          ),
          // Title
          Text(
            'Change $customerName to $newType?',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: .bold,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 28),
          // Profile Information
          Row(
            children: [
              // Circular Avatar with teal color
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    customerName.isNotEmpty
                        ? customerName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: .bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Name and Phone
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      customerName,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: .w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      customerPhone.isNotEmpty
                          ? customerPhone
                          : 'No phone number',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                        fontWeight: .w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          // Description
          Text(
            'All entries of $customerName will be safely transferred from $currentType to $newType section',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.5,
              fontWeight: .w400,
            ),
          ),
          const SizedBox(height: 32),
          // Change Button - Green and prominent
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: .symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: .circular(10)),
                elevation: 0,
              ),
              child: const Text(
                'CHANGE',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: .w700,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

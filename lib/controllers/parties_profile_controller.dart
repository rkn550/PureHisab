import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:purehisab/app/utils/snacks_bar.dart';
import 'package:purehisab/data/services/party_repo.dart';
import 'package:purehisab/controllers/parties_detail_controller.dart';
import '../app/utils/app_colors.dart';

class PartiesProfileController extends GetxController {
  PartyRepository get _partyRepository => Get.find<PartyRepository>();
  final RxBool _isLoading = false.obs;
  final RxString _partyId = ''.obs;
  final RxString _partyName = ''.obs;
  final RxString _partyPhoneNumber = ''.obs;
  final RxString _partyType = 'customer'.obs;
  final RxString _address = ''.obs;
  final Rx<File?> _profileImageFile = Rx<File?>(null);
  final RxBool _smsEnabled = false.obs;
  final RxString _smsLanguage = 'english'.obs;

  bool get isLoading => _isLoading.value;
  String get partyId => _partyId.value;
  String get partyName => _partyName.value;
  String get partyPhoneNumber => _partyPhoneNumber.value;
  String get partyType => _partyType.value;
  String get address => _address.value;
  File? get profileImageFile => _profileImageFile.value;
  bool get smsEnabled => _smsEnabled.value;
  String get smsLanguage => _smsLanguage.value;

  @override
  void onInit() {
    super.onInit();
    loadArgumentData();
  }

  Future<void> loadArgumentData() async {
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      _partyId.value =
          args['partyId']?.toString() ?? args['id']?.toString() ?? '';
      _partyType.value = args['partyType']?.toString() ?? 'customer';
    }
    await _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    if (partyId.isEmpty) return;

    try {
      _isLoading.value = true;
      final party = await _partyRepository.getPartyById(partyId);
      if (party != null) {
        _partyName.value = party.partyName;
        _partyPhoneNumber.value = party.phoneNumber;
        _address.value = party.address ?? '';
        _smsEnabled.value = party.smsSetting;
        _smsLanguage.value = party.smsLanguage ?? 'english';
        _partyType.value = party.type;
        if (party.partiesPhotoUrl != null &&
            party.partiesPhotoUrl!.isNotEmpty) {
          final photoFile = File(party.partiesPhotoUrl!);
          if (await photoFile.exists()) {
            _profileImageFile.value = photoFile;
          } else {
            _profileImageFile.value = null;
          }
        } else {
          _profileImageFile.value = null;
        }
      } else {
        SnacksBar.showSnackbar(
          title: 'Error',
          message: 'Party not found',
          type: SnacksBarType.ERROR,
        );
      }
    } catch (e) {
      SnacksBar.showSnackbar(
        title: 'Error',
        message: 'Failed to load profile data: ${e.toString()}',
        type: SnacksBarType.ERROR,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateName(String name) async {
    if (partyId.isEmpty) return;

    try {
      _isLoading.value = true;
      final party = await _partyRepository.getPartyById(partyId);
      if (party != null) {
        await _partyRepository.updateParty(party.copyWith(partyName: name));
        await _loadProfileData();
      }
    } catch (e) {
      SnacksBar.showSnackbar(
        title: 'Error',
        message: 'Failed to update name',
        type: SnacksBarType.ERROR,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updatePhone(String phone) async {
    if (partyId.isEmpty) return;

    try {
      _isLoading.value = true;
      final party = await _partyRepository.getPartyById(partyId);
      if (party != null) {
        await _partyRepository.updateParty(party.copyWith(phoneNumber: phone));
        await _loadProfileData();
      }
    } catch (e) {
      SnacksBar.showSnackbar(
        title: 'Error',
        message: 'Failed to update phone',
        type: SnacksBarType.ERROR,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateAddress(String newAddress) async {
    if (partyId.isEmpty) return;

    try {
      _isLoading.value = true;
      final party = await _partyRepository.getPartyById(partyId);
      if (party != null) {
        await _partyRepository.updateParty(party.copyWith(address: newAddress));
        await _loadProfileData();
      }
    } catch (e) {
      SnacksBar.showSnackbar(
        title: 'Error',
        message: 'Failed to update address',
        type: SnacksBarType.ERROR,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> toggleSmsEnabled() async {
    if (partyId.isEmpty) return;
    try {
      final newValue = !smsEnabled;
      final party = await _partyRepository.getPartyById(partyId);
      if (party != null) {
        await _partyRepository.updateParty(
          party.copyWith(smsSetting: newValue),
        );
        await _loadProfileData();
        if (Get.isRegistered<PartiesDetailController>()) {
          final detailController = Get.find<PartiesDetailController>();
          await detailController.reloadPartyData();
        }
        SnacksBar.showSnackbar(
          title: 'Success',
          message: 'SMS settings updated',
          type: SnacksBarType.SUCCESS,
        );
      }
    } catch (e) {
      SnacksBar.showSnackbar(
        title: 'Error',
        message: 'Failed to update SMS settings',
        type: SnacksBarType.ERROR,
      );
    }
  }

  Future<void> setSmsLanguage(String language) async {
    if (partyId.isEmpty) return;

    try {
      final party = await _partyRepository.getPartyById(partyId);
      if (party != null) {
        await _partyRepository.updateParty(
          party.copyWith(smsLanguage: language),
        );
        await _loadProfileData();

        if (Get.isRegistered<PartiesDetailController>()) {
          final detailController = Get.find<PartiesDetailController>();
          await detailController.reloadPartyData();
        }

        SnacksBar.showSnackbar(
          title: 'Success',
          message: 'SMS language updated to $language',
          type: SnacksBarType.SUCCESS,
        );
      }
    } catch (e) {
      SnacksBar.showSnackbar(
        title: 'Error',
        message: 'Failed to update SMS language',
        type: SnacksBarType.ERROR,
      );
    }
  }

  Future<void> changeToCustomerOrSupplier() async {
    if (partyId.isEmpty) return;

    Get.bottomSheet(
      _ChangeTypeBottomSheet(
        partyName: partyName,
        partyPhoneNumber: partyPhoneNumber,
        partyType: partyType,
        photoUrl: profileImageFile?.path,
        onConfirm: () async {
          try {
            final party = await _partyRepository.getPartyById(partyId);
            if (party != null) {
              final newType = party.type == 'customer'
                  ? 'supplier'
                  : 'customer';
              await _partyRepository.updateParty(party.copyWith(type: newType));
              await _loadProfileData();
              Get.back();
              SnacksBar.showSnackbar(
                title: 'Success',
                message:
                    '$partyName has been changed to ${partyType == 'customer' ? "Customer" : "Supplier"}',
                type: SnacksBarType.SUCCESS,
              );
            }
          } catch (e) {
            SnacksBar.showSnackbar(
              title: 'Error',
              message: 'Failed to change type',
              type: SnacksBarType.ERROR,
            );
          } finally {
            _isLoading.value = false;
          }
        },
      ),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
    );
  }

  Future<void> deleteCustomerOrSupplier() async {
    if (partyId.isEmpty) return;

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
              'Delete $partyName?',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: .bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'This will delete the ${partyType == 'customer' ? 'customer' : 'supplier'} from your book.',
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
                        _isLoading.value = true;
                        await _partyRepository.deleteParty(partyId);
                        Get.back();
                        Get.back();
                        SnacksBar.showSnackbar(
                          title: partyType == 'customer'
                              ? 'Customer Deleted'
                              : 'Supplier Deleted',
                          message: '$partyName has been deleted',
                          type: SnacksBarType.SUCCESS,
                        );
                      } catch (e) {
                        SnacksBar.showSnackbar(
                          title: 'Error',
                          message: 'Failed to delete',
                          type: SnacksBarType.ERROR,
                        );
                      } finally {
                        _isLoading.value = false;
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
                  Get.back(); // Close bottom sheet
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
                  Get.back(); // Close bottom sheet
                  await _pickImageFromGallery(picker);
                },
              ),
              Obx(
                () => _profileImageFile.value != null
                    ? ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: const Text('Remove Photo'),
                        onTap: () async {
                          Get.back();

                          if (partyId.isNotEmpty) {
                            try {
                              final party = await _partyRepository.getPartyById(
                                partyId,
                              );
                              if (party != null) {
                                await _partyRepository.updateParty(
                                  party.copyWith(clearPartyPhotoUrl: true),
                                );

                                await _loadProfileData();
                              }
                            } catch (e) {
                              SnacksBar.showSnackbar(
                                title: 'Error',
                                message: 'Failed to remove photo',
                                type: SnacksBarType.ERROR,
                              );
                            }
                          }

                          _profileImageFile.value = null;
                          SnacksBar.showSnackbar(
                            title: 'Success',
                            message: 'Photo removed',
                            type: SnacksBarType.SUCCESS,
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
          SnacksBar.showSnackbar(
            title: 'Permission Denied',
            message: 'Camera permission is required to take photos',
            type: SnacksBarType.ERROR,
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
        if (partyId.isNotEmpty) {
          try {
            final party = await _partyRepository.getPartyById(partyId);
            if (party != null) {
              await _partyRepository.updateParty(
                party.copyWith(partyPhotoUrl: image.path),
              );
              final imageFile = File(image.path);
              if (await imageFile.exists()) {
                _profileImageFile.value = imageFile;
              }
              await _loadProfileData();
              SnacksBar.showSnackbar(
                title: 'Success',
                message: 'Photo added successfully',
                type: SnacksBarType.SUCCESS,
              );
            }
          } catch (e) {
            SnacksBar.showSnackbar(
              title: 'Error',
              message: 'Failed to save photo',
              type: SnacksBarType.ERROR,
            );
            return;
          }
        }
      }
    } catch (e) {
      SnacksBar.showSnackbar(
        title: 'Error',
        message: 'Failed to take photo. Please try again.',
        type: SnacksBarType.ERROR,
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
        SnacksBar.showSnackbar(
          title: 'Permission Denied',
          message: 'Please enable photo library permission in settings',
          type: SnacksBarType.ERROR,
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
        if (partyId.isNotEmpty) {
          try {
            final party = await _partyRepository.getPartyById(partyId);
            if (party != null) {
              await _partyRepository.updateParty(
                party.copyWith(partyPhotoUrl: image.path),
              );

              final imageFile = File(image.path);
              if (await imageFile.exists()) {
                _profileImageFile.value = imageFile;
              }

              await _loadProfileData();

              SnacksBar.showSnackbar(
                title: 'Success',
                message: 'Photo added successfully',
                type: SnacksBarType.SUCCESS,
              );
            }
          } catch (e) {
            SnacksBar.showSnackbar(
              title: 'Error',
              message: 'Failed to save photo',
              type: SnacksBarType.ERROR,
            );
            return;
          }
        }
      }
    } catch (e) {
      SnacksBar.showSnackbar(
        title: 'Error',
        message: 'Failed to pick photo. Please try again.',
        type: SnacksBarType.ERROR,
      );
    }
  }
}

class _ChangeTypeBottomSheet extends StatelessWidget {
  final String partyName;
  final String partyPhoneNumber;
  final String partyType;
  final String? photoUrl;
  final VoidCallback onConfirm;

  const _ChangeTypeBottomSheet({
    required this.partyName,
    required this.partyPhoneNumber,
    required this.partyType,
    required this.photoUrl,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final newType = partyType == 'customer' ? 'supplier' : 'customer';
    final currentType = partyType == 'customer' ? 'customer' : 'supplier';

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
            'Change $partyName to $newType?',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: .bold,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    partyName.isNotEmpty ? partyName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: .bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      partyName,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: .w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      partyPhoneNumber.isNotEmpty
                          ? partyPhoneNumber
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
          Text(
            'All entries of $partyName will be safely transferred from $currentType to $newType section',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.5,
              fontWeight: .w400,
            ),
          ),
          const SizedBox(height: 32),
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

import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:purehisab/app/routes/app_pages.dart';
import 'package:purehisab/app/utils/snacks_bar.dart';
import 'package:purehisab/data/services/party_repo.dart';
import 'package:purehisab/controllers/parties_detail_controller.dart';
import 'package:purehisab/data/services/transaction_repo.dart';
import 'package:purehisab/controllers/analytics_controller.dart';
import '../screens/widgets/change_type_bottom_sheet.dart';
import '../screens/widgets/delete_party_bottom_sheet.dart';
import '../screens/widgets/select_photo_bottom_sheet.dart';

class PartiesProfileController extends GetxController {
  PartyRepository get _partyRepository => Get.find<PartyRepository>();
  TransactionRepository get _transactionRepository =>
      Get.find<TransactionRepository>();
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
      ChangeTypeBottomSheet(
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
      DeletePartyBottomSheet(
        partyName: partyName,
        partyType: partyType,
        onConfirm: () async {
          try {
            _isLoading.value = true;

            // Get party to retrieve businessId before deletion
            final party = await _partyRepository.getPartyById(partyId);
            final businessId = party?.businessId ?? '';

            await _partyRepository.deleteParty(partyId);
            await _transactionRepository.deleteTransactionsByPartyId(partyId);

            // Refresh analytics data if controller is registered
            if (Get.isRegistered<AnalyticsController>()) {
              final analyticsController = Get.find<AnalyticsController>();
              if (businessId.isNotEmpty) {
                await analyticsController.reloadAnalyticsDataWithBusinessId(
                  businessId,
                );
              } else {
                await analyticsController.reloadAnalyticsData();
              }
            }

            Get.back();
            Get.offAllNamed(Routes.home);
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
      ),
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
    );
  }

  Future<void> addPhoto() async {
    final ImagePicker picker = ImagePicker();

    Get.bottomSheet(
      Obx(
        () => SelectPhotoBottomSheet(
          hasPhoto: _profileImageFile.value != null,
          onTakePhoto: () => _pickImageFromCamera(picker),
          onChooseFromGallery: () => _pickImageFromGallery(picker),
          onRemovePhoto: _profileImageFile.value != null
              ? () async {
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
                }
              : null,
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

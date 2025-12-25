import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:purehisab/app/utils/snacks_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:purehisab/data/services/business_repo.dart';
import 'package:purehisab/data/services/app_lock_service.dart';
import 'package:purehisab/controllers/navigation_controller.dart';

class BusinessProfileController extends GetxController {
  BusinessRepository get _businessRepository => Get.find<BusinessRepository>();
  AppLockService get _appLockService => Get.find<AppLockService>();

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final RxString _businessId = ''.obs;
  String get businessId => _businessId.value;

  final RxString _businessName = ''.obs;
  String get businessName => _businessName.value;

  final RxString _ownerName = ''.obs;
  String get ownerName => _ownerName.value;

  final RxString _businessPhone = ''.obs;
  String get businessPhone => _businessPhone.value;

  final Rx<File?> profileImageFile = Rx<File?>(null);

  final RxBool settingsExpanded = false.obs;
  final RxBool appLockEnabled = false.obs;
  final RxBool aboutExpanded = false.obs;
  final RxBool helpSupportExpanded = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadBusinessFromNavigationController();
    _loadAppLockState();
    _setupBusinessIdListener();
  }

  void _setupBusinessIdListener() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (Get.isRegistered<NavigationController>()) {
        final navController = Get.find<NavigationController>();
        ever(navController.businessIdRx, (String newBusinessId) {
          if (newBusinessId.isNotEmpty && newBusinessId != _businessId.value) {
            _businessId.value = newBusinessId;
            loadBusinessFromDatabase(newBusinessId);
          }
        });
        if (navController.businessId.isNotEmpty &&
            navController.businessId != _businessId.value) {
          _businessId.value = navController.businessId;
          loadBusinessFromDatabase(navController.businessId);
        }
      }
    });
  }

  void _loadBusinessFromNavigationController() {
    if (Get.isRegistered<NavigationController>()) {
      final navController = Get.find<NavigationController>();
      final selectedBusinessId = navController.businessId;
      if (selectedBusinessId.isNotEmpty) {
        _businessId.value = selectedBusinessId;
        loadBusinessFromDatabase(selectedBusinessId);
      } else if (navController.businesses.isNotEmpty) {
        final firstBusinessId = navController.businesses.first.id;
        _businessId.value = firstBusinessId;
        navController.businessId = firstBusinessId;
        loadBusinessFromDatabase(firstBusinessId);
      }
    }
  }

  void refreshBusinessData() {
    if (Get.isRegistered<NavigationController>()) {
      final navController = Get.find<NavigationController>();
      final selectedBusinessId = navController.businessId;
      if (selectedBusinessId.isNotEmpty) {
        if (selectedBusinessId != _businessId.value) {
          _businessId.value = selectedBusinessId;
          loadBusinessFromDatabase(selectedBusinessId);
        }
      }
    }
  }

  Future<void> _loadAppLockState() async {
    appLockEnabled.value = await _appLockService.isLockEnabled();
  }

  Future<void> loadBusinessFromDatabase(String id) async {
    if (id.isEmpty) {
      return;
    }

    _businessId.value = id;
    try {
      _isLoading.value = true;

      final business = await _businessRepository.getBusinessById(id);
      if (business != null) {
        _businessName.value = business.businessName;
        _ownerName.value = business.ownerName ?? '';
        _businessPhone.value = business.phoneNumber ?? '';

        if (business.businessPhotoUrl != null &&
            business.businessPhotoUrl!.isNotEmpty) {
          final imageFile = File(business.businessPhotoUrl!);
          if (await imageFile.exists()) {
            profileImageFile.value = imageFile;
          } else {
            profileImageFile.value = null;
          }
        } else {
          profileImageFile.value = null;
        }
      } else {
        SnacksBar.showSnackbar(
          title: 'Error',
          message: 'Business not found',
          type: SnacksBarType.ERROR,
        );
      }
    } catch (e) {
      SnacksBar.showSnackbar(
        title: 'Error',
        message: 'Failed to load business data: ${e.toString()}',
        type: SnacksBarType.ERROR,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
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
        try {
          if (businessId.isEmpty) {
            throw Exception('Business ID not found');
          }

          final business = await _businessRepository.getBusinessById(
            businessId,
          );
          if (business == null) {
            throw Exception('Business not found');
          }

          final updatedBusiness = business.copyWith(
            businessPhotoUrl: image.path,
          );

          await _businessRepository.updateBusiness(updatedBusiness);

          await loadBusinessFromDatabase(businessId);

          SnacksBar.showSnackbar(
            title: 'Success',
            message: 'Photo added successfully',
            type: SnacksBarType.SUCCESS,
          );
        } catch (e) {
          SnacksBar.showSnackbar(
            title: 'Error',
            message: 'Failed to save photo: ${e.toString()}',
            type: SnacksBarType.ERROR,
          );
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

  Future<void> pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
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
        try {
          if (businessId.isEmpty) {
            throw Exception('Business ID not found');
          }

          final business = await _businessRepository.getBusinessById(
            businessId,
          );
          if (business == null) {
            throw Exception('Business not found');
          }

          final updatedBusiness = business.copyWith(
            businessPhotoUrl: image.path,
          );

          await _businessRepository.updateBusiness(updatedBusiness);

          await loadBusinessFromDatabase(businessId);

          SnacksBar.showSnackbar(
            title: 'Success',
            message: 'Photo added successfully',
            type: SnacksBarType.SUCCESS,
          );
        } catch (e) {
          SnacksBar.showSnackbar(
            title: 'Error',
            message: 'Failed to save photo: ${e.toString()}',
            type: SnacksBarType.ERROR,
          );
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

  Future<void> removePhoto() async {
    try {
      if (businessId.isEmpty) {
        throw Exception('Business ID not found');
      }

      final business = await _businessRepository.getBusinessById(businessId);
      if (business == null) {
        throw Exception('Business not found');
      }

      final updatedBusiness = business.copyWith(businessPhotoUrl: null);

      await _businessRepository.updateBusiness(updatedBusiness);
      profileImageFile.value = null;

      await loadBusinessFromDatabase(businessId);

      SnacksBar.showSnackbar(
        title: 'Success',
        message: 'Photo removed',
        type: SnacksBarType.SUCCESS,
      );
    } catch (e) {
      SnacksBar.showSnackbar(
        title: 'Error',
        message: 'Failed to remove photo: ${e.toString()}',
        type: SnacksBarType.ERROR,
      );
    }
  }

  Future<void> updateOwnerName(String ownerName) async {
    try {
      if (businessId.isEmpty) {
        SnacksBar.showSnackbar(
          title: 'Error',
          message: 'Business ID not found',
          type: SnacksBarType.ERROR,
        );
        return;
      }

      final business = await _businessRepository.getBusinessById(businessId);
      if (business == null) {
        SnacksBar.showSnackbar(
          title: 'Error',
          message: 'Business not found',
          type: SnacksBarType.ERROR,
        );
        return;
      }

      final updatedBusiness = business.copyWith(ownerName: ownerName);
      await _businessRepository.updateBusiness(updatedBusiness);

      await loadBusinessFromDatabase(businessId);

      SnacksBar.showSnackbar(
        title: 'Success',
        message: 'Owner name updated',
        type: SnacksBarType.SUCCESS,
      );
    } catch (e) {
      SnacksBar.showSnackbar(
        title: 'Error',
        message: 'Failed to update owner name: ${e.toString()}',
        type: SnacksBarType.ERROR,
      );
    }
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

  Future<String?> Function(String)? showPinSetupDialog;
  Future<String?> Function(String)? showPinVerificationDialog;
  Future<bool?> Function()? showDisableAppLockDialog;
  void Function()? showManageAppLockDialog;
  void Function()? showPhotoSelectionBottomSheet;

  Future<void> _enableAppLock() async {
    final hasPin = await _appLockService.hasPin();
    if (!hasPin) {
      if (showPinSetupDialog == null) return;
      final pin = await showPinSetupDialog!('Set PIN');
      if (pin == null || pin.length != 4) {
        SnacksBar.showSnackbar(
          title: 'Error',
          message: 'PIN is required to enable app lock',
          type: SnacksBarType.ERROR,
        );
        return;
      }
      await _appLockService.setPin(pin);
    }

    await _appLockService.setLockEnabled(true);
    appLockEnabled.value = true;
    SnacksBar.showSnackbar(
      title: 'Success',
      message: 'App lock enabled',
      type: SnacksBarType.SUCCESS,
    );
  }

  Future<void> _disableAppLock() async {
    if (showDisableAppLockDialog == null) return;
    final confirmed = await showDisableAppLockDialog!();

    if (confirmed == true) {
      await _appLockService.setLockEnabled(false);
      appLockEnabled.value = false;
      SnacksBar.showSnackbar(
        title: 'Success',
        message: 'App lock disabled',
        type: SnacksBarType.SUCCESS,
      );
    }
  }

  Future<void> manageAppLock() async {
    showManageAppLockDialog?.call();
  }

  Future<void> changePin() async {
    if (showPinVerificationDialog == null || showPinSetupDialog == null) return;

    final currentPin = await showPinVerificationDialog!('Enter current PIN');
    if (currentPin == null) return;

    final isValid = await _appLockService.verifyPin(currentPin);
    if (!isValid) {
      SnacksBar.showSnackbar(
        title: 'Error',
        message: 'Incorrect PIN. Please try again.',
        type: SnacksBarType.ERROR,
      );
      return;
    }
    final newPin = await showPinSetupDialog!('Enter new PIN');
    if (newPin == null || newPin.length != 4) {
      SnacksBar.showSnackbar(
        title: 'Error',
        message: 'Please enter a valid 4-digit PIN',
        type: SnacksBarType.ERROR,
      );
      return;
    }

    final confirmPin = await showPinSetupDialog!('Confirm new PIN');
    if (confirmPin != newPin) {
      SnacksBar.showSnackbar(
        title: 'Error',
        message: 'PINs do not match. Please try again.',
        type: SnacksBarType.ERROR,
      );
      return;
    }

    await _appLockService.setPin(newPin);
    SnacksBar.showSnackbar(
      title: 'Success',
      message: 'PIN changed successfully',
      type: SnacksBarType.SUCCESS,
    );
  }

  void toggleAboutExpanded() {
    aboutExpanded.value = !aboutExpanded.value;
  }

  void toggleHelpSupportExpanded() {
    helpSupportExpanded.value = !helpSupportExpanded.value;
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  void addPhoto() {
    showPhotoSelectionBottomSheet?.call();
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
        SnacksBar.showSnackbar(
          title: 'Error',
          message: 'WhatsApp is not installed on your device',
          type: SnacksBarType.ERROR,
        );
      }
    } catch (e) {
      SnacksBar.showSnackbar(
        title: 'Error',
        message: 'Failed to open WhatsApp. Please try again.',
        type: SnacksBarType.ERROR,
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
        SnacksBar.showSnackbar(
          title: 'Error',
          message:
              'Unable to open email app. Please check if an email app is installed.',
          type: SnacksBarType.ERROR,
        );
      }
    } catch (e) {
      SnacksBar.showSnackbar(
        title: 'Error',
        message:
            'Failed to open email app. Please make sure an email app is installed.',
        type: SnacksBarType.ERROR,
      );
    }
  }
}

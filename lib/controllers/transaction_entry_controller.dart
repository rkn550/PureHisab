import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:purehisab/data/services/transaction_repo.dart';
import 'package:purehisab/controllers/home_controller.dart';
import 'customer_detail_controller.dart';

class TransactionEntryController extends GetxController {
  final TransactionRepository _transactionRepository = TransactionRepository();
  final ImagePicker _imagePicker = ImagePicker();

  final RxString transactionType = 'give'.obs;
  final RxString customerName = ''.obs;
  final RxString customerId = ''.obs;
  final Rx<File?> billImageFile = Rx<File?>(null);

  // Calculator state
  final RxString currentInput = '0'.obs;
  final RxString calculationDisplay = ''.obs;
  final RxDouble result = 0.0.obs;
  String? pendingOperation;
  double? previousValue;

  // Transaction details
  final RxString details = ''.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final detailsController = TextEditingController();
  final detailsFocusNode = FocusNode();
  final amountController = TextEditingController();
  final amountFocusNode = FocusNode();

  // Show/hide calculator keypad
  final RxBool showCalculator = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTransactionData();
    // Initialize amount controller
    amountController.text = '0';
    amountController.addListener(() {
      if (amountController.text.isEmpty) {
        currentInput.value = '0';
      } else {
        currentInput.value = amountController.text;
      }
    });

    // Handle focus changes to show/hide calculator
    amountFocusNode.addListener(() {
      if (amountFocusNode.hasFocus) {
        showCalculator.value = true;
        // Unfocus details field if it's focused
        if (detailsFocusNode.hasFocus) {
          detailsFocusNode.unfocus();
        }
      }
    });

    detailsFocusNode.addListener(() {
      if (detailsFocusNode.hasFocus) {
        showCalculator.value = false;
        // Unfocus amount field if it's focused
        if (amountFocusNode.hasFocus) {
          amountFocusNode.unfocus();
        }
      } else {
        // When details field loses focus, show calculator again
        showCalculator.value = true;
      }
    });
  }

  void _loadTransactionData() {
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      transactionType.value = args['type']?.toString() ?? 'give';
      customerName.value = args['customerName']?.toString() ?? 'Unknown';
      customerId.value = args['customerId']?.toString() ?? '';
    }
  }

  // Calculator functions
  void onNumberPressed(String number) {
    final currentText = amountController.text;
    if (currentText == '0' && number != '.') {
      amountController.text = number;
      currentInput.value = number;
    } else if (currentText == '0' && number == '.') {
      amountController.text = '0.';
      currentInput.value = '0.';
    } else {
      amountController.text = currentText + number;
      currentInput.value = currentText + number;
    }
    _updateCalculationDisplay();
  }

  void onOperatorPressed(String operator) {
    if (pendingOperation != null && previousValue != null) {
      _calculate();
    } else {
      previousValue = double.tryParse(amountController.text) ?? 0.0;
    }

    pendingOperation = operator;
    calculationDisplay.value = '${previousValue!.toStringAsFixed(0)}$operator';
    amountController.text = '0';
    currentInput.value = '0';
  }

  void onEqualsPressed() {
    if (pendingOperation != null && previousValue != null) {
      _calculate();
      pendingOperation = null;
      previousValue = null;
      calculationDisplay.value = '';
    }
  }

  void _calculate() {
    final currentValue = double.tryParse(amountController.text) ?? 0.0;
    double calculatedResult = 0.0;

    switch (pendingOperation) {
      case '+':
        calculatedResult = previousValue! + currentValue;
        break;
      case '-':
        calculatedResult = previousValue! - currentValue;
        break;
      case '×':
        calculatedResult = previousValue! * currentValue;
        break;
      case '÷':
        if (currentValue != 0) {
          calculatedResult = previousValue! / currentValue;
        } else {
          Get.snackbar('Error', 'Cannot divide by zero');
          return;
        }
        break;
      case '%':
        calculatedResult = (previousValue! * currentValue) / 100;
        break;
    }

    result.value = calculatedResult;
    final resultString = calculatedResult
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\.0+$'), (match) => '');
    amountController.text = resultString;
    currentInput.value = resultString;
    calculationDisplay.value =
        '${previousValue!.toStringAsFixed(0)}$pendingOperation${currentValue.toStringAsFixed(0)} = ${calculatedResult.toStringAsFixed(0)}';
  }

  void _updateCalculationDisplay() {
    if (pendingOperation != null && previousValue != null) {
      calculationDisplay.value =
          '${previousValue!.toStringAsFixed(0)}$pendingOperation';
    }
  }

  void onClearPressed() {
    amountController.text = '0';
    currentInput.value = '0';
    calculationDisplay.value = '';
    pendingOperation = null;
    previousValue = null;
    result.value = 0.0;
  }

  void onBackspacePressed() {
    final currentText = amountController.text;
    if (currentText.length > 1) {
      final newText = currentText.substring(0, currentText.length - 1);
      amountController.text = newText;
      currentInput.value = newText;
    } else {
      amountController.text = '0';
      currentInput.value = '0';
    }
    _updateCalculationDisplay();
  }

  void onMemoryPlus() {
    // TODO: Implement memory plus
    Get.snackbar('Memory', 'Memory Plus - Coming soon');
  }

  void onMemoryMinus() {
    // TODO: Implement memory minus
    Get.snackbar('Memory', 'Memory Minus - Coming soon');
  }

  void onDecimalPressed() {
    final currentText = amountController.text;
    if (!currentText.contains('.')) {
      amountController.text = '$currentText.';
      currentInput.value = '$currentText.';
    }
  }

  // Date picker
  Future<void> selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  // Format date for display
  String getFormattedDate() {
    final date = selectedDate.value;
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year.toString().substring(2)}';
  }

  // Get current amount
  double getCurrentAmount() {
    return double.tryParse(amountController.text) ?? 0.0;
  }

  Future<void> saveTransaction() async {
    final amount = getCurrentAmount();
    if (amount <= 0) {
      Get.snackbar('Error', 'Please enter a valid amount');
      return;
    }

    if (customerId.value.isEmpty) {
      Get.snackbar('Error', 'Customer ID not found');
      return;
    }

    if (!Get.isRegistered<HomeController>()) {
      Get.snackbar('Error', 'HomeController not found');
      return;
    }

    try {
      final homeController = Get.find<HomeController>();
      if (homeController.selectedBusinessId.value.isEmpty) {
        Get.snackbar('Error', 'No business selected');
        return;
      }

      String? photoUrl;
      if (billImageFile.value != null) {
        photoUrl = billImageFile.value!.path;
      }

      await _transactionRepository.createTransaction(
        businessId: homeController.selectedBusinessId.value,
        partyId: customerId.value,
        amount: amount,
        direction: transactionType.value == 'give' ? 'gave' : 'got',
        date: selectedDate.value.millisecondsSinceEpoch,
        description: details.value.isNotEmpty ? details.value : null,
        photoUrl: photoUrl,
      );

      billImageFile.value = null;

      if (Get.isRegistered<CustomerDetailController>()) {
        final customerController = Get.find<CustomerDetailController>();
        await customerController.loadTransactions();
        customerController.calculateSummary();
      }

      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        await homeController.loadPartiesFromDatabase();
      }

      Get.back(result: {'success': true});

      Future.delayed(const Duration(milliseconds: 300), () {
        if (Get.isSnackbarOpen == false) {
          Get.snackbar(
            'Success',
            'Transaction saved successfully',
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
            : 'Failed to save transaction. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 4),
      );
    }
  }

  Future<void> onAttachBills() async {
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
                  'Attach Bill',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: .bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  color: transactionType.value == 'give'
                      ? Colors.red
                      : Colors.green,
                ),
                title: const Text('Take Photo'),
                onTap: () async {
                  Get.back();
                  await _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: transactionType.value == 'give'
                      ? Colors.red
                      : Colors.green,
                ),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Get.back();
                  await _pickImageFromGallery();
                },
              ),
              Obx(
                () => billImageFile.value != null
                    ? ListTile(
                        leading: const Icon(Icons.delete, color: Colors.red),
                        title: const Text('Remove Bill'),
                        onTap: () {
                          Get.back();
                          billImageFile.value = null;
                          Get.snackbar(
                            'Success',
                            'Bill removed',
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

  Future<void> _pickImageFromCamera() async {
    try {
      final cameraStatus = await Permission.camera.status;
      if (!cameraStatus.isGranted) {
        final result = await Permission.camera.request();
        if (!result.isGranted) {
          Get.snackbar(
            'Permission Denied',
            'Camera permission is required to take photos',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange.shade100,
            colorText: Colors.orange.shade900,
            duration: const Duration(seconds: 3),
          );
          return;
        }
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (image != null) {
        billImageFile.value = File(image.path);
        Get.snackbar(
          'Success',
          'Bill photo added',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to take photo. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
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
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade900,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (image != null) {
        billImageFile.value = File(image.path);
        Get.snackbar(
          'Success',
          'Bill photo added',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick photo. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  void onClose() {
    detailsController.dispose();
    detailsFocusNode.dispose();
    amountController.dispose();
    amountFocusNode.dispose();
    super.onClose();
  }
}

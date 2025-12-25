import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:purehisab/app/utils/snacks_bar.dart';
import 'package:purehisab/controllers/analytics_controller.dart';

import '../../../data/services/transaction_repo.dart';
import '../../../controllers/navigation_controller.dart';

class TransactionEntryController extends GetxController {
  final TransactionRepository _repo = Get.find();
  final ImagePicker _picker = ImagePicker();

  final RxString _transactionType = 'give'.obs;
  final RxString _partyId = ''.obs;
  final RxString _businessId = ''.obs;

  String get transactionType => _transactionType.value;
  String get partyId => _partyId.value;
  String get businessId => _businessId.value;

  final Rx<File?> billImage = Rx<File?>(null);
  final Rx<File?> billImageFile = Rx<File?>(null);
  final selectedDate = DateTime.now().obs;
  final showCalculator = false.obs;
  final RxString details = ''.obs;
  final RxString currentInput = '0'.obs;
  final RxString calculationDisplay = ''.obs;
  final RxDouble memory = 0.0.obs;

  final _amountController = TextEditingController(text: '0');
  final _detailsController = TextEditingController();
  final _amountFocus = FocusNode();
  final _detailsFocus = FocusNode();
  TextEditingController get amountController => _amountController;
  TextEditingController get detailsController => _detailsController;
  FocusNode get amountFocus => _amountFocus;
  FocusNode get amountFocusNode => _amountFocus;
  FocusNode get detailsFocus => _detailsFocus;
  FocusNode get detailsFocusNode => _detailsFocus;

  // ───────────── CALCULATOR ─────────────
  final RxString _operator = ''.obs;
  final RxDouble _previous = 0.0.obs;
  String get operator => _operator.value;
  double get previous => _previous.value;

  @override
  void onInit() {
    super.onInit();
    _loadArgs();
    amountFocus.addListener(() => showCalculator.value = amountFocus.hasFocus);
    detailsFocus.addListener(
      () => detailsFocus.hasFocus ? amountFocus.unfocus() : null,
    );
    _detailsController.addListener(() {
      details.value = _detailsController.text;
    });
    _amountController.addListener(() {
      currentInput.value = _amountController.text.isEmpty
          ? '0'
          : _amountController.text;
    });
  }

  void _loadArgs() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      _transactionType.value = args['type']?.toString() ?? 'give';
      _partyId.value = args['partyId']?.toString() ?? '';
      _businessId.value = args['businessId']?.toString() ?? '';
    }

    if (_businessId.value.isEmpty && Get.isRegistered<NavigationController>()) {
      final navController = Get.find<NavigationController>();
      if (navController.businessId.isNotEmpty) {
        _businessId.value = navController.businessId;
      }
    }
  }

  // ───────────── CALCULATOR LOGIC ─────────────
  void number(String n) {
    if (amountController.text == '0') {
      amountController.text = n;
    } else {
      amountController.text += n;
    }
    currentInput.value = amountController.text;
    _updateCalculationDisplay();
  }

  void onNumberPressed(String n) => number(n);

  void decimal() {
    if (!amountController.text.contains('.')) {
      amountController.text += '.';
      currentInput.value = amountController.text;
    }
  }

  void onDecimalPressed() => decimal();

  void setOperator(String op) {
    if (operator.isNotEmpty) {
      equals();
    }
    _previous.value = double.tryParse(amountController.text) ?? 0;
    _operator.value = op;
    amountController.text = '0';
    currentInput.value = '0';
    _updateCalculationDisplay();
  }

  void onOperatorPressed(String op) {
    if (op == '%') {
      final current = double.tryParse(amountController.text) ?? 0;
      final result = current / 100;
      amountController.text = result % 1 == 0
          ? result.toInt().toString()
          : result.toStringAsFixed(2);
      currentInput.value = amountController.text;
      _updateCalculationDisplay();
    } else {
      setOperator(op);
    }
  }

  void equals() {
    if (operator.isEmpty) {
      final current = double.tryParse(amountController.text) ?? 0;
      amountController.text = current % 1 == 0
          ? current.toInt().toString()
          : current.toStringAsFixed(2);
      currentInput.value = amountController.text;
      _updateCalculationDisplay();
      return;
    }

    final current = double.tryParse(amountController.text) ?? 0;
    double result = 0;

    switch (operator) {
      case '+':
        result = previous + current;
        break;
      case '-':
        result = previous - current;
        break;
      case '×':
        result = previous * current;
        break;
      case '÷':
        if (current == 0) {
          amountController.text = 'Error';
          currentInput.value = 'Error';
          calculationDisplay.value = '';
          _operator.value = '';
          _previous.value = 0;
          return;
        }
        result = previous / current;
        break;
      default:
        return;
    }

    amountController.text = result % 1 == 0
        ? result.toInt().toString()
        : result.toStringAsFixed(2);
    currentInput.value = amountController.text;
    calculationDisplay.value = '';
    _operator.value = '';
    _previous.value = 0;
  }

  void onEqualsPressed() => equals();

  void clear() {
    amountController.text = '0';
    currentInput.value = '0';
    _operator.value = '';
    _previous.value = 0;
    _updateCalculationDisplay();
  }

  void onClearPressed() => clear();

  void onBackspacePressed() {
    if (amountController.text.length > 1) {
      amountController.text = amountController.text.substring(
        0,
        amountController.text.length - 1,
      );
    } else {
      amountController.text = '0';
    }
    currentInput.value = amountController.text;
    _updateCalculationDisplay();
  }

  void onMemoryPlus() {
    final current = double.tryParse(amountController.text) ?? 0;
    memory.value = memory.value + current;
    _updateCalculationDisplay();
  }

  void onMemoryMinus() {
    final current = double.tryParse(amountController.text) ?? 0;
    memory.value = memory.value - current;
    _updateCalculationDisplay();
  }

  void _updateCalculationDisplay() {
    if (operator.isNotEmpty && previous != 0) {
      final opSymbol = operator == '×'
          ? '×'
          : operator == '÷'
          ? '÷'
          : operator;
      calculationDisplay.value =
          '${previous % 1 == 0 ? previous.toInt() : previous.toStringAsFixed(2)} $opSymbol';
    } else {
      calculationDisplay.value = '';
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        final status = await Permission.camera.request();
        if (!status.isGranted) return;
      } else {
        final status = await Permission.photos.request();
        if (!status.isGranted) return;
      }

      final img = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (img != null) {
        final file = File(img.path);
        billImage.value = file;
        billImageFile.value = file;
      }
    } catch (e) {}
  }

  Future<void> onAttachBills() async {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () async {
                  Get.back();
                  await pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Get.back();
                  await pickImage(ImageSource.gallery);
                },
              ),
              if (billImageFile.value != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Bill'),
                  onTap: () {
                    Get.back();
                    billImage.value = null;
                    billImageFile.value = null;
                  },
                ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
    );
  }

  Future<void> selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  String getFormattedDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
    );

    if (selected == today) {
      return 'Today';
    } else if (selected == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      const months = [
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
      final month = months[selectedDate.value.month - 1];
      final day = selectedDate.value.day;
      final year = selectedDate.value.year;
      return '$month $day, $year';
    }
  }

  Future<void> save() async {
    final amount = double.tryParse(amountController.text) ?? 0;
    if (amount <= 0) {
      Get.snackbar(
        'Error',
        'Please enter a valid amount',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (businessId.isEmpty) {
      Get.snackbar(
        'Error',
        'Business ID is required. Please select a business first.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (partyId.isEmpty) {
      Get.snackbar(
        'Error',
        'Party ID is required.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await _repo.createTransaction(
        businessId: businessId,
        partyId: partyId,
        amount: amount,
        direction: transactionType == 'give' ? 'gave' : 'got',
        date: selectedDate.value.millisecondsSinceEpoch,
        description: detailsController.text.trim().isEmpty
            ? null
            : detailsController.text.trim(),
        transactionPhotoUrl: billImage.value?.path,
      );
      if (Get.isRegistered<AnalyticsController>()) {
        final analyticsController = Get.find<AnalyticsController>();
        analyticsController.reloadAnalyticsData();
      }

      Get.back(result: {'success': true});
      await Future.delayed(const Duration(milliseconds: 300));
      SnacksBar.showSnackbar(
        title: 'Success',
        message: 'Transaction added successfully',
        type: SnacksBarType.SUCCESS,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save transaction: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> saveTransaction() => save();

  @override
  void onClose() {
    amountController.dispose();
    detailsController.dispose();
    amountFocus.dispose();
    detailsFocus.dispose();
    super.onClose();
  }
}

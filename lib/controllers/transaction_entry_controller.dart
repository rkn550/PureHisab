import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'customer_detail_controller.dart';

class TransactionEntryController extends GetxController {
  // Transaction type: 'give' for "You Gave", 'get' for "You Got"
  final RxString transactionType = 'give'.obs;
  final RxString customerName = ''.obs;
  final RxString customerId = ''.obs;

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

  // Save transaction
  Future<void> saveTransaction() async {
    final amount = getCurrentAmount();
    if (amount <= 0) {
      Get.snackbar('Error', 'Please enter a valid amount');
      return;
    }

    // Create transaction data
    final transactionData = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'date': selectedDate.value,
      'type': transactionType.value,
      'amount': amount,
      'balance': 0.0, // Will be calculated by customer detail controller
      'note': details.value,
    };

    // Save to customer detail controller if available
    try {
      if (Get.isRegistered<CustomerDetailController>()) {
        final customerController = Get.find<CustomerDetailController>();
        // Add transaction to the list
        customerController.transactions.add(transactionData);
        // Recalculate balance and summary
        customerController.calculateSummary();
      }
    } catch (e) {
      // CustomerDetailController not available, continue anyway
    }

    Get.snackbar(
      'Success',
      'Transaction saved successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
    );

    // Navigate back and refresh
    Get.back(
      result: {
        'success': true,
        'amount': amount,
        'type': transactionType.value,
        'details': details.value,
        'date': selectedDate.value,
      },
    );
  }

  // Attach bills
  void onAttachBills() {
    // TODO: Implement image picker for bills
    Get.snackbar('Attach Bills', 'Bill attachment - Coming soon');
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/transaction_entry_controller.dart';

class TransactionEntryScreen extends StatelessWidget {
  const TransactionEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransactionEntryController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: _buildAppBar(controller),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    _buildAmountInput(controller),
                    _buildDetailsInput(controller),
                    _buildDateAndAttachSection(controller, context),
                    _buildSaveButton(controller),
                  ],
                ),
              ),
            ),
          ),
          Obx(
            () => controller.showCalculator.value
                ? _buildCalculatorKeypad(controller)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(TransactionEntryController controller) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Obx(
        () => IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: controller.transactionType.value == 'give'
                ? Colors.red
                : Colors.green,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      title: Obx(
        () => Text(
          controller.transactionType.value == 'give'
              ? 'You gave ₹ ${_formatAmount(controller.getCurrentAmount())} to ${controller.customerName.value}'
              : 'You got ₹ ${_formatAmount(controller.getCurrentAmount())} from ${controller.customerName.value}',
          style: TextStyle(
            color: controller.transactionType.value == 'give'
                ? Colors.red
                : Colors.green,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput(TransactionEntryController controller) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '₹',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller.amountController,
                    focusNode: controller.amountFocusNode,
                    readOnly: true,
                    showCursor: true,
                    enableInteractiveSelection: true,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '0',
                      hintStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    textAlign: TextAlign.left,
                    onChanged: (value) {
                      // Update current input when user types
                      if (value.isEmpty) {
                        controller.currentInput.value = '0';
                      } else {
                        controller.currentInput.value = value;
                      }
                    },
                  ),
                ),
              ],
            ),
            if (controller.calculationDisplay.value.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                controller.calculationDisplay.value,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsInput(TransactionEntryController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller.detailsController,
        focusNode: controller.detailsFocusNode,
        onChanged: (value) => controller.details.value = value,
        decoration: InputDecoration(
          hintText: 'Enter details (Items, bill no., quantity, etc.)',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          border: InputBorder.none,
        ),
        maxLines: 3,
      ),
    );
  }

  Widget _buildDateAndAttachSection(
    TransactionEntryController controller,
    BuildContext context,
  ) {
    return Row(
      children: [
        Expanded(
          child: Obx(
            () => InkWell(
              onTap: () => controller.selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      controller.getFormattedDate(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_drop_down,
                      color: controller.transactionType.value == 'give'
                          ? Colors.red
                          : Colors.green,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Obx(
          () => InkWell(
            onTap: controller.onAttachBills,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.camera_alt,
                    size: 20,
                    color: controller.transactionType.value == 'give'
                        ? Colors.red
                        : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Attach bills',
                    style: TextStyle(
                      fontSize: 14,
                      color: controller.transactionType.value == 'give'
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(TransactionEntryController controller) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: controller.saveTransaction,
          style: ElevatedButton.styleFrom(
            backgroundColor: controller.transactionType.value == 'give'
                ? Colors.red
                : Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'SAVE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalculatorKeypad(TransactionEntryController controller) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCalculatorRow(controller, [
            _CalculatorButton('C', onTap: controller.onClearPressed),
            _CalculatorButton('M+', onTap: controller.onMemoryPlus),
            _CalculatorButton('M-', onTap: controller.onMemoryMinus),
            _CalculatorButton('⌫', onTap: controller.onBackspacePressed),
            _CalculatorButton(
              '÷',
              isOperator: true,
              onTap: () => controller.onOperatorPressed('÷'),
            ),
            _CalculatorButton(
              '%',
              isOperator: true,
              onTap: () => controller.onOperatorPressed('%'),
            ),
          ]),
          _buildCalculatorRow(controller, [
            _CalculatorButton(
              '7',
              onTap: () => controller.onNumberPressed('7'),
            ),
            _CalculatorButton(
              '8',
              onTap: () => controller.onNumberPressed('8'),
            ),
            _CalculatorButton(
              '9',
              onTap: () => controller.onNumberPressed('9'),
            ),
            _CalculatorButton(
              '×',
              isOperator: true,
              onTap: () => controller.onOperatorPressed('×'),
            ),
          ]),
          _buildCalculatorRow(controller, [
            _CalculatorButton(
              '4',
              onTap: () => controller.onNumberPressed('4'),
            ),
            _CalculatorButton(
              '5',
              onTap: () => controller.onNumberPressed('5'),
            ),
            _CalculatorButton(
              '6',
              onTap: () => controller.onNumberPressed('6'),
            ),
            _CalculatorButton(
              '-',
              isOperator: true,
              onTap: () => controller.onOperatorPressed('-'),
            ),
          ]),
          _buildCalculatorRow(controller, [
            _CalculatorButton(
              '1',
              onTap: () => controller.onNumberPressed('1'),
            ),
            _CalculatorButton(
              '2',
              onTap: () => controller.onNumberPressed('2'),
            ),
            _CalculatorButton(
              '3',
              onTap: () => controller.onNumberPressed('3'),
            ),
            _CalculatorButton(
              '+',
              isOperator: true,
              onTap: () => controller.onOperatorPressed('+'),
            ),
          ]),
          _buildCalculatorRow(controller, [
            _CalculatorButton(
              '0',
              onTap: () => controller.onNumberPressed('0'),
            ),
            _CalculatorButton('.', onTap: controller.onDecimalPressed),
            _CalculatorButton(
              '=',
              isEquals: true,
              onTap: controller.onEqualsPressed,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildCalculatorRow(
    TransactionEntryController controller,
    List<_CalculatorButton> buttons,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: buttons
            .map(
              (button) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildCalculatorButton(controller, button),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildCalculatorButton(
    TransactionEntryController controller,
    _CalculatorButton button,
  ) {
    Color? backgroundColor;
    Color textColor = Colors.black87;

    if (button.isEquals) {
      backgroundColor = controller.transactionType.value == 'give'
          ? Colors.red
          : Colors.green;
      textColor = Colors.white;
    } else if (button.isOperator) {
      if (button.label == '×') {
        backgroundColor = Colors.blue.shade100;
      } else if (button.label == '-' || button.label == '+') {
        backgroundColor = Colors.blue.shade300;
      }
    }

    return InkWell(
      onTap: button.onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300, width: 0.5),
        ),
        child: Center(
          child: Text(
            button.label,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    final formatter = amount.toStringAsFixed(0);
    final parts = formatter.split('.');
    final integerPart = parts[0];
    final reversed = integerPart.split('').reversed.join();
    final formatted = reversed.replaceAllMapped(
      RegExp(r'(\d{3})(?=\d)'),
      (match) => '${match.group(0)},',
    );
    return formatted.split('').reversed.join();
  }
}

class _CalculatorButton {
  final String label;
  final VoidCallback onTap;
  final bool isOperator;
  final bool isEquals;

  _CalculatorButton(
    this.label, {
    required this.onTap,
    this.isOperator = false,
    this.isEquals = false,
  });
}

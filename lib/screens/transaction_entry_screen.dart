import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/transaction_entry_controller.dart';
import 'widgets/widgets.dart';

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
            Icons.arrow_back_rounded,
            color: controller.transactionType == 'give'
                ? Colors.red.shade700
                : Colors.green.shade700,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      title: Obx(
        () => Text(
          controller.transactionType == 'give' ? 'You Gave' : 'You Got',
          style: TextStyle(
            color: controller.transactionType == 'give'
                ? Colors.red.shade700
                : Colors.green.shade700,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput(TransactionEntryController controller) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: controller.transactionType == 'give'
                ? [Colors.red.shade50, Colors.red.shade100]
                : [Colors.green.shade50, Colors.green.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color:
                  (controller.transactionType == 'give'
                          ? Colors.red
                          : Colors.green)
                      .withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            GestureDetector(
              onTap: () {
                controller.amountFocusNode.requestFocus();
              },
              child: TextFormField(
                controller: controller.amountController,
                focusNode: controller.amountFocusNode,
                readOnly: true,
                showCursor: true,
                enableInteractiveSelection: true,
                cursorColor: controller.transactionType == 'give'
                    ? Colors.red.shade700
                    : Colors.green.shade700,
                cursorHeight: 32,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: controller.transactionType == 'give'
                      ? Colors.red.shade700
                      : Colors.green.shade700,
                  letterSpacing: 1,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  prefixIcon: Icon(
                    Icons.currency_rupee,
                    color: controller.transactionType == 'give'
                        ? Colors.red.shade700
                        : Colors.green.shade700,
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  border: InputBorder.none,
                  hintText: '0',
                  hintStyle: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color:
                        (controller.transactionType == 'give'
                                ? Colors.red
                                : Colors.green)
                            .withValues(alpha: 0.3),
                  ),
                ),
                textAlign: TextAlign.left,
                onChanged: (value) {
                  if (value.isEmpty) {
                    controller.currentInput.value = '0';
                  } else {
                    controller.currentInput.value = value;
                  }
                },
              ),
            ),

            if (controller.calculationDisplay.value.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const .symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: .circular(8),
                ),
                child: Text(
                  controller.calculationDisplay.value,
                  style: TextStyle(
                    fontSize: 14,
                    color: controller.transactionType == 'give'
                        ? Colors.red.shade700
                        : Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                size: 20,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'Details',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller.detailsController,
            focusNode: controller.detailsFocusNode,
            onChanged: (value) => controller.details.value = value,
            decoration: InputDecoration(
              hintText: 'Enter details (Items, bill no., quantity, etc.)',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            maxLines: 3,
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildDateAndAttachSection(
    TransactionEntryController controller,
    BuildContext context,
  ) {
    return Column(
      children: [
        Row(
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
                          color: controller.transactionType == 'give'
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: controller.billImageFile.value != null
                        ? Border.all(
                            color: controller.transactionType == 'give'
                                ? Colors.red
                                : Colors.green,
                            width: 2,
                          )
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        controller.billImageFile.value != null
                            ? Icons.attach_file
                            : Icons.camera_alt,
                        size: 20,
                        color: controller.transactionType == 'give'
                            ? Colors.red
                            : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        controller.billImageFile.value != null
                            ? 'Bill attached'
                            : 'Attach bills',
                        style: TextStyle(
                          fontSize: 14,
                          color: controller.transactionType == 'give'
                              ? Colors.red
                              : Colors.green,
                          fontWeight: controller.billImageFile.value != null
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Obx(
          () => controller.billImageFile.value != null
              ? Row(
                  mainAxisAlignment: .end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        height: 70,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: controller.transactionType == 'give'
                                ? Colors.red.shade200
                                : Colors.green.shade200,
                            width: 1,
                          ),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                controller.billImageFile.value!,
                                width: double.infinity,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: InkWell(
                                onTap: () {
                                  controller.billImageFile.value = null;
                                  Get.snackbar(
                                    'Success',
                                    'Bill removed',
                                    snackPosition: SnackPosition.BOTTOM,
                                    duration: const Duration(seconds: 2),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildSaveButton(TransactionEntryController controller) {
    return Obx(
      () => PrimaryButton(
        text: 'SAVE',
        onPressed: controller.saveTransaction,
        height: 56,
        fontSize: 18,
        backgroundColor: controller.transactionType == 'give'
            ? Colors.red
            : Colors.green,
        foregroundColor: Colors.white,
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
              '÷',
              isOperator: true,
              onTap: () => controller.onOperatorPressed('÷'),
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
              '×',
              isOperator: true,
              onTap: () => controller.onOperatorPressed('×'),
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
              '-',
              isOperator: true,
              onTap: () => controller.onOperatorPressed('-'),
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
            _CalculatorButton(
              '+',
              isOperator: true,
              onTap: () => controller.onOperatorPressed('+'),
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
    bool isEquals = button.isEquals;
    bool isOperator = button.isOperator;

    if (isEquals) {
      backgroundColor = controller.transactionType == 'give'
          ? Colors.red.shade600
          : Colors.green.shade600;
      textColor = Colors.white;
    } else if (isOperator) {
      if (button.label == '×') {
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade700;
      } else if (button.label == '-' || button.label == '+') {
        backgroundColor = Colors.blue.shade200;
        textColor = Colors.blue.shade800;
      } else if (button.label == '÷') {
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade700;
      }
    } else {
      backgroundColor = Colors.white;
      textColor = Colors.black87;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: button.onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: 56,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isEquals ? Colors.transparent : Colors.grey.shade200,
              width: 1,
            ),
            boxShadow: isEquals
                ? [
                    BoxShadow(
                      color:
                          (controller.transactionType == 'give'
                                  ? Colors.red
                                  : Colors.green)
                              .withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              button.label,
              style: TextStyle(
                fontSize: 22,
                fontWeight: isEquals || isOperator
                    ? FontWeight.bold
                    : FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
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

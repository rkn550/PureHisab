import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/add_party_controller.dart';
import '../app/utils/app_colors.dart';
import 'widgets/widgets.dart';

class AddPartyScreen extends StatelessWidget {
  const AddPartyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddPartyController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text('Add Party', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            padding: .all(16),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                // Party Name
                CustomTextField(
                  controller: controller.partyNameController,
                  label: 'Party name',
                  hintText: 'Enter party name',
                  validator: controller.validatePartyName,
                  borderRadius: 8,
                  focusedBorderColor: AppColors.primary,
                  enabledBorderColor: AppColors.primary,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: .circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: .center,
                        children: [
                          const Text('🇮🇳', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 4),
                          const Text('+91'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomTextField(
                        controller: controller.mobileController,
                        label: 'Mobile Number',
                        hintText: 'Enter mobile number',
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: controller.validateMobile,
                        borderRadius: 8,
                        focusedBorderColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Obx(
                  () => Row(
                    children: [
                      const Text(
                        'Who are they?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: .w500,
                        ),
                      ),
                      Expanded(
                        child: _buildRadioOption(
                          controller,
                          'Customer',
                          controller.partyType.value == 'Customer',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildRadioOption(
                          controller,
                          'Supplier',
                          controller.partyType.value == 'Supplier',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // GSTIN & Address Toggle
                Obx(
                  () => controller.showGstinAddress.value
                      ? _buildGstinAddressSection(controller)
                      : InkWell(
                          onTap: () => controller.toggleGstinAddress(),
                          child: Text(
                            'ADD ADDRESS (OPTIONAL)',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: .w500,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 32),
                // Add Button
                Obx(
                  () => PrimaryButton(
                    text: 'ADD ${controller.partyType.value.toUpperCase()}',
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.addParty(),
                    isLoading: controller.isLoading.value,
                    height: 50,
                    fontSize: 16,
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRadioOption(
    AddPartyController controller,
    String label,
    bool isSelected,
  ) {
    return Row(
      mainAxisAlignment: .center,
      children: [
        IconButton(
          onPressed: () => controller.togglePartyType(label),
          icon: Icon(
            isSelected
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            size: 18,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? .w600 : .normal,
            color: isSelected ? AppColors.primary : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildGstinAddressSection(AddPartyController controller) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        InkWell(
          onTap: () => controller.toggleGstinAddress(),
          child: Text(
            'ADD ADDRESS (OPTIONAL)',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: .w500,
            ),
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: controller.addressController,
          label: 'Address',
          hintText: 'Enter address',
          borderRadius: 8,
          focusedBorderColor: AppColors.primary,
          minLines: 3,
          maxLines: 5,
        ),
      ],
    );
  }
}

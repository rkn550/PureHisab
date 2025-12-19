import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/add_party_controller.dart';
import '../app/utils/app_colors.dart';

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
                TextFormField(
                  controller: controller.partyNameController,
                  decoration: InputDecoration(
                    labelText: 'Party name',
                    labelStyle: TextStyle(color: Colors.grey.shade600),
                    border: OutlineInputBorder(
                      borderRadius: .circular(8),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: .circular(8),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: .circular(8),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: .symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  style: const TextStyle(fontSize: 16),
                  validator: controller.validatePartyName,
                  autofocus: true,
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
                      child: TextFormField(
                        controller: controller.mobileController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          hintText: 'Enter mobile number',

                          labelText: 'Mobile Number',
                          labelStyle: TextStyle(color: Colors.grey.shade600),
                          border: OutlineInputBorder(
                            borderRadius: .circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: .circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: .circular(8),
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: .symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        style: const TextStyle(fontSize: 16),
                        validator: controller.validateMobile,
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
                  () => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () {
                              controller.addParty();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: .symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: .circular(8),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'ADD ${controller.partyType.value.toUpperCase()}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: .bold,
                              ),
                            ),
                    ),
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
        TextFormField(
          controller: controller.addressController,
          minLines: 3,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: 'Address',
            labelStyle: TextStyle(color: Colors.grey.shade600),
            border: OutlineInputBorder(
              borderRadius: .circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: .circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: .circular(8),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            hintText: 'Enter address',
            contentPadding: .symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}

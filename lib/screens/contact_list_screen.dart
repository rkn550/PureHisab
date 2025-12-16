import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/utils/app_colors.dart';
import '../app/routes/app_pages.dart';
import '../controllers/contact_list_controller.dart';

class ContactListScreen extends StatelessWidget {
  const ContactListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ContactListController>();

    // Get party type from arguments
    final args = Get.arguments;
    final partyType = args != null && args is Map<String, dynamic>
        ? (args['partyType'] as int? ?? 0)
        : 0;
    final isCustomer = partyType == 0;
    final title = isCustomer
        ? 'Add Customer from Contacts'
        : 'Add Supplier from Contacts';

    // Listen to permission dialog state and show dialog when needed
    ever(controller.showPermissionDialog, (bool show) {
      if (show) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showPermissionDialog(controller, isCustomer);
        });
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white)),
      ),
      body: _buildBody(controller, isCustomer),
    );
  }

  Widget _buildBody(ContactListController controller, bool isCustomer) {
    return Column(
      children: [
        // Search bar
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Obx(
            () => TextField(
              controller: controller.searchTextController,
              onChanged: controller.updateSearchQuery,
              decoration: InputDecoration(
                hintText: isCustomer
                    ? 'Search customer name'
                    : 'Search supplier name',
                hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.grey.shade600, size: 20),
                suffixIcon: controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                        onPressed: () {
                          controller.searchTextController.clear();
                          controller.updateSearchQuery('');
                        },
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ),
        // Add Customer option
        InkWell(
          onTap: () {
            Get.back();
            Get.toNamed(Routes.addParty, arguments: Get.arguments);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: Icon(Icons.add, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  isCustomer ? 'Add Customer' : 'Add Supplier',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                Icon(Icons.chevron_right, color: AppColors.primary),
              ],
            ),
          ),
        ),
        const Divider(),
        // Contact list
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!controller.hasPermission.value) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.contacts_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Permission denied',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please grant contacts permission',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Check if we have contacts but search returned empty
            if (controller.filteredContacts.isEmpty) {
              if (controller.hasContacts &&
                  controller.searchQuery.value.isNotEmpty) {
                // Search returned no results
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No contacts found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try a different search term',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                // No contacts at all
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.contacts_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No contacts found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your contacts list is empty',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }
            }

            return ListView.builder(
              itemCount: controller.filteredContacts.length,
              itemBuilder: (context, index) {
                final contact = controller.filteredContacts[index];
                final name = contact.displayName;
                final number = controller.getContactNumber(contact);
                final initials = controller.getContactInitials(contact);

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 24,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    name.isEmpty ? 'Unknown' : name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    number,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  onTap: () {
                    // Navigate to add party with contact details
                    // Clean phone number before passing (remove non-digits)
                    final cleanedNumber = controller.getCleanedPhoneNumber(
                      contact,
                    );
                    // Preserve party type from original arguments
                    final originalArgs = Get.arguments ?? <String, dynamic>{};
                    Get.toNamed(
                      Routes.addParty,
                      arguments: {
                        'partyType':
                            originalArgs['partyType'] ??
                            0, // Preserve party type
                        'contactName': name.isEmpty ? '' : name,
                        'contactNumber': cleanedNumber,
                      },
                    );
                  },
                );
              },
            );
          }),
        ),
      ],
    );
  }

  void _showPermissionDialog(
    ContactListController controller,
    bool isCustomer,
  ) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.contacts, size: 64, color: AppColors.primary),
              const SizedBox(height: 16),
              const Text(
                'Allow Khatabook to access your contacts?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Get.back();
                        controller.showPermissionDialog.value = false;
                        // Navigate to add party form
                        final args = Get.arguments;
                        Get.back();
                        Get.toNamed(Routes.addParty, arguments: args);
                      },
                      child: const Text(
                        'Don\'t Allow',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        controller.showPermissionDialog.value = false;
                        await controller.requestPermission();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Allow',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}

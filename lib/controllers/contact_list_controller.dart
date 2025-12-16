import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../app/utils/app_colors.dart';

class ContactListController extends GetxController {
  final RxList<Contact> contacts = <Contact>[].obs;
  final RxList<Contact> filteredContacts = <Contact>[].obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;
  final RxBool hasPermission = false.obs;
  final RxBool showPermissionDialog = false.obs;
  final searchTextController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Delay to ensure screen is visible before showing dialog
    Future.delayed(const Duration(milliseconds: 300), () {
      checkAndRequestPermission();
    });

    // Listen to search query changes
    ever(searchQuery, (_) => filterContacts());

    // Sync controller with search query
    searchTextController.addListener(() {
      if (searchTextController.text != searchQuery.value) {
        updateSearchQuery(searchTextController.text);
      }
    });
  }

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }

  Future<void> checkAndRequestPermission() async {
    try {
      isLoading.value = true;

      // Check permission
      final status = await Permission.contacts.status;

      if (status.isGranted) {
        // Permission already granted - load contacts
        await loadContacts();
      } else if (status.isDenied) {
        // Permission not granted - show permission dialog
        hasPermission.value = false;
        isLoading.value = false;
        showPermissionDialog.value = true;
      } else if (status.isPermanentlyDenied) {
        // Permission permanently denied - show settings dialog
        hasPermission.value = false;
        isLoading.value = false;
        showPermissionDialog.value = true;
      } else {
        // Request permission
        final newStatus = await Permission.contacts.request();
        if (newStatus.isGranted) {
          await loadContacts();
        } else {
          hasPermission.value = false;
          isLoading.value = false;
          showPermissionDialog.value = true;
        }
      }
    } catch (e) {
      // Error logged silently
      hasPermission.value = false;
      isLoading.value = false;
    }
  }

  Future<void> loadContacts() async {
    try {
      isLoading.value = true;

      // Request full access to read contacts
      if (await FlutterContacts.requestPermission()) {
        hasPermission.value = true;
        showPermissionDialog.value = false;

        // Fetch all contacts
        final allContacts = await FlutterContacts.getContacts(
          withProperties: true,
          withThumbnail: false,
        );

        // Sort contacts by name
        allContacts.sort((a, b) {
          final nameA = a.displayName.toLowerCase();
          final nameB = b.displayName.toLowerCase();
          return nameA.compareTo(nameB);
        });

        contacts.value = allContacts;
        filteredContacts.value = allContacts;
      } else {
        hasPermission.value = false;
        showPermissionDialog.value = true;
      }
    } catch (e) {
      // Error logged silently
      hasPermission.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> requestPermission() async {
    final status = await Permission.contacts.request();
    if (status.isGranted) {
      await loadContacts();
    } else if (status.isPermanentlyDenied) {
      // Show settings dialog
      showPermissionDialog.value = false;
      _showSettingsDialog();
    } else {
      // Permission denied - navigate to add party form
      final args = Get.arguments;
      Get.back();
      Get.toNamed('/add-party', arguments: args);
    }
  }

  void _showSettingsDialog() {
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
              Icon(Icons.settings, size: 64, color: AppColors.primary),
              const SizedBox(height: 16),
              const Text(
                'Permission Required',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please enable contacts permission in Settings to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Get.back();
                        final args = Get.arguments;
                        Get.back();
                        Get.toNamed('/add-party', arguments: args);
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        await openAppSettings();
                        // Check permission again after user returns
                        Future.delayed(const Duration(seconds: 1), () {
                          checkAndRequestPermission();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Settings',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void filterContacts() {
    if (searchQuery.value.isEmpty) {
      filteredContacts.value = contacts;
    } else {
      final query = searchQuery.value.toLowerCase().trim();
      filteredContacts.value = contacts.where((contact) {
        final name = contact.displayName.toLowerCase();
        final phones = contact.phones
            .map((p) => p.number.toLowerCase())
            .join(' ');
        return name.contains(query) || phones.contains(query);
      }).toList();
    }
  }

  // Check if we have contacts but search returned empty
  bool get hasContacts => contacts.isNotEmpty;
  bool get hasSearchResults => filteredContacts.isNotEmpty;

  String getContactNumber(Contact contact) {
    if (contact.phones.isEmpty) return 'No number';
    return contact.phones.first.number;
  }

  // Get cleaned phone number (digits only) for form submission
  String getCleanedPhoneNumber(Contact contact) {
    if (contact.phones.isEmpty) return '';
    // Remove all non-digit characters
    final cleaned = contact.phones.first.number.replaceAll(
      RegExp(r'[^\d]'),
      '',
    );
    // Remove country code if present (e.g., +91)
    if (cleaned.length > 10 && cleaned.startsWith('91')) {
      return cleaned.substring(2);
    }
    return cleaned;
  }

  String getContactInitials(Contact contact) {
    final name = contact.displayName.trim();
    if (name.isEmpty) return '?';

    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();

    if (parts.length >= 2) {
      final first = parts[0];
      final second = parts[1];
      if (first.isNotEmpty && second.isNotEmpty) {
        return (first[0] + second[0]).toUpperCase();
      }
    }

    if (name.length >= 2) {
      return name.substring(0, 2).toUpperCase();
    }

    return name[0].toUpperCase();
  }
}

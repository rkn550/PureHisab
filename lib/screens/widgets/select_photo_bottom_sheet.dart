import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/utils/app_colors.dart';

class SelectPhotoBottomSheet extends StatelessWidget {
  final bool hasPhoto;
  final VoidCallback onTakePhoto;
  final VoidCallback onChooseFromGallery;
  final VoidCallback? onRemovePhoto;

  const SelectPhotoBottomSheet({
    super.key,
    required this.hasPhoto,
    required this.onTakePhoto,
    required this.onChooseFromGallery,
    this.onRemovePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                'Select Photo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.primaryDark),
              title: const Text('Take Photo'),
              onTap: () {
                Get.back();
                onTakePhoto();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.primaryDark),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Get.back();
                onChooseFromGallery();
              },
            ),
            if (hasPhoto && onRemovePhoto != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo'),
                onTap: () {
                  Get.back();
                  onRemovePhoto!();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

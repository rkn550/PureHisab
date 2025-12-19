import 'package:flutter/material.dart';
import 'dart:io';
import '../../app/utils/app_colors.dart';

class AvatarWidget extends StatelessWidget {
  final String? imagePath;
  final String? name;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? fallbackIcon;

  const AvatarWidget({
    super.key,
    this.imagePath,
    this.name,
    this.size = 40,
    this.backgroundColor,
    this.textColor,
    this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.primary;
    final txtColor = textColor ?? Colors.white;

    if (imagePath != null && imagePath!.isNotEmpty) {
      final file = File(imagePath!);
      if (file.existsSync()) {
        return CircleAvatar(
          radius: size / 2,
          backgroundImage: FileImage(file),
          backgroundColor: bgColor,
        );
      }
    }

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: bgColor,
      child: name != null && name!.isNotEmpty
          ? Text(
              name![0].toUpperCase(),
              style: TextStyle(
                color: txtColor,
                fontSize: size * 0.5,
                fontWeight: FontWeight.bold,
              ),
            )
          : Icon(
              fallbackIcon ?? Icons.person,
              color: txtColor,
              size: size * 0.6,
            ),
    );
  }
}

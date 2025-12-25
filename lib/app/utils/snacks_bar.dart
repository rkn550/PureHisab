import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SnacksBarType { SUCCESS, ERROR, WARNING, INFO, CUSTOM }

class SnacksBar {
  static void showSnackbar({
    required String title,
    required String message,
    required SnacksBarType type,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: type == SnacksBarType.SUCCESS
          ? Colors.green.shade50
          : type == SnacksBarType.ERROR
          ? Colors.red.shade50
          : type == SnacksBarType.WARNING
          ? Colors.yellow.shade50
          : type == SnacksBarType.INFO
          ? Colors.blue.shade50
          : type == SnacksBarType.CUSTOM
          ? Colors.grey.shade50
          : Colors.grey.shade50,
      colorText: type == SnacksBarType.SUCCESS
          ? Colors.green.shade900
          : type == SnacksBarType.ERROR
          ? Colors.red.shade900
          : type == SnacksBarType.WARNING
          ? Colors.yellow.shade900
          : type == SnacksBarType.INFO
          ? Colors.blue.shade900
          : type == SnacksBarType.CUSTOM
          ? Colors.grey.shade900
          : Colors.grey.shade900,
      duration: Duration(
        seconds: type == SnacksBarType.SUCCESS
            ? 2
            : type == SnacksBarType.ERROR
            ? 3
            : type == SnacksBarType.WARNING
            ? 4
            : type == SnacksBarType.INFO
            ? 5
            : type == SnacksBarType.CUSTOM
            ? 6
            : 3,
      ),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }
}

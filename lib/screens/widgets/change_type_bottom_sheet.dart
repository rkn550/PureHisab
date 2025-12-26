import 'package:flutter/material.dart';
import '../../app/utils/app_colors.dart';

class ChangeTypeBottomSheet extends StatelessWidget {
  final String partyName;
  final String partyPhoneNumber;
  final String partyType;
  final String? photoUrl;
  final VoidCallback onConfirm;

  const ChangeTypeBottomSheet({
    super.key,
    required this.partyName,
    required this.partyPhoneNumber,
    required this.partyType,
    required this.photoUrl,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final newType = partyType == 'customer' ? 'supplier' : 'customer';
    final currentType = partyType == 'customer' ? 'customer' : 'supplier';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.only(
        left: 28,
        right: 28,
        top: 28,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Change $partyName to $newType?',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    partyName.isNotEmpty ? partyName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partyName,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      partyPhoneNumber.isNotEmpty
                          ? partyPhoneNumber
                          : 'No phone number',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'All entries of $partyName will be safely transferred from $currentType to $newType section',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'CHANGE',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../app/utils/app_colors.dart';

class ResendTimer extends StatelessWidget {
  final bool canResend;
  final int timer;
  final VoidCallback? onResend;
  final String? prefixText;
  final String? resendText;
  final String? waitText;

  const ResendTimer({
    super.key,
    required this.canResend,
    required this.timer,
    this.onResend,
    this.prefixText,
    this.resendText,
    this.waitText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (prefixText != null)
          Text(
            prefixText!,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        if (canResend)
          TextButton(
            onPressed: onResend,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              resendText ?? 'Resend Code',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          )
        else
          Text(
            waitText != null
                ? '$waitText $timer${timer == 1 ? '' : 's'}'
                : 'Resend in ${timer}s',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }
}

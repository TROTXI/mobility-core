import 'package:flutter/material.dart';
import 'package:trotxi_commuter/core/auth/password_policy.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';

/// Shared, live feedback for every new-password form.
class PasswordRequirements extends StatelessWidget {
  const PasswordRequirements({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password requirements',
            style: AppTypography.caption.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              for (final requirement in passwordRequirements(password))
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      requirement.met
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 16,
                      color: requirement.met
                          ? colors.actionPrimaryDefault
                          : colors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      requirement.label,
                      style: AppTypography.caption.copyWith(
                        color: requirement.met
                            ? colors.actionPrimaryDefault
                            : colors.textSecondary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

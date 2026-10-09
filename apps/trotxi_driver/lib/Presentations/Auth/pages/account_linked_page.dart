import 'package:flutter/material.dart';
import 'package:trotxi_driver/Presentations/Auth/widgets/auth_layout.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/data/driver_auth_repository.dart';

/// Acknowledges the device link before opening assigned work (design page 05).
class AccountLinkedPage extends StatelessWidget {
  const AccountLinkedPage({
    super.key,
    required this.session,
    required this.onContinue,
    this.showDeviceSetup = true,
  });

  final DriverSession session;
  final VoidCallback onContinue;

  /// False when location is already allowed: the next screen is today's work,
  /// so there is no device setup to preview.
  final bool showDeviceSetup;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final code = session.driverCode;
    return AuthLayout(
      hero: AuthStatusMark(color: colors.success, icon: Icons.check_rounded),
      title: 'Account linked',
      subtitle:
          'This device can now access ${session.fullName}\u2019s assigned Trotxi trips.',
      footer: [
        FilledButton(
          style: authPrimaryButton(colors),
          onPressed: onContinue,
          child: const AuthButtonLabel('Continue'),
        ),
        AuthCaption(
          showDeviceSetup
              ? 'You can review camera and location access later in Profile & settings.'
              : 'You can review device permissions in Profile & settings.',
        ),
      ],
      children: [
        AuthCard(
          padding: const EdgeInsets.all(AppSpacing.space16),
          child: AuthIdentity(
            name: session.fullName,
            detail: code == null
                ? 'Verified driver account'
                : 'Driver ID \u00b7 $code',
          ),
        ),
        if (showDeviceSetup) ...[
          const SizedBox(height: AppSpacing.space24),
          Text(
            'NEXT: DEVICE SETUP',
            textAlign: TextAlign.center,
            style: AppTypography.chipLabel.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.space8),
          AuthCard(
            raised: true,
            padding: const EdgeInsets.all(AppSpacing.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Allow the tools used during a trip',
                  style: AppTypography.authRowTitle.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.space8),
                const _Bullet('Location for live navigation'),
                const _Bullet('Camera for passenger QR codes'),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space4),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.action,
            ),
          ),
          const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: Text(
              text,
              style: AppTypography.authRowDetail.copyWith(
                fontSize: 13,
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

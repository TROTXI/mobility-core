import 'package:flutter/material.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/core/widgets/trotxi_wordmark.dart';
import 'package:trotxi_driver/data/driver_auth_repository.dart';

/// Acknowledges the device link before opening assigned work (design page 05).
class AccountLinkedPage extends StatelessWidget {
  const AccountLinkedPage({
    super.key,
    required this.session,
    required this.onContinue,
  });

  final DriverSession session;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth >= 800
                      ? AppSpacing.space40
                      : AppSpacing.space20,
                  vertical: AppSpacing.space24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: TrotxiWordmark(height: 42)),
                    const SizedBox(height: AppSpacing.space32),
                    Center(
                      child: Container(
                        width: 84,
                        height: 84,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.success.withValues(alpha: 0.1),
                          border: Border.all(color: colors.success, width: 2),
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 46,
                          color: colors.success,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space20),
                    Text(
                      'Account linked',
                      textAlign: TextAlign.center,
                      style: AppTypography.screenTitle.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    Text(
                      'This device can now access ${session.fullName}’s assigned Trotxi trips.',
                      textAlign: TextAlign.center,
                      style: AppTypography.screenContext.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space24),
                    _IdentityCard(session: session),
                    const SizedBox(height: AppSpacing.space24),
                    Text(
                      'NEXT: DEVICE READINESS',
                      style: AppTypography.chipLabel.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space8),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.space16),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        border: Border.all(color: colors.border),
                        borderRadius: AppRadii.circular(AppRadii.xl),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Allow the tools used during a trip',
                            style: AppTypography.tileLabel.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space12),
                          const _ReadinessLine(
                            icon: Icons.location_on_outlined,
                            text: 'Location for live navigation',
                          ),
                          const _ReadinessLine(
                            icon: Icons.qr_code_scanner,
                            text: 'Camera for passenger QR codes',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space24),
                    FilledButton(
                      onPressed: onContinue,
                      child: const Text('Continue'),
                    ),
                    const SizedBox(height: AppSpacing.space12),
                    Text(
                      'You can review camera and location access later in Profile & settings. Permission prompts appear only when you ask for them.',
                      textAlign: TextAlign.center,
                      style: AppTypography.footnote.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.session});

  final DriverSession session;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final code = session.driverCode;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: colors.surfaceSelected,
        border: Border.all(color: colors.border),
        borderRadius: AppRadii.circular(AppRadii.xl),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: colors.surfaceStrong,
            child: Text(
              _initials(session.fullName),
              style: AppTypography.title.copyWith(color: colors.textPrimary),
            ),
          ),
          const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.fullName,
                  style: AppTypography.title.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  code == null
                      ? 'Verified driver account'
                      : 'Driver ID · $code',
                  style: AppTypography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadinessLine extends StatelessWidget {
  const _ReadinessLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colors.info),
          const SizedBox(width: AppSpacing.space8),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _initials(String fullName) {
  final parts = fullName
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.characters.first.toUpperCase();
  return (parts.first.characters.first + parts.last.characters.first)
      .toUpperCase();
}

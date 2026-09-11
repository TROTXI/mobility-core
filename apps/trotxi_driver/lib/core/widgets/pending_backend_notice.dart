import 'package:flutter/material.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';

/// Marks a screen whose layout is built but whose API does not exist yet.
///
/// Every skeleton in this app says so, in the app, where it cannot be missed.
/// The alternative is a screen that looks finished, takes a tap, and does
/// nothing — which is how a half-built feature reaches a driver at a roadside
/// and fails silently at the worst possible moment.
///
/// Each one names the endpoint it is waiting on, so the backend work and the
/// screen that needs it stay tied together.
class PendingBackendNotice extends StatelessWidget {
  const PendingBackendNotice({super.key, required this.waitingOn});

  /// What has to exist before this screen works, in plain terms.
  final String waitingOn;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.space16),
      padding: const EdgeInsets.all(AppSpacing.space12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.circular(AppRadii.md),
        border: Border.all(color: colors.warning),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.construction_outlined, size: 18, color: colors.warning),
          const SizedBox(width: AppSpacing.space8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Not connected yet',
                  style: AppTypography.label.copyWith(color: colors.warning),
                ),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  'This screen is built but does nothing yet. Waiting on $waitingOn.',
                  style: AppTypography.bodySmall.copyWith(
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

/// A tappable row used across the skeleton hubs.
class SkeletonTile extends StatelessWidget {
  const SkeletonTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.tone,
  });

  final String title;
  final String subtitle;

  /// The count chip the frames put on the right ("3 OPEN", "2 PENDING").
  final String? trailing;
  final VoidCallback? onTap;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.circular(AppRadii.lg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.label.copyWith(
                      color: tone ?? colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space8,
                  vertical: AppSpacing.space4,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceSelected,
                  borderRadius: AppRadii.circular(AppRadii.full),
                ),
                child: Text(
                  trailing!,
                  style: AppTypography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
            if (onTap != null)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.space8),
                child: Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: colors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The card the skeleton screens group tiles into.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.space16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.circular(AppRadii.lg),
      ),
      child: Column(children: children),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/data/trips_repository.dart';

/// One rider on the manifest: photo, name, and whether they are aboard.
///
/// The photo is the point. The manifest is the "photo pass" fallback, so a
/// driver can match a face to a seat when a code will not scan, which is why a
/// rider without one still renders with initials rather than being hidden.
class RiderRow extends StatelessWidget {
  const RiderRow({super.key, required this.rider, this.onTap});

  final ManifestRider rider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final name = rider.name?.trim().isNotEmpty == true ? rider.name!.trim() : 'Unnamed rider';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.circular(AppRadii.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space12,
            vertical: AppSpacing.space12,
          ),
          child: Row(
            children: [
              _Avatar(url: rider.avatarUrl, name: name, colors: colors),
              const SizedBox(width: AppSpacing.space12),
              Expanded(
                child: Text(
                  name,
                  style: AppTypography.body.copyWith(color: colors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (rider.boarded)
                _StatusPill(label: 'Boarded', color: colors.success, colors: colors)
              else
                _StatusPill(label: 'Waiting', color: colors.textSecondary, colors: colors),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.name, required this.colors});

  final String? url;
  final String name;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surfaceSelected,
        borderRadius: AppRadii.circular(AppRadii.full),
      ),
      child: url == null
          ? Text(_initials(name), style: AppTypography.label.copyWith(color: colors.textPrimary))
          : Image.network(
              url!,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              // A photo that will not load must not blank the row: the seat is
              // still taken and the driver still has to account for it.
              errorBuilder: (_, _, _) => Text(
                _initials(name),
                style: AppTypography.label.copyWith(color: colors.textPrimary),
              ),
            ),
    );
  }

  static String _initials(String name) {
    final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first).toUpperCase();
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color, required this.colors});

  final String label;
  final Color color;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: AppSpacing.space4,
      ),
      decoration: BoxDecoration(
        borderRadius: AppRadii.circular(AppRadii.full),
        border: Border.all(color: color),
      ),
      child: Text(label, style: AppTypography.caption.copyWith(color: color)),
    );
  }
}

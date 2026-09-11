import 'package:flutter/material.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/data/trips_repository.dart';

/// One rider on the manifest.
///
/// The pill on the right is an ACTION, not a label. That is the file's rule
/// made concrete: "status and next action must remain glanceable". A driver
/// scanning the list is looking for who still needs boarding, and a row that
/// only reports state makes them find the person, then find the button.
class RiderRow extends StatelessWidget {
  const RiderRow({super.key, required this.rider, this.onAction, this.onTap});

  final ManifestRider rider;

  /// Fired by the pill. Null renders it as a plain state chip, which is what a
  /// boarded rider gets: there is nothing left to do to them.
  final VoidCallback? onAction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final name = rider.name?.trim().isNotEmpty == true ? rider.name!.trim() : 'Unnamed rider';

    return InkWell(
      onTap: onTap,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: AppTypography.label.copyWith(color: colors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _subtitle(rider),
                    style: AppTypography.caption.copyWith(color: colors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.space8),
            _ActionPill(rider: rider, onAction: onAction, colors: colors),
          ],
        ),
      ),
    );
  }

  /// "Morning · boarded" or "Morning · reserved", as the frame writes it, with
  /// a missing photo called out because that is what sends a driver to the
  /// code instead of the face.
  static String _subtitle(ManifestRider rider) {
    final when = rider.direction == 'evening' ? 'Evening' : 'Morning';
    if (rider.boarded) return '$when · boarded';
    if (rider.avatarUrl == null) return '$when · no photo';
    return '$when · reserved';
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({required this.rider, required this.onAction, required this.colors});

  final ManifestRider rider;
  final VoidCallback? onAction;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final boarded = rider.boarded;
    final background = boarded ? colors.success : colors.action;
    final label = boarded ? 'BOARDED' : 'BOARD';

    final pill = Container(
      constraints: const BoxConstraints(minWidth: 84, minHeight: 36),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space12,
        vertical: AppSpacing.space8,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadii.circular(AppRadii.full),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(color: colors.onAction),
      ),
    );

    if (boarded || onAction == null) {
      return Semantics(label: '$label, no action available', child: pill);
    }
    return Semantics(
      button: true,
      label: 'Board ${rider.name ?? 'rider'}',
      child: InkWell(
        onTap: onAction,
        borderRadius: AppRadii.circular(AppRadii.full),
        child: pill,
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.name, required this.colors});

  final String? url;
  final String name;
  final AppColors colors;

  /// A stable colour per person, so the same rider keeps the same disc all
  /// shift and a driver can find them by shape before reading the name.
  Color get _tint {
    const palette = [0xFF147A3B, 0xFF1769AA, 0xFFB76512, 0xFFB42318, 0xFF5B7896];
    return Color(palette[name.hashCode.abs() % palette.length]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: _tint, shape: BoxShape.circle),
      child: url == null
          ? Text(_initials(name), style: AppTypography.label.copyWith(color: Colors.white))
          : Image.network(
              url!,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              // A photo that will not load must not blank the row: the seat is
              // still taken and the driver still has to account for it.
              errorBuilder: (_, _, _) =>
                  Text(_initials(name), style: AppTypography.label.copyWith(color: Colors.white)),
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

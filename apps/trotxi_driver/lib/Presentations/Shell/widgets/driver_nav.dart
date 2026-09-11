import 'package:flutter/material.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';

/// The five places a driver can be.
enum DriverTab { today, trip, scan, manifest, me }

/// The floating bottom bar from the frames.
///
/// A bar rather than a stack of pushed screens, because Trip, Scan and Manifest
/// are not steps in a sequence: a driver moves between them repeatedly at a
/// single stop, and making that a back-button journey costs taps at exactly the
/// moment there is a queue at the door.
///
/// Trip and Scan are disabled with no run under way. They are drawn rather than
/// hidden so the bar never changes shape mid-shift, which is what lets a driver
/// hit a target without looking.
class DriverNav extends StatelessWidget {
  const DriverNav({
    super.key,
    required this.current,
    required this.onSelect,
    this.hasActiveRun = false,
    this.tripHasAlert = false,
  });

  final DriverTab current;
  final ValueChanged<DriverTab> onSelect;

  /// Whether a run is open. Gates the run-scoped tabs.
  final bool hasActiveRun;

  /// The dot the frames put beside Trip when the run needs attention.
  final bool tripHasAlert;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.space12),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space8,
          vertical: AppSpacing.space8,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadii.circular(AppRadii.full),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _Item(
              tab: DriverTab.today,
              icon: Icons.home_outlined,
              label: 'Today',
              current: current,
              onSelect: onSelect,
              colors: colors,
            ),
            _Item(
              tab: DriverTab.trip,
              icon: Icons.route_outlined,
              label: 'Trip',
              current: current,
              onSelect: onSelect,
              colors: colors,
              enabled: hasActiveRun,
              alert: tripHasAlert,
            ),
            _Item(
              tab: DriverTab.scan,
              icon: Icons.qr_code_scanner,
              label: 'Scan',
              current: current,
              onSelect: onSelect,
              colors: colors,
              enabled: hasActiveRun,
            ),
            _Item(
              tab: DriverTab.manifest,
              icon: Icons.list_alt_outlined,
              label: 'Manifest',
              current: current,
              onSelect: onSelect,
              colors: colors,
              enabled: hasActiveRun,
            ),
            _Item(
              tab: DriverTab.me,
              icon: Icons.person_outline,
              label: 'Me',
              current: current,
              onSelect: onSelect,
              colors: colors,
            ),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.tab,
    required this.icon,
    required this.label,
    required this.current,
    required this.onSelect,
    required this.colors,
    this.enabled = true,
    this.alert = false,
  });

  final DriverTab tab;
  final IconData icon;
  final String label;
  final DriverTab current;
  final ValueChanged<DriverTab> onSelect;
  final AppColors colors;
  final bool enabled;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    final selected = tab == current;
    final tone = !enabled
        ? colors.textSecondary.withValues(alpha: 0.4)
        : selected
        ? colors.textPrimary
        : colors.textSecondary;

    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        enabled: enabled,
        child: InkWell(
          onTap: enabled ? () => onSelect(tab) : null,
          borderRadius: AppRadii.circular(AppRadii.full),
          child: Container(
            // 56dp-class target, per the file's "touch under motion" rule:
            // these are hit on a windscreen mount by someone not looking.
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
            decoration: BoxDecoration(
              color: selected ? colors.surfaceSelected : Colors.transparent,
              borderRadius: AppRadii.circular(AppRadii.full),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(icon, size: 22, color: tone),
                    if (alert && enabled)
                      Positioned(
                        right: -4,
                        top: -2,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colors.info,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  label,
                  style: AppTypography.caption.copyWith(color: tone),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

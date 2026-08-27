import 'package:flutter/material.dart';
import 'package:trotxi_commuter/Presentations/Home/models/home_ride_lifecycle_state.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_radii.dart';
import 'package:trotxi_commuter/core/config/theme/app_shadows.dart';
import 'package:trotxi_commuter/core/config/theme/app_spacing.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';
import 'package:trotxi_commuter/core/config/theme/minimum_touch_target.dart';

/// Icon set for each destination, split into outlined (default) and
/// filled/rounded (selected) variants so the nav reflects state the same
/// way Material 3 navigation bars do.
IconData _outlinedIconFor(CommuterDestination destination) {
  return switch (destination) {
    CommuterDestination.home => Icons.home_outlined,
    CommuterDestination.trips => Icons.directions_bus_outlined,
    CommuterDestination.wallet => Icons.account_balance_wallet_outlined,
    CommuterDestination.profile => Icons.person_outline_rounded,
  };
}

IconData _filledIconFor(CommuterDestination destination) {
  return switch (destination) {
    CommuterDestination.home => Icons.home_rounded,
    CommuterDestination.trips => Icons.directions_bus_rounded,
    CommuterDestination.wallet => Icons.account_balance_wallet_rounded,
    CommuterDestination.profile => Icons.person_rounded,
  };
}

String _labelFor(CommuterDestination destination) {
  return switch (destination) {
    CommuterDestination.home => 'Home',
    CommuterDestination.trips => 'Trips',
    CommuterDestination.wallet => 'Wallet',
    CommuterDestination.profile => 'Profile',
  };
}

class CommuterBottomNavigation extends StatelessWidget {
  const CommuterBottomNavigation({
    super.key,
    required this.selected,
    required this.onDestinationSelected,
    required this.onSearch,
    required this.isTabletPortrait,
  });

  final CommuterDestination selected;
  final ValueChanged<CommuterDestination>? onDestinationSelected;
  final VoidCallback? onSearch;
  final bool isTabletPortrait;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space16,
        AppSpacing.space8,
        AppSpacing.space16,
        AppSpacing.space12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Container(
              key: ValueKey(
                isTabletPortrait
                    ? 'home-navigation-tablet-portrait'
                    : 'home-navigation-phone',
              ),
              constraints: BoxConstraints(
                maxWidth: isTabletPortrait ? 640 : 560,
                minHeight: 64,
              ),
              padding: const EdgeInsets.all(AppSpacing.space4),
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: AppRadii.circular(AppRadii.full),
                border: Border.all(color: colors.borderSubtle),
                boxShadow: AppShadows.elevation3,
              ),
              child: Row(
                children: CommuterDestination.values
                    .map(
                      (destination) => Expanded(
                        child: _DestinationButton(
                          destination: destination,
                          selected: destination == selected,
                          onPressed: onDestinationSelected == null
                              ? null
                              : () => onDestinationSelected!(destination),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.space12),
          CommuterSearchAction(onPressed: onSearch),
        ],
      ),
    );
  }
}

/// Canonical 390 x 844 phone dock from Figma component set 2552:158.
///
/// The dock deliberately owns no surrounding padding: the phone Home shell
/// positions this 366 x 64 surface at x=12, y=772 as a floating overlay.
class CommuterPhoneDock extends StatelessWidget {
  const CommuterPhoneDock({
    super.key,
    required this.selected,
    required this.onDestinationSelected,
    required this.onSearch,
  });

  final CommuterDestination selected;
  final ValueChanged<CommuterDestination>? onDestinationSelected;
  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final capsule = isDark
        ? AppPrimitiveColors.homeDarkNavigation
        : Colors.white;
    final border = isDark
        ? AppPrimitiveColors.homeDarkNavigationBorder
        : const Color(0xFFDDE4E0);
    final inactive = isDark ? const Color(0xFFAAB3AD) : const Color(0xFF68736C);
    final icon = isDark ? Colors.white : const Color(0xFF061421);

    return SizedBox(
      key: const ValueKey('home-navigation-phone'),
      width: 366,
      height: 64,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 300,
            height: 64,
            decoration: BoxDecoration(
              color: capsule,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: border),
              boxShadow: isDark
                  ? null
                  : const [
                      BoxShadow(
                        color: Color(0x1F000000),
                        offset: Offset(0, 8),
                        blurRadius: 24,
                      ),
                    ],
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: SizedBox(
              width: 300,
              height: 64,
              child: Row(
                children: CommuterDestination.values
                    .map(
                      (destination) => _PhoneDestinationButton(
                        destination: destination,
                        selected: destination == selected,
                        inactiveColor: inactive,
                        onPressed: onDestinationSelected == null
                            ? null
                            : () => onDestinationSelected!(destination),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          Positioned(
            left: 308,
            top: 3,
            child: _PhoneSearchAction(
              color: capsule,
              border: border,
              iconColor: icon,
              showShadow: !isDark,
              onPressed: onSearch,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoneDestinationButton extends StatelessWidget {
  const _PhoneDestinationButton({
    required this.destination,
    required this.selected,
    required this.inactiveColor,
    required this.onPressed,
  });

  final CommuterDestination destination;
  final bool selected;
  final Color inactiveColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final label = _labelFor(destination);
    final foreground = selected ? Colors.white : inactiveColor;

    return Semantics(
      button: true,
      selected: selected,
      enabled: onPressed != null,
      label: label,
      onTap: onPressed,
      child: ExcludeSemantics(
        child: SizedBox(
          width: 75,
          height: 64,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(32),
              child: Stack(
                children: [
                  if (selected)
                    Positioned(
                      left: 4,
                      top: 4,
                      child: Container(
                        width: 67,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppPrimitiveColors.homeGreen,
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                    ),
                  Positioned(
                    left: 25.5,
                    top: 7,
                    child: Icon(
                      selected
                          ? _filledIconFor(destination)
                          : _outlinedIconFor(destination),
                      size: 24,
                      color: foreground,
                    ),
                  ),
                  Positioned(
                    left: 2,
                    top: 36,
                    child: SizedBox(
                      width: 71,
                      height: 16,
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          color: foreground,
                          fontSize: 9,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          height: 12 / 9,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhoneSearchAction extends StatelessWidget {
  const _PhoneSearchAction({
    required this.color,
    required this.border,
    required this.iconColor,
    required this.showShadow,
    required this.onPressed,
  });

  final Color color;
  final Color border;
  final Color iconColor;
  final bool showShadow;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: 'Search',
      onTap: onPressed,
      child: ExcludeSemantics(
        child: Material(
          color: color,
          shape: CircleBorder(side: BorderSide(color: border)),
          elevation: showShadow ? 4 : 0,
          shadowColor: const Color(0x2E061421),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: SizedBox.square(
              dimension: 58,
              child: Icon(Icons.search_rounded, color: iconColor, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}

class CommuterLandscapeRail extends StatelessWidget {
  const CommuterLandscapeRail({
    super.key,
    required this.selected,
    required this.onDestinationSelected,
  });

  final CommuterDestination selected;
  final ValueChanged<CommuterDestination>? onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      key: const ValueKey('home-navigation-tablet-landscape'),
      width: 72,
      margin: const EdgeInsets.fromLTRB(14, 14, 12, 20),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space12,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: AppRadii.circular(AppRadii.xl),
        border: Border.all(color: colors.borderSubtle),
        boxShadow: AppShadows.elevation2,
      ),
      child: Column(
        children: [
          Semantics(
            label: 'Trotxi',
            image: true,
            child: ExcludeSemantics(
              child: Image.asset(
                'assets/TrotxiLogo.png',
                width: 42,
                height: 42,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space20),
          ...CommuterDestination.values.map(
            (destination) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space20),
              child: _DestinationButton(
                destination: destination,
                selected: destination == selected,
                compact: true,
                onPressed: onDestinationSelected == null
                    ? null
                    : () => onDestinationSelected!(destination),
              ),
            ),
          ),
          const Spacer(),
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppPrimitiveColors.trotxiGreen,
              shape: BoxShape.circle,
            ),
            child: Text(
              'K',
              style: AppTypography.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CommuterSearchAction extends StatelessWidget {
  const CommuterSearchAction({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: 'Search',
      onTap: onPressed,
      child: ExcludeSemantics(
        child: MinimumTouchTarget(
          minimumSize: const Size.square(56),
          child: Material(
            color: colors.surfaceElevated,
            shape: CircleBorder(side: BorderSide(color: colors.borderSubtle)),
            elevation: 4,
            shadowColor: AppPrimitiveColors.navy900.withValues(alpha: 0.18),
            child: InkWell(
              onTap: onPressed,
              customBorder: const CircleBorder(),
              child: SizedBox.square(
                dimension: 56,
                child: Icon(
                  Icons.search_rounded,
                  color: colors.iconDefault,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DestinationButton extends StatelessWidget {
  const _DestinationButton({
    required this.destination,
    required this.selected,
    required this.onPressed,
    this.compact = false,
  });

  final CommuterDestination destination;
  final bool selected;
  final VoidCallback? onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final foreground = selected ? Colors.white : colors.iconSubtle;
    final label = _labelFor(destination);

    return Semantics(
      button: true,
      selected: selected,
      enabled: onPressed != null,
      label: label,
      onTap: onPressed,
      child: ExcludeSemantics(
        child: MinimumTouchTarget(
          minimumSize: Size(compact ? 56 : 44, compact ? 64 : 56),
          child: Material(
            color: selected ? colors.actionPrimaryDefault : Colors.transparent,
            borderRadius: AppRadii.circular(AppRadii.full),
            child: InkWell(
              onTap: onPressed,
              borderRadius: AppRadii.circular(AppRadii.full),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? AppSpacing.space4 : AppSpacing.space8,
                  vertical: AppSpacing.space8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      selected
                          ? _filledIconFor(destination)
                          : _outlinedIconFor(destination),
                      size: 24,
                      color: foreground,
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: AppTypography.caption.copyWith(
                        color: foreground,
                        fontSize: compact ? 9 : 10,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
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

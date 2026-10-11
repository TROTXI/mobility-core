import 'package:flutter/material.dart';
import 'package:trotxi_commuter/Features/Home/models/home_ride_lifecycle_state.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';
import 'package:trotxi_commuter/core/widgets/figma_commuter_icon.dart';

/// Four persistent destinations and a separate search action. Labels wrap
/// and the dock grows with text scaling rather than clipping enlarged text.
class CommuterNavigation extends StatelessWidget {
  const CommuterNavigation({
    super.key,
    required this.selected,
    required this.onDestinationSelected,
    this.onSearch,
  });
  final CommuterDestination selected;
  final ValueChanged<CommuterDestination> onDestinationSelected;
  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? AppPrimitiveColors.homeDarkNavigation : Colors.white;
    final border = dark
        ? AppPrimitiveColors.homeDarkNavigationBorder
        : const Color(0xFFDDE4E0);
    final muted = dark ? const Color(0xFFAAB3AD) : const Color(0xFF68736C);
    final selectedFill = dark
        ? AppPrimitiveColors.homeGreen
        : const Color(0xFF067647);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(32),
      side: BorderSide(color: border),
    );
    const labels = ['Home', 'Trips', 'Wallet', 'Profile'];
    const icons = [
      CommuterIcon.home,
      CommuterIcon.trips,
      CommuterIcon.wallet,
      CommuterIcon.profile,
    ];
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Row(
            key: const ValueKey('home-navigation-phone'),
            children: [
              Expanded(
                child: Material(
                  color: surface,
                  shape: shape,
                  elevation: 6,
                  shadowColor: Colors.black.withValues(alpha: dark ? .28 : .12),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: List.generate(4, (i) {
                          final active = i == selected.index;
                          final ink = active ? Colors.white : muted;
                          return Expanded(
                            child: Semantics(
                              selected: active,
                              button: true,
                              label: labels[i],
                              child: Tooltip(
                                message: labels[i],
                                child: Material(
                                  color: active
                                      ? selectedFill
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(28),
                                  child: InkWell(
                                    key: ValueKey(
                                      'dock-${labels[i].toLowerCase()}',
                                    ),
                                    borderRadius: BorderRadius.circular(28),
                                    onTap: () => onDestinationSelected(
                                      CommuterDestination.values[i],
                                    ),
                                    child: ExcludeSemantics(
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          minHeight: 56,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 2,
                                            vertical: 6,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              FigmaCommuterIcon(
                                                icons[i],
                                                color: ink,
                                                cutout: active
                                                    ? selectedFill
                                                    : surface,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                labels[i],
                                                textAlign: TextAlign.center,
                                                style: AppTypography.caption
                                                    .copyWith(
                                                      fontSize: 11,
                                                      height: 1.2,
                                                      color: ink,
                                                      fontWeight: active
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
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: surface,
                shape: CircleBorder(side: BorderSide(color: border)),
                elevation: 6,
                shadowColor: Colors.black.withValues(alpha: .12),
                child: IconButton(
                  key: const ValueKey('dock-search'),
                  tooltip: 'Search routes and stops',
                  onPressed: onSearch,
                  constraints: const BoxConstraints.tightFor(
                    width: 58,
                    height: 58,
                  ),
                  icon: FigmaCommuterIcon(
                    CommuterIcon.search,
                    color: colors.iconDefault,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

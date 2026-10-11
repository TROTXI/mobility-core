import 'package:flutter/material.dart';
import 'package:trotxi_commuter/Features/Home/models/home_ride_lifecycle_state.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';

/// Four persistent destinations. Search lives in the header, not a fifth tab.
class CommuterNavigation extends StatelessWidget {
  const CommuterNavigation({
    super.key,
    required this.selected,
    required this.onDestinationSelected,
  });
  final CommuterDestination selected;
  final ValueChanged<CommuterDestination> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.borderSubtle)),
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: colors.surfaceElevated,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          indicatorColor: colors.backgroundSubtle,
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
              size: 23,
              color: states.contains(WidgetState.selected)
                  ? colors.actionPrimaryDefault
                  : colors.iconSubtle,
            ),
          ),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => AppTypography.caption.copyWith(
              color: states.contains(WidgetState.selected)
                  ? colors.actionPrimaryDefault
                  : colors.textSecondary,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w600
                  : FontWeight.w400,
            ),
          ),
        ),
        child: NavigationBar(
          key: const ValueKey('home-navigation-phone'),
          selectedIndex: selected.index,
          onDestinationSelected: (index) =>
              onDestinationSelected(CommuterDestination.values[index]),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.directions_bus_outlined),
              label: 'Trips',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              label: 'Wallet',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

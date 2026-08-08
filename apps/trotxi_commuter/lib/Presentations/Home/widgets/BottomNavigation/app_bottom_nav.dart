import 'package:flutter/material.dart';
import 'package:trotxi_commuter/Presentations/Home/widgets/BottomNavigation/nav_destination.dart';
import 'package:trotxi_commuter/Presentations/Home/widgets/BottomNavigation/nav_item.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<NavDestination> items;
  final ValueChanged<int> onTap;
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.navborder)),
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: NavItem(
                icon: item.iconPath,
                label: item.label,
                selected: currentIndex == index,
                onTap: () => onTap(index),
              ),
            ),
          );
        }),
      ),
    );
  }
}

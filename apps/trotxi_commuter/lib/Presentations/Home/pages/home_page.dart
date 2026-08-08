import 'package:flutter/material.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/Presentations/Home/widgets/BottomNavigation/app_bottom_nav.dart';
import 'package:trotxi_commuter/Presentations/Home/widgets/BottomNavigation/nav_destination.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.client});
  final TrotxiApiClient client;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<NavDestination> _items = [
    NavDestination(label: 'Home', iconPath: Icons.home, route: '/home'),
    NavDestination(
      label: 'Routes',
      iconPath: Icons.directions,
      route: '/routes',
    ),
    NavDestination(
      label: 'Pass',
      iconPath: Icons.card_membership,
      route: '/pass',
    ),
    NavDestination(label: 'Wallet', iconPath: Icons.wallet, route: '/wallet'),
    NavDestination(label: 'Profile', iconPath: Icons.person, route: '/profile'),
  ];

  // Replace these with your actual page widgets
  final List<Widget> _pages = const [
    Center(child: Text('Welcome to Trotxi')), // Home
    Center(child: Text('Routes Page')),
    Center(child: Text('Pass Page')),
    Center(child: Text('Wallet Page')),
    Center(child: Text('Profile Page')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        items: _items,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}

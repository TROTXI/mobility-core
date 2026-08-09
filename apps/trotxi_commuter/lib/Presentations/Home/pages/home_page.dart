import 'package:flutter/material.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/Presentations/Home/widgets/BottomNavigation/app_bottom_nav.dart';
import 'package:trotxi_commuter/Presentations/Home/widgets/BottomNavigation/nav_destination.dart';
import 'package:trotxi_commuter/Presentations/Home/widgets/Navbar/navbar.dart';
import 'package:trotxi_commuter/core/Tokens/token_storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.client});
  final TrotxiApiClient client;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  MeGet200Response? _userData;
  bool _loadingUser = true;
  String? _userError;

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

  final List<Widget> _pages = const [
    Center(child: Text('Welcome to Trotxi')),
    Center(child: Text('Routes Page')),
    Center(child: Text('Pass Page')),
    Center(child: Text('Wallet Page')),
    Center(child: Text('Profile Page')),
  ];

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    try {
      final token = await TokenStorage.instance.getAccessToken();

      if (token == null) {
        setState(() {
          _userError = 'Not authenticated';
          _loadingUser = false;
        });
        return;
      }

      final response = await widget.client.getAuthApi().meGet(
        headers: {'Authorization': 'Bearer $token'},
      );

      setState(() {
        _userData = response.data;
        _loadingUser = false;
      });
    } catch (e) {
      setState(() {
        _userError = e.toString();
        _loadingUser = false;
      });
      debugPrint('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingUser) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_userError != null || _userData == null) {
      return Scaffold(
        body: Center(
          child: Text('Failed to load user: ${_userError ?? "unknown error"}'),
        ),
      );
    }

    return Scaffold(
      appBar: Navbar(userData: _userData!, userName: _userData!.displayName),
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

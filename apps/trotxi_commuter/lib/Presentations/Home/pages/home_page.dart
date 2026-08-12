import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/Presentations/Home/widgets/BottomNavigation/app_bottom_nav.dart';
import 'package:trotxi_commuter/Presentations/Home/widgets/BottomNavigation/nav_destination.dart';
import 'package:trotxi_commuter/Presentations/Home/widgets/Navbar/navbar.dart';
import 'package:trotxi_commuter/Presentations/Onboarding/pages/onboard_page.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';

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
  TrotxiException? _activeError;

  final List<NavDestination> _items = [
    NavDestination(label: 'Home', iconPath: Icons.home_filled, route: '/home'),
    NavDestination(
      label: 'Routes',
      iconPath: Icons.bus_alert_outlined,
      route: '/routes',
    ),
    NavDestination(
      label: 'Pass',
      iconPath: Icons.qr_code_scanner,
      route: '/pass',
    ),
    NavDestination(
      label: 'Wallet',
      iconPath: Icons.account_balance_wallet_outlined,
      route: '/wallet',
    ),
    NavDestination(
      label: 'Profile',
      iconPath: Icons.person_outline_rounded,
      route: '/profile',
    ),
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

  /// Safely extracts custom [TrotxiException] from Dio wrappers
  TrotxiException _parseError(Object e) {
    if (e is DioException && e.error is TrotxiException) {
      return e.error as TrotxiException;
    }
    if (e is TrotxiException) {
      return e;
    }
    return ApiException(0, e.toString());
  }

  Future<void> _fetchCurrentUser() async {
    setState(() {
      _loadingUser = true;
      _activeError = null;
    });

    try {
      final response = await widget.client.getAuthApi().meGet();

      if (!mounted) return;
      setState(() {
        _userData = response.data;
        _loadingUser = false;
      });
    } catch (e) {
      if (!mounted) return;
      final parsedError = _parseError(e);

      setState(() {
        _activeError = parsedError;
        _loadingUser = false;
      });

      debugPrint('Error fetching user data: $parsedError');
    }
  }

  void _handleUnauthorized() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => OnBoardPage(client: widget.client),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingUser) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_activeError is OfflineException) {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  size: 64,
                  color: AppColors.textsecondary,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No Connection',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _activeError!.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textsecondary),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _fetchCurrentUser,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 3. Session Expired / Unauthorized State
    if (_activeError is UnauthorizedException) {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_clock_outlined,
                  size: 64,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Session Expired',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _activeError!.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textsecondary),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleUnauthorized,
                    child: const Text('Go to Login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 4. Rate Limit (429) State
    if (_activeError is RateLimitException) {
      final rateErr = _activeError as RateLimitException;
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.speed_rounded,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Too Many Requests',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${rateErr.message} Please wait ${rateErr.retryAfter.inSeconds}s.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textsecondary),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _fetchCurrentUser,
                  child: const Text('Retry Again Later'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_userData == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Something went wrong.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchCurrentUser,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // 5. Success State
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

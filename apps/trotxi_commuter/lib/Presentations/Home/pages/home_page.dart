import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/Presentations/Home/models/home_ride_lifecycle_state.dart';
import 'package:trotxi_commuter/Presentations/Home/widgets/BottomNavigation/commuter_navigation.dart';
import 'package:trotxi_commuter/Presentations/Home/widgets/Navbar/navbar.dart';
import 'package:trotxi_commuter/Presentations/Home/widgets/Tabs/home_tab.dart';
import 'package:trotxi_commuter/Presentations/Home/widgets/Tabs/pass_tab.dart';
import 'package:trotxi_commuter/Presentations/Home/widgets/Tabs/profile_tab.dart';
import 'package:trotxi_commuter/Presentations/Home/widgets/Tabs/routes_tab.dart';
import 'package:trotxi_commuter/Presentations/Home/widgets/Tabs/wallet_tab.dart';
import 'package:trotxi_commuter/Presentations/Onboarding/pages/onboard_page.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';

/// An [IndexedStack] replacement that only builds a child the first time
/// its index becomes active, instead of building all children up front.
///
/// Once a child has been built it stays mounted (like a normal
/// [IndexedStack]), so switching tabs away and back preserves its state
/// (including any data it has already fetched) without needing
/// [AutomaticKeepAliveClientMixin].
class LazyIndexedStack extends StatefulWidget {
  const LazyIndexedStack({
    super.key,
    required this.index,
    required this.children,
  });

  final int index;
  final List<Widget> children;

  @override
  State<LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<LazyIndexedStack> {
  final Set<int> _builtIndices = {};

  @override
  void initState() {
    super.initState();
    _builtIndices.add(widget.index);
  }

  @override
  void didUpdateWidget(covariant LazyIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    _builtIndices.add(widget.index);
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.index,
      children: List.generate(widget.children.length, (i) {
        return _builtIndices.contains(i)
            ? widget.children[i]
            : const SizedBox.shrink();
      }),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.client});
  final TrotxiApiClient client;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Pages are indexed in the same order as CommuterDestination.values:
  // 0 = home, 1 = trips, 2 = wallet, 3 = profile.
  CommuterDestination _selected = CommuterDestination.home;

  MeGet200Response? _userData;
  bool _loadingUser = true;
  TrotxiException? _activeError;

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

  void _goToDestination(CommuterDestination destination) {
    setState(() => _selected = destination);
  }

  /// Pass is no longer a persistent bottom-nav tab (CommuterDestination has
  /// no slot for it), so it's opened as a pushed screen instead.
  void _showBoardingPass() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => PassTab(client: widget.client)),
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
              const Text('Something went wrong.'),
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

    // 5. Success State — _userData is guaranteed non-null past this point,
    // so it's safe to build tabs that require it (HomeTab).
    final userData = _userData!;

    // Order matches CommuterDestination.values: home, trips, wallet, profile.
    final pages = [
      HomeTab(
        client: widget.client,
        userData: userData,
        onShowBoardingPass: _showBoardingPass,
      ),
      RoutesTab(client: widget.client),
      WalletTab(client: widget.client),
      ProfileTab(client: widget.client),
    ];

    return Scaffold(
      appBar: Navbar(userData: userData, userName: userData.displayName),
      body: LazyIndexedStack(index: _selected.index, children: pages),
      bottomNavigationBar: CommuterBottomNavigation(
        selected: _selected,
        onDestinationSelected: _goToDestination,
        onSearch: null,
        isTabletPortrait: false,
      ),
    );
  }
}

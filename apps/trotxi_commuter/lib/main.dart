import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trotxi_commuter/Features/Onboarding/pages/splash_page.dart';
import 'package:trotxi_commuter/core/Tokens/token_storage.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme_controller.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/firebase_options.dart';
import 'package:trotxi_commuter/firebase_performance.dart';

const String _apiBaseUrl = 'https://trotxi-api-staging.onrender.com';

final trotxiClientProvider = Provider<TrotxiApiClient>((ref) {
  throw UnimplementedError(
    'trotxiClientProvider has no default  override it in main() with '
    'trotxiClientProvider.overrideWithValue(client) before runApp().',
  );
});

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Catch Flutter framework errors (widget build errors, layout errors, etc.)
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };

      // Catch errors outside Flutter's error handling (async errors, isolate errors)
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      final client = TrotxiClientFactory.create(
        baseUrl: _apiBaseUrl,
        tokenStore: TokenStorage.instance,
      );
      client.dio.interceptors.add(PerformanceInterceptor());
      //await TokenStorage.instance.clearTokens();

      runApp(
        ProviderScope(
          overrides: [trotxiClientProvider.overrideWithValue(client)],
          child: TrotxiCommuterApp(client: client),
        ),
      );
    },
    (error, stack) {
      // Catches anything thrown outside the zone above (belt-and-suspenders)
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    },
  );
}

class TrotxiCommuterApp extends StatefulWidget {
  const TrotxiCommuterApp({super.key, required this.client});

  final TrotxiApiClient client;

  @override
  State<TrotxiCommuterApp> createState() => _TrotxiCommuterAppState();
}

class _TrotxiCommuterAppState extends State<TrotxiCommuterApp> {
  final _themeController = AppThemeController();

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // AppThemeControllerScope makes the controller reachable from anywhere
    // in the tree (e.g. the dark-mode toggle in ProfileTab); the
    // AnimatedBuilder re-renders MaterialApp itself whenever it changes,
    // since an InheritedWidget update alone wouldn't re-run this build.
    return AppThemeControllerScope(
      controller: _themeController,
      child: AnimatedBuilder(
        animation: _themeController,
        builder: (context, _) => MaterialApp(
          title: 'Trotxi Commuter',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _themeController.themeMode,
          home: SplashPage(client: widget.client),
        ),
      ),
    );
  }
}

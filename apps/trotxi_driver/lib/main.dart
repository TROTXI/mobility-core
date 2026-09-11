import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:trotxi_driver/core/Tokens/token_storage.dart';
import 'package:trotxi_driver/core/config/theme/app_theme.dart';
import 'package:trotxi_driver/core/config/theme/app_theme_controller.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/Presentations/Auth/pages/auth_gate.dart';
import 'package:trotxi_driver/Presentations/Today/pages/today_page.dart';
import 'package:trotxi_driver/core/state/session_controller.dart';
import 'package:trotxi_driver/core/state/today_controller.dart';
import 'package:trotxi_driver/data/driver_auth_repository.dart';
import 'package:trotxi_driver/data/trips_repository.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_driver/firebase_options.dart';
import 'package:trotxi_driver/firebase_performance.dart';

const _apiBaseUrl = String.fromEnvironment('API_BASE_URL');

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
      runApp(TrotxiDriverApp(client: client));
    },
    (error, stack) {
      // Catches anything thrown outside the zone above (belt-and-suspenders)
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    },
  );
}

class TrotxiDriverApp extends StatefulWidget {
  const TrotxiDriverApp({super.key, required this.client});

  final TrotxiApiClient client;

  @override
  State<TrotxiDriverApp> createState() => _TrotxiDriverAppState();
}

class _TrotxiDriverAppState extends State<TrotxiDriverApp> {
  late final DriverAuthRepository _auth = DriverAuthRepository(
    client: widget.client,
    tokenStore: TokenStorage.instance,
  );
  late final TripsRepository _trips = TripsRepository(client: widget.client);

  @override
  Widget build(BuildContext context) {
    // Composition root (ADR-0016): repositories and controllers are built once
    // here and read from context, rather than threaded through constructors
    // down every screen that happens to sit between the two.
    return MultiProvider(
      providers: [
        // The raw client, for the position publisher, which is created per run
        // screen rather than held app-wide.
        Provider<TrotxiApiClient>.value(value: widget.client),
        Provider<DriverAuthRepository>.value(value: _auth),
        Provider<TripsRepository>.value(value: _trips),
        // Follows the device by default. The prototype puts a Theme control on
        // Profile > App preferences, which drives this; dark is the one that
        // matters in practice, since these screens are read before dawn and
        // after dusk on a windscreen-mounted phone.
        ChangeNotifierProvider(create: (_) => AppThemeController()),
        ChangeNotifierProvider(create: (_) => SessionController(auth: _auth)),
        ChangeNotifierProvider(create: (_) => TodayController(trips: _trips)),
      ],
      child: Consumer<AppThemeController>(
        builder: (context, theme, _) => MaterialApp(
          title: 'Trotxi Driver',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: theme.themeMode,
          home: AuthGate(home: (context) => const TodayPage()),
        ),
      ),
    );
  }
}

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
import 'package:trotxi_driver/Presentations/Shell/pages/driver_shell.dart';
import 'package:trotxi_driver/core/state/config_controller.dart';
import 'package:trotxi_driver/core/state/session_controller.dart';
import 'package:trotxi_driver/core/state/today_controller.dart';
import 'package:trotxi_driver/data/config_repository.dart';
import 'package:trotxi_driver/data/driver_auth_repository.dart';
import 'package:trotxi_driver/data/incidents_repository.dart';
import 'package:trotxi_driver/data/route_map_repository.dart';
import 'package:trotxi_driver/data/trips_repository.dart';
import 'package:trotxi_driver/data/work_repository.dart';
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
  late final ConfigRepository _config = ConfigRepository(client: widget.client);
  late final IncidentsRepository _incidents = IncidentsRepository(
    client: widget.client,
  );
  late final WorkRepository _work = WorkRepository(client: widget.client);
  late final RouteMapRepository _maps = RouteMapRepository(
    client: widget.client,
  );
  late final SessionController _session = SessionController(auth: _auth);

  @override
  void initState() {
    super.initState();
    // A session revoked server-side now returns the app to sign-in on its own
    // (#235). The store is cleared only after a refresh has genuinely failed,
    // so this reacts to a proven 401 and never to a bad connection.
    TokenStorage.instance.onCleared = _session.onSessionRevoked;
  }

  @override
  void dispose() {
    TokenStorage.instance.onCleared = null;
    super.dispose();
  }

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
        Provider<ConfigRepository>.value(value: _config),
        Provider<IncidentsRepository>.value(value: _incidents),
        Provider<WorkRepository>.value(value: _work),
        Provider<RouteMapRepository>.value(value: _maps),
        // Fetched at start, not per screen: GET /flags answers before sign-in,
        // and the screen that needs the operations number most is the one a
        // driver reaches when they cannot get in (#234).
        ChangeNotifierProvider(
          create: (_) => ConfigController(config: _config)..load(),
        ),
        // Follows the device by default. The prototype puts a Theme control on
        // Profile > App preferences, which drives this; dark is the one that
        // matters in practice, since these screens are read before dawn and
        // after dusk on a windscreen-mounted phone.
        ChangeNotifierProvider(create: (_) => AppThemeController()),
        ChangeNotifierProvider.value(value: _session),
        ChangeNotifierProvider(create: (_) => TodayController(trips: _trips)),
      ],
      child: Consumer<AppThemeController>(
        builder: (context, theme, _) => MaterialApp(
          title: 'Trotxi Driver',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: theme.themeMode,
          home: AuthGate(home: (context) => const DriverShell()),
        ),
      ),
    );
  }
}

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
import 'package:trotxi_driver/core/state/driver_notifications.dart';
import 'package:trotxi_driver/core/state/driver_location_controller.dart';
import 'package:trotxi_driver/data/position_publisher.dart';
import 'package:trotxi_driver/data/position_queue.dart';
import 'package:trotxi_driver/data/config_repository.dart';
import 'package:trotxi_driver/data/driver_auth_repository.dart';
import 'package:trotxi_driver/data/incidents_repository.dart';
import 'package:trotxi_driver/data/route_map_repository.dart';
import 'package:trotxi_driver/data/trips_repository.dart';
import 'package:trotxi_driver/data/work_repository.dart';
import 'package:trotxi_driver/core/api/driver_api.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:trotxi_driver/firebase_options.dart';
import 'package:trotxi_driver/firebase_performance.dart';

const _apiBaseUrl = String.fromEnvironment('API_BASE_URL');
const _apiRealm = String.fromEnvironment('API_SESSION_REALM');

Future<void> main() async {
  var launched = false;
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      // An explicitly selected replacement database is mandatory. Never fall
      // back to staging or reuse the old unscoped session on a bad build.
      final tokens = TokenStorage(baseUrl: _apiBaseUrl, realm: _apiRealm);
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

      final package = await PackageInfo.fromPlatform();
      final platform = switch (defaultTargetPlatform) {
        TargetPlatform.iOS => 'ios',
        TargetPlatform.android => 'android',
        _ => throw UnsupportedError('The driver app requires iOS or Android.'),
      };
      final metadata = wire.ClientMetadata(
        app: 'driver',
        build: int.parse(package.buildNumber),
        platform: platform,
      );
      final transport = wire.TrotxiClientFactory.create(
        baseUrl: _apiBaseUrl,
        tokenStore: tokens,
        metadata: metadata,
      );
      final client = DriverApi(
        client: transport,
        store: tokens,
        metadata: metadata,
      );
      client.dio.interceptors.add(PerformanceInterceptor());
      runApp(TrotxiDriverApp(client: client));
      launched = true;
    },
    (error, stack) {
      // Catches anything thrown outside the zone above (belt-and-suspenders)
      if (Firebase.apps.isNotEmpty) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      }
      if (launched) return;
      runApp(
        const MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'The driver app could not start. Check that this build has a replacement API URL and session realm, or contact operations.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class TrotxiDriverApp extends StatefulWidget {
  const TrotxiDriverApp({super.key, required this.client});

  final DriverApi client;

  @override
  State<TrotxiDriverApp> createState() => _TrotxiDriverAppState();
}

class _TrotxiDriverAppState extends State<TrotxiDriverApp> {
  late final DriverAuthRepository _auth = DriverAuthRepository(
    client: widget.client,
    tokenStore: widget.client.store,
  );
  late final TripsRepository _trips = TripsRepository(
    client: widget.client,
    beginLifecycleChange: () => _location.captureRunObserver(),
    beforeComplete: (id) => _positions.flushBeforeComplete(id),
    completionFailed: () => _positions.resumeAfterCompletionFailure(),
  );
  late final PositionPublisher _positions = PositionPublisher(
    client: widget.client,
    queue: PositionQueue(
      storage: widget.client.store.storage,
      key: '${widget.client.store.scope.storageKey}.gps-queue',
    ),
  );
  late final DriverLocationController _location = DriverLocationController(
    trips: _trips,
    publisher: _positions,
  );
  late final ConfigRepository _config = ConfigRepository(client: widget.client);
  late final IncidentsRepository _incidents = IncidentsRepository(
    client: widget.client,
  );
  late final WorkRepository _work = WorkRepository(client: widget.client);
  late final RouteMapRepository _maps = RouteMapRepository(
    client: widget.client,
  );
  late final SessionController _session = SessionController(auth: _auth);
  late final TodayController _today = TodayController(trips: _trips);
  late final DriverNotifications _notifications = DriverNotifications(
    api: widget.client,
    refresh: _today.load,
  );
  int? _sessionGeneration;
  String? _gpsOwner;
  Future<void> _gpsBinding = Future.value();
  int _locationRevision = 0;
  final _navigator = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _notifications.start();
    // A session revoked server-side now returns the app to sign-in on its own
    // (#235). Automatic clearing requires a refresh endpoint 401, not a
    // timeout/server error or a failed retry after a successful refresh.
    widget.client.store.onCleared = _session.onSessionRevoked;
    _session.addListener(_syncLocationSession);
    widget.client.upgradeRequired.addListener(_syncLocationSession);
    _syncLocationSession();
  }

  Future<void> _syncLocationSession() async {
    final revision = ++_locationRevision;
    if (_sessionGeneration != widget.client.store.generation) {
      final hadSession = _sessionGeneration != null;
      _sessionGeneration = widget.client.store.generation;
      _today.reset();
      if (hadSession) {
        // Pushed manifest/scan/profile routes must not outlive their identity.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _navigator.currentState?.popUntil((route) => route.isFirst);
          }
        });
      }
    }
    final owner = _session.session?.accountId;
    _notifications.setOwner(
      _session.stage == SessionStage.ready ? owner : null,
    );
    final ready =
        _session.stage == SessionStage.ready &&
        owner != null &&
        !widget.client.upgradeRequired.value;
    if (!ready) _location.setSessionReady(false);
    if (owner != _gpsOwner || _session.stage == SessionStage.signedOut) {
      _location.setSessionReady(false);
      _gpsOwner = owner;
      _gpsBinding = _gpsBinding
          .then<void>((_) {}, onError: (Object _, StackTrace _) {})
          .then((_) => _positions.bindOwner(owner));
    }
    try {
      // Re-entrant session notifications must also await the same binding.
      await _gpsBinding;
    } catch (_) {
      if (revision == _locationRevision) _gpsOwner = null;
      return; // Fail closed when private queued data cannot be scoped safely.
    }
    if (mounted && revision == _locationRevision) {
      _location.setSessionReady(ready);
    }
  }

  @override
  void dispose() {
    widget.client.store.onCleared = null;
    _session.removeListener(_syncLocationSession);
    widget.client.upgradeRequired.removeListener(_syncLocationSession);
    _location.dispose();
    _positions.dispose();
    _today.dispose();
    _notifications.dispose();
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Composition root (ADR-0016): repositories and controllers are built once
    // here and read from context, rather than threaded through constructors
    // down every screen that happens to sit between the two.
    return MultiProvider(
      providers: [
        // One publisher follows the signed-in active trip across all screens.
        Provider<DriverApi>.value(value: widget.client),
        ChangeNotifierProvider<PositionPublisher>.value(value: _positions),
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
          lazy: false,
          create: (_) => ConfigController(config: _config)
            ..startRecovery()
            ..load(),
        ),
        // Follows the device by default. The prototype puts a Theme control on
        // Profile > App preferences, which drives this; dark is the one that
        // matters in practice, since these screens are read before dawn and
        // after dusk on a windscreen-mounted phone.
        ChangeNotifierProvider(create: (_) => AppThemeController()),
        ChangeNotifierProvider.value(value: _session),
        ChangeNotifierProvider<TodayController>.value(value: _today),
        ChangeNotifierProvider<DriverNotifications>.value(
          value: _notifications,
        ),
      ],
      child: Consumer<AppThemeController>(
        builder: (context, theme, _) => MaterialApp(
          navigatorKey: _navigator,
          title: 'Trotxi Driver',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: theme.themeMode,
          home: AuthGate(home: (context) => const DriverShell()),
          builder: (context, child) => ValueListenableBuilder<bool>(
            valueListenable: widget.client.upgradeRequired,
            builder: (context, blocked, _) => blocked
                ? const Scaffold(
                    body: SafeArea(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.system_update, size: 48),
                              SizedBox(height: 16),
                              Text(
                                'Update required',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'This build is no longer supported. Update the driver app to continue. If an update is not available, contact operations.',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : Consumer<ConfigController>(
                    builder: (context, config, _) => Column(
                      children: [
                        if (config.error != null)
                          Material(
                            child: SafeArea(
                              bottom: false,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        config.error!,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: config.load,
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        Expanded(child: child ?? const SizedBox.shrink()),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

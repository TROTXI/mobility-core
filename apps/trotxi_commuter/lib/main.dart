import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trotxi_commuter/Features/Onboarding/widgets/splash_view.dart';
import 'package:trotxi_commuter/Features/Onboarding/pages/onboard_page.dart';
import 'package:trotxi_commuter/Features/Home/pages/home_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_commuter/core/Tokens/token_storage.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme_controller.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/firebase_options.dart';
import 'package:trotxi_commuter/firebase_performance.dart';

const _apiBaseUrl = String.fromEnvironment('API_BASE_URL');
const _apiRealm = String.fromEnvironment('API_SESSION_REALM');

final trotxiClientProvider = Provider<CommuterApi>((ref) {
  throw UnimplementedError(
    'trotxiClientProvider has no default  override it in main() with '
    'trotxiClientProvider.overrideWithValue(client) before runApp().',
  );
});

Future<void> main() async {
  var launched = false;
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
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
        _ => throw UnsupportedError(
          'The commuter app requires iOS or Android.',
        ),
      };
      final metadata = wire.ClientMetadata(
        app: 'commuter',
        build: int.parse(package.buildNumber),
        platform: platform,
      );
      final transport = wire.TrotxiClientFactory.create(
        baseUrl: _apiBaseUrl,
        tokenStore: tokens,
        metadata: metadata,
      );
      transport.dio.interceptors.add(PerformanceInterceptor());
      final client = CommuterApi(
        client: transport,
        store: tokens,
        metadata: metadata,
      );
      runApp(TrotxiCommuterApp(client: client));
      launched = true;
    },
    (error, stack) {
      // Catches anything thrown outside the zone above (belt-and-suspenders)
      if (Firebase.apps.isNotEmpty) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      }
      if (!launched) {
        runApp(
          const MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'This build needs a replacement API URL and session realm. Contact support.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    },
  );
}

class TrotxiCommuterApp extends StatefulWidget {
  const TrotxiCommuterApp({super.key, required this.client});

  final CommuterApi client;

  @override
  State<TrotxiCommuterApp> createState() => _TrotxiCommuterAppState();
}

class _TrotxiCommuterAppState extends State<TrotxiCommuterApp> {
  final _themeController = AppThemeController();

  @override
  void initState() {
    super.initState();
    unawaited(widget.client.load());
  }

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
        animation: Listenable.merge([
          _themeController,
          widget.client.stage,
          widget.client.identityRevision,
          widget.client.upgradeRequired,
        ]),
        builder: (context, _) => ProviderScope(
          key: ValueKey(
            '${widget.client.stage.value}:${widget.client.store.generation}:${widget.client.upgradeRequired.value}',
          ),
          overrides: [trotxiClientProvider.overrideWithValue(widget.client)],
          child: MaterialApp(
            title: 'Trotxi Commuter',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: _themeController.themeMode,
            home: widget.client.upgradeRequired.value
                ? const PopScope(
                    canPop: false,
                    child: Scaffold(
                      body: SafeArea(
                        child: Center(
                          child: Text('Please update the app to continue.'),
                        ),
                      ),
                    ),
                  )
                : switch (widget.client.stage.value) {
                    CommuterStage.loading => const Scaffold(body: SplashView()),
                    CommuterStage.signedOut => OnBoardPage(
                      client: widget.client,
                    ),
                    CommuterStage.ready => HomePage(client: widget.client),
                    CommuterStage.failed => Scaffold(
                      body: SafeArea(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.client.startupError?.message ??
                                    'Could not restore your session.',
                              ),
                              TextButton(
                                onPressed: widget.client.load,
                                child: const Text('Try again'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  },
          ),
        ),
      ),
    );
  }
}

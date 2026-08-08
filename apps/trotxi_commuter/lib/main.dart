import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:trotxi_commuter/Presentations/Onboarding/pages/splash_page.dart';
import 'package:trotxi_commuter/core/Tokens/token_storage.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/firebase_options.dart';
import 'package:trotxi_commuter/firebase_performance.dart';

const String _apiBaseUrl = 'https://trotxi-api-staging.onrender.com';

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
      final client = TrotxiClientFactory.create(baseUrl: _apiBaseUrl);
      client.dio.interceptors.add(PerformanceInterceptor());
      // await TokenStorage.instance.clearTokens();
      runApp(TrotxiCommuterApp(client: client));
    },
    (error, stack) {
      // Catches anything thrown outside the zone above (belt-and-suspenders)
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    },
  );
}

class TrotxiCommuterApp extends StatelessWidget {
  const TrotxiCommuterApp({super.key, required this.client});

  final TrotxiApiClient client;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trotxi Commuter',
      theme: AppTheme.lightTheme,
      home: SplashPage(client: client),
    );
  }
}

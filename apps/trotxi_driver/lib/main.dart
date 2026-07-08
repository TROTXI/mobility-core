import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:trotxi_driver/core/config/theme/app_theme.dart';
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

      final client = TrotxiClientFactory.create(baseUrl: _apiBaseUrl);
      client.dio.interceptors.add(PerformanceInterceptor());
      runApp(TrotxiDriverApp(client: client));
    },
    (error, stack) {
      // Catches anything thrown outside the zone above (belt-and-suspenders)
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    },
  );
}

class TrotxiDriverApp extends StatelessWidget {
  const TrotxiDriverApp({super.key, required this.client});

  final TrotxiApiClient client;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trotxi Driver',
      theme: AppTheme.lightTheme,
      home: _PlaceholderHome(client: client),
    );
  }
}

class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome({required this.client});

  final TrotxiApiClient client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Trotxi Driver'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_bus_outlined, size: 64),
            const SizedBox(height: 16),
            Text(
              'Driver App',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(_apiBaseUrl, style: Theme.of(context).textTheme.bodySmall),
            ElevatedButton(
              onPressed: () => FirebaseCrashlytics.instance.crash(),
              child: const Text('Test Crash Driver'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:trotxi_driver/core/config/theme/app_theme.dart';
import 'package:trotxi_client/trotxi_client.dart';

const _apiBaseUrl = String.fromEnvironment('API_BASE_URL');

void main() {
  final client = TrotxiClientFactory.create(baseUrl: _apiBaseUrl);
  runApp(TrotxiDriverApp(client: client));
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
            Text(
              _apiBaseUrl,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
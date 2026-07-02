import 'package:flutter/material.dart';
import 'package:trotxi_client/authentication_client.dart';
import 'package:trotxi_client/auth_result.dart';
import 'package:trotxi_client/google_auth_orchestrator.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme.dart';
import 'package:trotxi_client/trotxi_client.dart';

const _apiBaseUrl = String.fromEnvironment('API_BASE_URL');
const _googleServerClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

void main() {
  final (:client, :authClient) = TrotxiClientFactory.create(
    baseUrl: _apiBaseUrl,
  );

  final googleAuthOrchestrator = GoogleAuthOrchestrator(
    authClient: authClient,
    serverClientId: _googleServerClientId,
  );

  runApp(TrotxiCommuterApp(
    client: client,
    authClient: authClient,
    googleAuthOrchestrator: googleAuthOrchestrator,
  ));
}

class TrotxiCommuterApp extends StatelessWidget {
  const TrotxiCommuterApp({
    super.key,
    required this.client,
    required this.authClient,
    required this.googleAuthOrchestrator,
  });

  final TrotxiApiClient client;
  final AuthenticationClient authClient;
  final GoogleAuthOrchestrator googleAuthOrchestrator;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trotxi Commuter',
      theme: AppTheme.lightTheme,
      home: _PlaceholderHome(
        client: client,
        authClient: authClient,
        googleAuthOrchestrator: googleAuthOrchestrator,
      ),
    );
  }
}

class _PlaceholderHome extends StatefulWidget {
  const _PlaceholderHome({
    required this.client,
    required this.authClient,
    required this.googleAuthOrchestrator,
  });

  final TrotxiApiClient client;
  final AuthenticationClient authClient;
  final GoogleAuthOrchestrator googleAuthOrchestrator;

  @override
  State<_PlaceholderHome> createState() => _PlaceholderHomeState();
}

class _PlaceholderHomeState extends State<_PlaceholderHome> {
  bool _isSigningIn = false;
  String? _statusMessage;

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isSigningIn = true;
      _statusMessage = null;
    });

    final result = await widget.googleAuthOrchestrator.signIn();

    if (!mounted) return;

    setState(() {
      _isSigningIn = false;
      _statusMessage = switch (result) {
        AuthSuccess(:final user) => 'Signed in as ${user.id}',
        AuthCancelled() => 'Sign-in cancelled',
        AuthFailure(:final reason) => 'Failed: ${reason.name}',
        _ => 'Unknown result',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Trotxi Commuter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_bus_outlined, size: 64),
            const SizedBox(height: 16),
            Text(
              'Commuter App',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _apiBaseUrl,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSigningIn ? null : _handleGoogleSignIn,
              child: _isSigningIn
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Sign in with Google'),
            ),
            if (_statusMessage != null) ...[
              const SizedBox(height: 16),
              Text(_statusMessage!),
            ],
          ],
        ),
      ),
    );
  }
}
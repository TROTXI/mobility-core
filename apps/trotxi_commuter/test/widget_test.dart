import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_client/auth_result.dart';
import 'package:trotxi_client/authentication_client.dart';
import 'package:trotxi_client/google_auth_orchestrator.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/main.dart';

class FakeGoogleAuthOrchestrator extends GoogleAuthOrchestrator {
  FakeGoogleAuthOrchestrator()
      : super(
          authClient: FakeAuthClient(),
          serverClientId: 'test',
        );

  @override
  Future<AuthResult> signIn() async {
    return AuthCancelled();
  }
}

class FakeAuthClient extends AuthenticationClient {
  FakeAuthClient() : super(client: TrotxiApiClient());
}

void main() {
  late TrotxiApiClient client;
  late AuthenticationClient authClient;
  late GoogleAuthOrchestrator googleAuth;

  setUp(() {
    (client: client, authClient: authClient) =
        TrotxiClientFactory.create(baseUrl: 'https://example.com');

    googleAuth = FakeGoogleAuthOrchestrator();
  });

  testWidgets('SMOKE: app boots and renders home screen', (tester) async {
    await tester.pumpWidget(
      TrotxiCommuterApp(
        client: client,
        authClient: authClient,
        googleAuthOrchestrator: googleAuth,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Trotxi Commuter'), findsOneWidget);
    expect(find.text('Commuter App'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('SMOKE: sign-in button exists and is tappable', (tester) async {
    await tester.pumpWidget(
      TrotxiCommuterApp(
        client: client,
        authClient: authClient,
        googleAuthOrchestrator: googleAuth,
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign in with Google'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
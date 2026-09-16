import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/Presentations/Auth/pages/auth_gate.dart';
import 'package:trotxi_driver/core/state/session_controller.dart';
import 'package:trotxi_driver/data/driver_auth_repository.dart';
import 'package:trotxi_driver/core/api/driver_api.dart';
import 'package:trotxi_driver/main.dart';
import 'support/replacement_client.dart';

void main() {
  late DriverApi client;

  Future<void> pumpApp(WidgetTester tester) async {
    FlutterSecureStorage.setMockInitialValues({
      'driver_first_launch_completed_v1': '1',
    });
    // The real serialized session queue and Dio futures live in the same
    // asynchronous zone. Native keystore behavior is not claimed by this test.
    await tester.runAsync(() async {
      client = replacementClient(
        dio: Dio()
          ..interceptors.add(
            InterceptorsWrapper(
              onRequest: (o, h) => h.reject(
                DioException(
                  requestOptions: o,
                  type: DioExceptionType.connectionError,
                ),
              ),
            ),
          ),
      );
      await tester.pumpWidget(TrotxiDriverApp(client: client));
      await Future<void>.delayed(const Duration(milliseconds: 20));
    });
    await tester.pumpAndSettle();
  }

  testWidgets(
    'upgrade admission replaces the navigator and cannot be dismissed with Back',
    (tester) async {
      await pumpApp(tester);
      client.upgradeRequired.value = true;
      await tester.pump();
      expect(find.text('Update required'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(find.text('Update required'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('App renders without crashing', (tester) async {
    await pumpApp(tester);
    expect(find.byType(MaterialApp), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'a session clear removes pushed routes from the previous driver',
    (tester) async {
      await pumpApp(tester);
      final context = tester.element(find.byType(AuthGate));
      context.read<SessionController>().onSignedIn(
        const DriverSession(
          driverId: 'driver-old',
          fullName: 'Old driver',
          mustChangePin: false,
        ),
      );
      await tester.pump();
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              const Scaffold(body: Text('Previous driver manifest')),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Previous driver manifest'), findsOneWidget);
      await tester.runAsync(client.store.clearTokens);
      await tester.pumpAndSettle();
      expect(find.text('Previous driver manifest'), findsNothing);
      expect(context.read<SessionController>().stage, SessionStage.signedOut);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('Theme uses Material3', (tester) async {
    await pumpApp(tester);
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme?.useMaterial3, isTrue);
    await tester.pumpWidget(const SizedBox());
  });
}

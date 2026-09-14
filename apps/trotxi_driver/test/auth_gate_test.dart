import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/Presentations/Auth/pages/auth_gate.dart';
import 'package:trotxi_driver/Presentations/Readiness/pages/device_readiness_page.dart';
import 'package:trotxi_driver/core/config/theme/app_theme.dart';
import 'package:trotxi_driver/core/state/config_controller.dart';
import 'package:trotxi_driver/core/state/session_controller.dart';
import 'package:trotxi_driver/data/config_repository.dart';
import 'package:trotxi_driver/data/device_readiness.dart';
import 'package:trotxi_driver/data/driver_auth_repository.dart';
import 'package:trotxi_driver/data/first_launch_store.dart';

class _Auth implements DriverAuthRepository {
  _Auth(this.operatorIssued);
  final bool operatorIssued;
  int signInCalls = 0;
  int pinChangeCalls = 0;

  @override
  Future<bool> hasStoredSession() async => false;

  @override
  Future<DriverSession> signIn({
    required String driverCode,
    required String pin,
    required bool rememberDevice,
  }) async {
    signInCalls++;
    return DriverSession(
      driverId: 'test-driver',
      fullName: 'TEST Driver',
      mustChangePin: operatorIssued,
      driverCode: driverCode,
    );
  }

  @override
  Future<void> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    pinChangeCalls++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FirstLaunch implements FirstLaunchStore {
  _FirstLaunch({this.completed = true});

  bool completed;

  @override
  Future<bool> hasCompleted() async => completed;

  @override
  Future<void> complete() async => completed = true;
}

class _Readiness implements DeviceReadinessService {
  @override
  Future<DeviceReadiness> check() async => const DeviceReadiness(
    camera: PermissionStatus.denied,
    location: PermissionStatus.denied,
    locationServices: true,
  );

  @override
  Future<void> request(DevicePermission permission) async {}

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<bool> openLocationSettings() async => true;
}

class _Config implements ConfigRepository {
  @override
  Future<AppConfig> load() async => AppConfig.empty;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pump(WidgetTester tester, _Auth auth) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<DriverAuthRepository>.value(value: auth),
        ChangeNotifierProvider(create: (_) => SessionController(auth: auth)),
        ChangeNotifierProvider(
          create: (_) => ConfigController(config: _Config()),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: AuthGate(
          firstLaunchStore: _FirstLaunch(),
          readinessService: _Readiness(),
          splashDuration: Duration.zero,
          home: (_) => const Scaffold(body: Text('Today test destination')),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final operatorIssued in [true, false]) {
    testWidgets(
      'sign-in reaches Today without PIN setup, operator-issued=$operatorIssued',
      (tester) async {
        final auth = _Auth(operatorIssued);
        await _pump(tester, auth);
        expect(find.text('Today test destination'), findsNothing);
        await tester.enterText(find.byType(TextField).first, 'DR-TEST');
        await tester.enterText(find.byType(TextField).last, '482913');
        await tester.pumpAndSettle();
        expect(auth.signInCalls, 1);
        expect(find.text('Confirm your account'), findsOneWidget);
        expect(find.text('Today test destination'), findsNothing);
        await tester.tap(find.text('Yes, link account'));
        await tester.pumpAndSettle();
        expect(find.text('Account linked'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('Continue'),
          300,
          scrollable: find.byType(Scrollable).last,
        );
        await tester.ensureVisible(find.text('Continue'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        expect(find.byType(DeviceReadinessPage), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('Continue to today'),
          300,
          scrollable: find.byType(Scrollable).last,
        );
        await tester.ensureVisible(find.text('Continue to today'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue to today'));
        await tester.pumpAndSettle();
        expect(find.text('Today test destination'), findsOneWidget);
        expect(find.text('Choose your PIN'), findsNothing);
        expect(auth.pinChangeCalls, 0);
      },
    );
  }

  testWidgets('operator recovery remains reachable and returns to sign-in', (
    tester,
  ) async {
    final auth = _Auth(true);
    await _pump(tester, auth);
    await tester.scrollUntilVisible(
      find.text("Can't sign in?"),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text("Can't sign in?"));
    await tester.pumpAndSettle();
    expect(find.text('Ask operations for a new PIN'), findsOneWidget);
    expect(find.text('Choose your PIN'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Back to sign in'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back to sign in'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(2));
    expect(auth.signInCalls, 0);
    expect(auth.pinChangeCalls, 0);
  });

  testWidgets('first install shows splash and welcome once before sign-in', (
    tester,
  ) async {
    final auth = _Auth(false);
    final firstLaunch = _FirstLaunch(completed: false);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<DriverAuthRepository>.value(value: auth),
          ChangeNotifierProvider(create: (_) => SessionController(auth: auth)),
          ChangeNotifierProvider(
            create: (_) => ConfigController(config: _Config()),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: AuthGate(
            firstLaunchStore: firstLaunch,
            splashDuration: Duration.zero,
            home: (_) => const Text('Today test destination'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Welcome to Trotxi Driver'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Continue'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.ensureVisible(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(firstLaunch.completed, isTrue);
    expect(find.byType(TextField), findsNWidgets(2));
  });
}

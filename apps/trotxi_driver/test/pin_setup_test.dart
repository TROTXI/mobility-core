// Temporary-PIN setup and "Forgot PIN?" (driver email onboarding).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/Presentations/Auth/pages/forgot_pin_page.dart';
import 'package:trotxi_driver/Presentations/Auth/pages/pin_setup_page.dart';
import 'package:trotxi_driver/Presentations/Auth/pages/sign_in_page.dart';
import 'package:trotxi_driver/core/api/driver_api.dart';
import 'package:trotxi_driver/core/config/theme/app_theme.dart';
import 'package:trotxi_driver/core/state/config_controller.dart';
import 'package:trotxi_driver/core/state/session_controller.dart';
import 'package:trotxi_driver/data/config_repository.dart';
import 'package:trotxi_driver/data/driver_auth_repository.dart';

const _temporary = DriverSession(
  driverId: 'driver-1',
  fullName: 'Ama Mensah',
  mustChangePin: true,
  driverCode: 'DR-7K9Q',
);

class _Auth implements DriverAuthRepository {
  _Auth({this.restored});
  DriverSession? restored;
  int signOutCalls = 0;
  final changes = <({String current, String next, String key})>[];
  final List<Object> failures = [];

  @override
  Future<bool> hasStoredSession() async => restored != null;

  @override
  Future<DriverSession?> currentDriver() async => restored;

  @override
  Future<DriverSession> signIn({
    required String driverCode,
    required String pin,
    required bool rememberDevice,
  }) async => _temporary;

  @override
  Future<void> changePin({
    required String currentPin,
    required String newPin,
    required String idempotencyKey,
  }) async {
    changes.add((current: currentPin, next: newPin, key: idempotencyKey));
    if (failures.isNotEmpty) throw failures.removeAt(0);
  }

  @override
  Future<void> signOut() async => signOutCalls++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Config implements ConfigRepository {
  @override
  Future<AppConfig> load() async => AppConfig.empty;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _setup(
  WidgetTester tester,
  _Auth auth, {
  String? temporaryPin = '481205',
  Future<void> Function()? onChanged,
  Future<void> Function()? onUncertain,
}) {
  // The phone size the frames are drawn at, so the actions at the foot of the
  // screen are where a driver sees them.
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme,
      home: PinSetupPage(
        temporaryPin: temporaryPin,
        changePin: auth.changePin,
        onChanged: onChanged ?? () async {},
        onUncertain: onUncertain ?? () async {},
        onSignOut: () async {},
      ),
    ),
  );
}

Future<void> _type(WidgetTester tester, String label, String value) async {
  await tester.enterText(find.byKey(ValueKey('pin-field:$label')), value);
  await tester.pump();
}

void main() {
  test('weak PINs are refused locally with the server\'s own rule', () {
    expect(pinProblem('12345'), isNotNull);
    expect(pinProblem('777777'), contains('repeated'));
    expect(pinProblem('123456'), contains('run'));
    expect(pinProblem('654321'), contains('run'));
    expect(pinProblem('483920'), isNull);
  });

  group('session stages', () {
    test(
      'a temporary PIN goes to setup after confirmation, then sign-in',
      () async {
        final auth = _Auth();
        final session = SessionController(auth: auth);
        session.holdTemporaryPin('481205');
        session.onSignedIn(_temporary);
        expect(session.stage, SessionStage.confirming);
        session.confirm();
        expect(session.stage, SessionStage.pinSetup);
        expect(session.temporaryPin, '481205');

        await session.onPinChanged();
        // The server revoked every session, this one too: clear and sign in.
        expect(auth.signOutCalls, 1);
        expect(session.stage, SessionStage.signedOut);
        expect(session.temporaryPin, isNull);
        expect(session.notice, contains('new PIN'));
        session.onSignedIn(
          const DriverSession(
            driverId: 'driver-1',
            fullName: 'Ama',
            mustChangePin: false,
          ),
        );
        expect(session.notice, isNull);
        session.confirm();
        expect(session.stage, SessionStage.linked);
      },
    );

    test('a restored temporary-PIN session cannot skip setup', () async {
      final session = SessionController(auth: _Auth(restored: _temporary));
      await session.restore();
      expect(session.stage, SessionStage.pinSetup);
      // Restored: the app never had the PIN, so setup asks for it.
      expect(session.temporaryPin, isNull);
    });
  });

  group('PIN setup screen', () {
    testWidgets(
      'six digits do not submit themselves; confirmation must match',
      (tester) async {
        final auth = _Auth();
        await _setup(tester, auth);
        await _type(tester, 'New PIN', '483920');
        await _type(tester, 'Confirm new PIN', '483920');
        expect(auth.changes, isEmpty, reason: 'no automatic submission');

        await _type(tester, 'Confirm new PIN', '483921');
        await tester.tap(find.text('Save PIN'));
        await tester.pump();
        expect(find.text('The two new PINs do not match.'), findsOneWidget);
        expect(auth.changes, isEmpty);

        await _type(tester, 'New PIN', '123456');
        await _type(tester, 'Confirm new PIN', '123456');
        await tester.tap(find.text('Save PIN'));
        await tester.pump();
        expect(find.textContaining('run like 123456'), findsOneWidget);
        expect(auth.changes, isEmpty);
      },
    );

    testWidgets('an unanswered request retries with the same key', (
      tester,
    ) async {
      final auth = _Auth()..failures.add(const OfflineException());
      var changed = 0;
      await _setup(tester, auth, onChanged: () async => changed++);
      await _type(tester, 'New PIN', '483920');
      await _type(tester, 'Confirm new PIN', '483920');
      await tester.tap(find.text('Save PIN'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('may or may not have gone through'),
        findsOneWidget,
      );
      // Locked: the PIN that may already be set cannot be edited away.
      for (final label in ['New PIN', 'Confirm new PIN']) {
        expect(
          tester
              .widget<TextField>(find.byKey(ValueKey('pin-field:$label')))
              .enabled,
          isFalse,
        );
      }
      await tester.tap(find.text('Retry saving this PIN'));
      await tester.pump();
      await tester.pump();
      expect(auth.changes, hasLength(2));
      expect(auth.changes[1].next, '483920');
      expect(auth.changes[0].key, auth.changes[1].key);
      expect(auth.changes[0].current, '481205');
      expect(changed, 1);
    });

    for (final status in [500, 502, 503, 504]) {
      testWidgets(
        'a first $status locks all PIN fields and preserves the retry',
        (tester) async {
          final auth = _Auth()
            ..failures.add(ApiException(status, 'Server error'));
          var changed = 0;
          await _setup(
            tester,
            auth,
            temporaryPin: null,
            onChanged: () async => changed++,
          );
          await _type(tester, 'Temporary PIN', '481205');
          await _type(tester, 'New PIN', '483920');
          await _type(tester, 'Confirm new PIN', '483920');
          await tester.tap(find.text('Save PIN'));
          await tester.pumpAndSettle();
          expect(
            find.textContaining('may or may not have gone'),
            findsOneWidget,
          );
          for (final label in ['Temporary PIN', 'New PIN', 'Confirm new PIN']) {
            expect(
              tester
                  .widget<TextField>(find.byKey(ValueKey('pin-field:$label')))
                  .enabled,
              isFalse,
            );
          }
          await tester.tap(find.text('Retry saving this PIN'));
          await tester.pump();
          await tester.pump();
          expect(auth.changes, hasLength(2));
          expect(auth.changes[1], auth.changes[0]);
          expect(changed, 1);
        },
      );
    }

    testWidgets(
      'a 502 followed by a revoked session keeps the outcome uncertain',
      (tester) async {
        final auth = _Auth()
          ..failures.addAll([
            const ApiException(502, 'Bad gateway'),
            const UnauthorizedException(),
          ]);
        var uncertain = 0;
        await _setup(tester, auth, onUncertain: () async => uncertain++);
        await _type(tester, 'New PIN', '483920');
        await _type(tester, 'Confirm new PIN', '483920');
        await tester.tap(find.text('Save PIN'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Retry saving this PIN'));
        await tester.pump();
        await tester.pump();
        expect(auth.changes[1], auth.changes[0]);
        expect(uncertain, 1);
      },
    );

    testWidgets(
      'after a definite refusal the PIN can change, and a new PIN gets a new key',
      (tester) async {
        final auth = _Auth()
          ..failures.add(
            const ApiException(
              400,
              'Choose a different PIN that is not repeated or sequential digits.',
              code: 'weak_pin',
            ),
          );
        await _setup(tester, auth);
        await _type(tester, 'New PIN', '483920');
        await _type(tester, 'Confirm new PIN', '483920');
        await tester.tap(find.text('Save PIN'));
        await tester.pumpAndSettle();
        // A 4xx is an answer: nothing was applied, so editing is safe again.
        await _type(tester, 'New PIN', '572914');
        await _type(tester, 'Confirm new PIN', '572914');
        await tester.tap(find.text('Save PIN'));
        await tester.pump();
        await tester.pump();
        expect(auth.changes[1].next, '572914');
        expect(auth.changes[0].key, isNot(auth.changes[1].key));
      },
    );

    testWidgets(
      'a session gone after an unanswered change is treated as uncertain',
      (tester) async {
        final auth = _Auth()
          ..failures.addAll([
            const OfflineException(),
            const UnauthorizedException(),
          ]);
        var uncertain = 0;
        await _setup(tester, auth, onUncertain: () async => uncertain++);
        await _type(tester, 'New PIN', '483920');
        await _type(tester, 'Confirm new PIN', '483920');
        await tester.tap(find.text('Save PIN'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Retry saving this PIN'));
        await tester.pump();
        await tester.pump();
        expect(uncertain, 1);
      },
    );

    testWidgets(
      'restored sessions ask for the temporary PIN; lockout and limits explain the wait',
      (tester) async {
        final auth = _Auth()
          ..failures.addAll([
            const InvalidCredentialsException(),
            const CredentialLockedException(Duration(minutes: 15)),
            const RateLimitException(Duration(seconds: 30)),
          ]);
        await _setup(tester, auth, temporaryPin: null);
        expect(
          find.byKey(const ValueKey('pin-field:Temporary PIN')),
          findsOneWidget,
        );
        await tester.tap(find.text('Save PIN'));
        await tester.pump();
        expect(find.textContaining('six-digit temporary PIN'), findsOneWidget);

        await _type(tester, 'Temporary PIN', '481205');
        await _type(tester, 'New PIN', '483920');
        await _type(tester, 'Confirm new PIN', '483920');
        await tester.tap(find.text('Save PIN'));
        await tester.pumpAndSettle();
        expect(
          find.textContaining('temporary PIN is not right'),
          findsOneWidget,
        );
        await tester.tap(find.text('Save PIN'));
        await tester.pumpAndSettle();
        expect(find.textContaining('Try again in 15 minutes'), findsOneWidget);
        await tester.tap(find.text('Save PIN'));
        await tester.pumpAndSettle();
        expect(find.textContaining('Wait 30 seconds'), findsOneWidget);
      },
    );

    testWidgets('an expired temporary PIN stops the form and says who to ask', (
      tester,
    ) async {
      final auth = _Auth()
        ..failures.add(
          const ApiException(
            403,
            'Your temporary PIN has expired. Ask Trotxi operations for a new one.',
            code: 'temporary_pin_expired',
          ),
        );
      await _setup(tester, auth);
      await _type(tester, 'New PIN', '483920');
      await _type(tester, 'Confirm new PIN', '483920');
      await tester.tap(find.text('Save PIN'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Ask Trotxi operations for a new one'),
        findsOneWidget,
      );
      final save = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Save PIN'),
      );
      expect(save.onPressed, isNull);
    });
  });

  testWidgets(
    'signed out: "Forgot PIN?" explains the operations-assisted reset',
    (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ConfigController(config: _Config()),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: SignInPage(auth: _Auth(), onSignedIn: (_) {}),
          ),
        ),
      );
      expect(find.text('Forgot PIN?'), findsOneWidget);
      expect(find.textContaining('one-way hash'), findsOneWidget);
      await tester.ensureVisible(find.text('Forgot PIN?'));
      await tester.tap(find.text('Forgot PIN?'));
      await tester.pumpAndSettle();
      expect(find.byType(ForgotPinPage), findsOneWidget);
      expect(find.textContaining('Operations resets your PIN'), findsOneWidget);
      expect(find.textContaining('works for 72 hours'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.textContaining('cannot see the PIN you choose'),
        200,
      );
      expect(
        find.textContaining('cannot see the PIN you choose'),
        findsOneWidget,
      );
    },
  );

  testWidgets('sign-in hands a temporary PIN to setup, in memory only', (
    tester,
  ) async {
    String? held;
    DriverSession? signedIn;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: SignInPage(
          auth: _Auth(),
          onSignedIn: (session) => signedIn = session,
          onTemporaryPin: (pin) => held = pin,
        ),
      ),
    );
    await tester.enterText(find.byType(TextField).first, 'DR-7K9Q');
    await tester.enterText(find.byType(TextField).last, '481205');
    await tester.pump();
    await tester.pump();
    expect(signedIn?.mustChangePin, isTrue);
    expect(held, '481205');
  });
}

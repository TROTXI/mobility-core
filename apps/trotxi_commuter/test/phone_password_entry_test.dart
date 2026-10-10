import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_commuter/Features/Onboarding/pages/onboard_page.dart';
import 'package:trotxi_commuter/Features/Onboarding/pages/phone_password_page.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/auth/password_policy.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme.dart';

import 'replacement_fixture.dart';

void main() {
  test('new password policy requires a capital, number and symbol', () {
    expect(validateNewPassword('GoodPass123!'), isNull);
    for (final value in [
      'GoodPass12!',
      'goodpassword1!',
      'GoodPassword!',
      'GoodPassword1',
      'GoodPassword1 ',
      'Password123!',
    ]) {
      expect(validateNewPassword(value), isNotNull);
    }
    expect(newPasswordGuidance, isNot(contains('128')));
  });

  testWidgets('commuter entry shows one phone method with distinct signup', (
    tester,
  ) async {
    final fixture = Fixture();
    addTearDown(fixture.api.dispose);
    await tester.binding.setSurfaceSize(const Size(430, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: OnBoardPage(client: fixture.api),
      ),
    );
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.textContaining('Google'), findsNothing);
    expect(find.textContaining('Apple'), findsNothing);
    expect(find.textContaining('Continue with email'), findsNothing);
    expect(find.text('Request account deletion'), findsOneWidget);

    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('First name'), findsOneWidget);
    expect(find.text('Last name'), findsOneWidget);
    expect(find.text('Phone number'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsNothing);
    expect(find.text('Continue'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Continue')).dy, lessThan(1000));
    expect(fixture.requests, isEmpty);
  });

  testWidgets('entry actions remain visible on a short phone', (tester) async {
    final fixture = Fixture();
    addTearDown(fixture.api.dispose);
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: OnBoardPage(client: fixture.api),
      ),
    );

    expect(
      tester
          .getBottomRight(find.widgetWithText(FilledButton, 'Create account'))
          .dy,
      lessThan(640),
    );
    expect(
      tester.getBottomRight(find.widgetWithText(OutlinedButton, 'Sign in')).dy,
      lessThan(640),
    );
  });

  testWidgets('signup keeps the action visible and preserves details on back', (
    tester,
  ) async {
    final fixture = Fixture();
    addTearDown(fixture.api.dispose);
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: PhonePasswordPage(client: fixture.api, signup: true),
      ),
    );

    final continueButton = find.widgetWithText(FilledButton, 'Continue');
    expect(continueButton, findsOneWidget);
    expect(tester.getBottomRight(continueButton).dy, lessThan(640));
    Future<void> enter(String label, String value) async {
      final field = find.widgetWithText(TextFormField, label);
      await tester.ensureVisible(field);
      await tester.enterText(field, value);
      await tester.pump();
    }

    await enter('First name', 'Ama');
    await enter('Last name', 'Mensah');
    await enter('Phone number', '0241234567');
    await enter('Email', 'ama@example.com');
    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    expect(find.text('Create a password'), findsOneWidget);
    expect(find.text('Confirm password'), findsOneWidget);
    expect(find.text('12 to 128 characters'), findsNothing);
    expect(find.text('At least 12 characters'), findsOneWidget);
    final sendButton = find.widgetWithText(
      FilledButton,
      'Send verification code',
    );
    expect(tester.widget<FilledButton>(sendButton).onPressed, isNull);
    await enter('Password', 'short');
    await enter('Confirm password', 'short');
    expect(tester.widget<FilledButton>(sendButton).onPressed, isNull);
    await enter('Password', 'GoodPass123!');
    await enter('Confirm password', 'GoodPass123!');
    expect(find.text('Passwords match'), findsOneWidget);
    expect(tester.widget<FilledButton>(sendButton).onPressed, isNotNull);
    expect(tester.getBottomRight(sendButton).dy, lessThan(640));

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Your details'), findsAtLeastNWidgets(1));
    expect(
      tester
          .widget<TextFormField>(
            find.widgetWithText(TextFormField, 'First name'),
          )
          .controller
          ?.text,
      'Ama',
    );
    expect(fixture.requests, isEmpty);
  });

  test(
    'finishing signup removes the revoked OTP session from this device',
    () async {
      final fixture = Fixture();
      addTearDown(fixture.api.dispose);
      await fixture.signedIn();
      fixture.reply = (request) {
        if (request.path == '/v1/me/phone-registration') {
          return jsonResponse({'data': null}, 204);
        }
        return jsonResponse({
          'error': {'code': 'not_found', 'message': 'Unexpected route'},
        }, 404);
      };

      await fixture.api.finishPhoneRegistration(
        firstName: 'Ama',
        lastName: 'Mensah',
        email: 'ama@example.com',
        password: 'Correct horse trotxi battery1!',
      );

      expect(await fixture.store.getAccessToken(), isNull);
      expect(fixture.api.stage.value, CommuterStage.signedOut);
      expect(fixture.api.authNotice, contains('Sign in with your phone'));
      expect(
        fixture.requests.map((request) => request.path),
        contains('/v1/me/phone-registration'),
      );
    },
  );

  testWidgets('an existing phone account returns to sign-in after OTP', (
    tester,
  ) async {
    final fixture = Fixture();
    addTearDown(fixture.api.dispose);
    await tester.binding.setSurfaceSize(const Size(430, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    fixture.reply = (request) {
      if (request.path == '/v1/auth/phone/request') {
        return jsonResponse({
          'data': {
            'challengeId': '11111111-1111-4111-8111-111111111111',
            'expiresAt': DateTime.now()
                .toUtc()
                .add(const Duration(minutes: 5))
                .toIso8601String(),
            'resendAfterSeconds': 60,
          },
        });
      }
      if (request.path == '/v1/auth/phone/verify') {
        return jsonResponse({
          'error': {
            'code': 'password_required',
            'message': 'Sign in with your phone number and password.',
          },
        }, 409);
      }
      return jsonResponse({
        'error': {'code': 'not_found', 'message': 'Unexpected route'},
      }, 404);
    };
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: PhonePasswordPage(client: fixture.api, signup: true),
      ),
    );
    Future<void> enter(String label, String value) async {
      final field = find.widgetWithText(TextFormField, label);
      await tester.ensureVisible(field);
      await tester.enterText(field, value);
      await tester.pump();
    }

    await enter('First name', 'Ama');
    await enter('Last name', 'Mensah');
    await enter('Phone number', '0241234567');
    await enter('Email', 'ama@example.com');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Create a password'), findsOneWidget);
    await enter('Password', 'Correct horse trotxi battery1!');
    await enter('Confirm password', 'Correct horse trotxi battery1!');
    final send = find.text('Send verification code');
    await tester.ensureVisible(send);
    await tester.tap(send);
    await tester.pumpAndSettle();
    await enter('Six-digit code', '123456');
    final verify = find.text('Verify and create account');
    await tester.ensureVisible(verify);
    await tester.tap(verify);
    await tester.pumpAndSettle();

    expect(find.text('Forgot password?'), findsOneWidget);
    expect(
      find.text(
        'This number already has an account. Sign in with your password.',
      ),
      findsOneWidget,
    );
    final phone = tester.widget<TextFormField>(
      find.widgetWithText(TextFormField, 'Phone number'),
    );
    expect(phone.controller?.text, '0241234567');
  });
}

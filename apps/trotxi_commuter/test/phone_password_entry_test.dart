import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_commuter/Features/Onboarding/pages/onboard_page.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme.dart';

import 'replacement_fixture.dart';

void main() {
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

    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(find.text('Create your account'), findsAtLeastNWidgets(1));
    expect(find.text('First name'), findsOneWidget);
    expect(find.text('Last name'), findsOneWidget);
    expect(find.text('Phone number'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Send verification code'), findsOneWidget);
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
        password: 'correct horse trotxi battery',
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
}

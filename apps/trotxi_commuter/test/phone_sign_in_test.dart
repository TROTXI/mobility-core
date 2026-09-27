import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_commuter/Features/Onboarding/pages/phone_sign_in_page.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme.dart';
import 'replacement_fixture.dart';

void main() {
  testWidgets(
    'phone sign-in validates numbers and presents OTP without duplicate send',
    (tester) async {
      var sends = 0;
      final fixture = Fixture();
      fixture.reply = (request) {
        expect(request.path, '/v1/auth/phone/request');
        expect(bodyOf(request), {'phone': '0241234567'});
        sends++;
        return jsonResponse({
          'data': {
            'challengeId': '00000000-0000-4000-8000-000000000001',
            'expiresAt': DateTime.now()
                .add(const Duration(minutes: 5))
                .toUtc()
                .toIso8601String(),
            'resendAfterSeconds': 60,
          },
        });
      };
      addTearDown(fixture.api.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: PhoneSignInPage(client: fixture.api),
        ),
      );
      await tester.tap(find.text('Send code'));
      await tester.pump();
      expect(
        find.textContaining('Enter a Ghana mobile number'),
        findsOneWidget,
      );
      expect(sends, 0);
      await tester.enterText(find.byType(TextField).first, '0241234567');
      await tester.tap(find.text('Send code'));
      await tester.pumpAndSettle();
      expect(sends, 1);
      expect(find.text('Six-digit code'), findsOneWidget);
      expect(find.text('Verify and continue'), findsOneWidget);
      expect(find.textContaining('Resend in'), findsOneWidget);
      expect(find.textContaining('Google'), findsNothing);
      await tester.tap(find.text('Verify and continue'));
      await tester.pump();
      expect(find.text('Enter the six-digit code.'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
}

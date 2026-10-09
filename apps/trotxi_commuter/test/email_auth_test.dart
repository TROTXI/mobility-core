import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_commuter/Features/Onboarding/pages/email_sign_in_page.dart';
import 'package:trotxi_commuter/Features/Onboarding/pages/full_name_page.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme.dart';
import 'replacement_fixture.dart';

void main() {
  testWidgets(
    'email registration sends full name components and supports non-Google addresses',
    (tester) async {
      final f = Fixture();
      addTearDown(f.api.dispose);
      f.reply = (request) {
        expect(request.path, '/v1/auth/email/signup');
        expect(bodyOf(request), {
          'email': 'ama@outlook.com',
          'firstName': 'Ama',
          'lastName': 'Mensah',
          'otherNames': 'Akua',
        });
        return jsonResponse({
          'data': {'message': 'Check your inbox.'},
        });
      };
      await tester.binding.setSurfaceSize(const Size(430, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: EmailSignInPage(client: f.api),
        ),
      );
      await tester.tap(find.text('Create an account'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'Ama');
      await tester.enterText(find.byType(TextFormField).at(1), 'Akua');
      await tester.enterText(find.byType(TextFormField).at(2), 'Mensah');
      await tester.enterText(
        find.byType(TextFormField).at(3),
        'ama@outlook.com',
      );
      await tester.tap(find.text('Send verification email'));
      await tester.pumpAndSettle();
      expect(find.text('Check your inbox.'), findsOneWidget);
      expect(find.text('Resend email'), findsOneWidget);
      expect(f.requests.length, 1);
      expect(await f.store.getAccessToken(), isNull);
    },
  );
  testWidgets(
    'forgot password requests a generic email and keeps the rider signed out',
    (tester) async {
      final f = Fixture();
      addTearDown(f.api.dispose);
      f.reply = (request) {
        expect(request.path, '/v1/auth/email/reset');
        expect(bodyOf(request), {'email': 'ama@example.com'});
        return jsonResponse({
          'data': {
            'message':
                'If this email can be used, an email will arrive shortly.',
          },
        });
      };
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: EmailSignInPage(client: f.api),
        ),
      );
      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).first,
        'ama@example.com',
      );
      await tester.tap(find.text('Send verification email'));
      await tester.pumpAndSettle();
      expect(find.textContaining('If this email'), findsOneWidget);
      expect(await f.store.getAccessToken(), isNull);
    },
  );
  testWidgets(
    'full-name entry requires first and last names rather than an alias',
    (tester) async {
      final f = Fixture();
      addTearDown(f.api.dispose);
      await tester.binding.setSurfaceSize(const Size(430, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: FullNamePage(client: f.api, requiredForSignup: true),
        ),
      );
      await tester.tap(find.text('Save and continue'));
      await tester.pump();
      expect(find.text('Enter your first name'), findsOneWidget);
      expect(find.text('Enter your last name'), findsOneWidget);
      expect(f.requests, isEmpty);
    },
  );
}

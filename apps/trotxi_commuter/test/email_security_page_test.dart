import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/email_security_page.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme.dart';

import 'replacement_fixture.dart';

void main() {
  testWidgets('contact status refreshes manually and when the app resumes', (
    tester,
  ) async {
    final fixture = Fixture();
    addTearDown(fixture.api.dispose);
    await fixture.signedIn();
    var reads = 0;
    fixture.reply = (request) {
      if (request.path == '/v1/me/email-access') {
        reads++;
        return jsonResponse({
          'data': {
            'email': 'ama@example.com',
            'passwordEnabled': true,
            'emailVerified': reads >= 3,
          },
        });
      }
      return jsonResponse({
        'error': {'code': 'not_found', 'message': 'Unexpected route'},
      }, 404);
    };

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: EmailSecurityPage(client: fixture.api),
      ),
    );
    await tester.pumpAndSettle();
    expect(reads, 1);
    expect(find.text("I've verified my email"), findsOneWidget);

    await tester.tap(find.text("I've verified my email"));
    await tester.pumpAndSettle();
    expect(reads, 2);
    expect(find.text("I've verified my email"), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(reads, 3);
    expect(
      find.text('Contact email verified. You can use it for account recovery.'),
      findsOneWidget,
    );
    expect(find.text("I've verified my email"), findsNothing);
  });
}

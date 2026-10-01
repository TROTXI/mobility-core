import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/phone_verification_page.dart';

import 'replacement_fixture.dart';

void main() {
  testWidgets('signed-in phone upgrade sends and confirms without replacing the session',
      (tester) async {
    final fixture = Fixture();
    await fixture.signedIn();
    var verified = false;
    fixture.reply = (request) {
      if (request.path == '/v1/me/verification') {
        return jsonResponse({'data': {
          'phone': {
            'status': verified ? 'verified' : 'incomplete',
            'maskedNumber': verified ? '+233 ** *** 4567' : null,
            'verifiedAt': verified ? timestamp : null,
          },
          'standbyEligible': verified,
          'missing': verified ? <String>[] : ['phone'],
        }});
      }
      if (request.path == '/v1/me/phone-verification/start') {
        return jsonResponse({'data': {
          'challengeId': '11111111-1111-4111-8111-111111111111',
          'expiresAt': timestamp,
          'resendAfterSeconds': 60,
        }});
      }
      if (request.path == '/v1/me/phone-verification/confirm') {
        verified = true;
        return jsonResponse({'data': {'status': 'verified'}});
      }
      return jsonResponse({'error': {'code': 'not_found', 'message': 'Unexpected route'}}, 404);
    };
    await tester.runAsync(() async {
      await tester.pumpWidget(MaterialApp(home: PhoneVerificationPage(client: fixture.api)));
      for (var i = 0; i < 60 && find.text('Send code').evaluate().isEmpty; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        await tester.pump();
      }
      await tester.enterText(find.byType(TextField).first, '0241234567');
      await tester.tap(find.text('Send code'));
      for (var i = 0; i < 60 && find.text('Confirm code').evaluate().isEmpty; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        await tester.pump();
      }
      await tester.enterText(find.byType(TextField).last, '123456');
      await tester.tap(find.text('Confirm code'));
      for (var i = 0; i < 60 && find.text('Phone verified').evaluate().isEmpty; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        await tester.pump();
      }
    });
    expect(find.text('Phone verified'), findsOneWidget);
    expect(fixture.api.sessionGeneration, 1);
    expect(fixture.requests.map((r) => r.path), containsAll([
      '/v1/me/verification',
      '/v1/me/phone-verification/start',
      '/v1/me/phone-verification/confirm',
    ]));
    await tester.pumpWidget(const SizedBox.shrink());
    fixture.api.dispose();
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/auto_renewal_page.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme.dart';

import 'replacement_fixture.dart';

void main() {
  test('card controls use the scoped generated endpoints', () async {
    final fixture = Fixture();
    addTearDown(fixture.api.dispose);
    await fixture.signedIn();
    fixture.reply = (request) => request.method == 'DELETE'
        ? jsonResponse(null, 204)
        : jsonResponse({
            'data': {'enabled': true, 'card': null, 'upcoming': null},
          });
    final result = await fixture.api
        .setAutoRenewal(true)
        .timeout(const Duration(seconds: 5));
    expect(result.enabled, isTrue);
    await fixture.api.setAutoRenewal(false);
    await fixture.api.removeAutoRenewalCard();
    expect(fixture.requests.map((r) => '${r.method} ${r.path}'), [
      'PUT /v1/me/auto-renewal',
      'PUT /v1/me/auto-renewal',
      'DELETE /v1/me/auto-renewal/card',
    ]);
  });

  testWidgets('card renewal requires explicit consent and card-removal confirmation', (
    tester,
  ) async {
    final fixture = Fixture();
    await fixture.signedIn();
    fixture.reply = (request) {
      if (request.path == '/v1/me/auto-renewal' && request.method == 'GET') {
        return jsonResponse({
          'data': {
            'enabled': false,
            'card': {
              'brand': 'Visa',
              'last4': '1234',
              'expMonth': 12,
              'expYear': 2028,
            },
            'upcoming': null,
          },
        });
      }
      return jsonResponse({
        'error': {'code': 'not_found', 'message': 'No fixture'},
      }, 404);
    };
    await tester.runAsync(() async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: AutoRenewalPage(client: fixture.api),
        ),
      );
      for (
        var i = 0;
        i < 100 &&
            find.text('Visa ending 1234 · expires 12/2028').evaluate().isEmpty;
        i++
      ) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        await tester.pump();
      }
    });
    expect(find.text('Off'), findsOneWidget);
    expect(fixture.requests.where((r) => r.method == 'PUT'), isEmpty);

    await tester.tap(find.text('Turn on auto-renewal'));
    await tester.pumpAndSettle();
    expect(find.text('Turn on card auto-renewal?'), findsOneWidget);
    await tester.tap(find.text('Keep current setting'));
    await tester.pumpAndSettle();
    expect(fixture.requests.where((r) => r.method == 'PUT'), isEmpty);

    await tester.tap(find.text('Remove saved card'));
    await tester.pumpAndSettle();
    expect(find.text('Remove saved card?'), findsOneWidget);
    await tester.tap(find.text('Keep current setting'));
    await tester.pumpAndSettle();
    expect(fixture.requests.where((r) => r.method == 'DELETE'), isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
    fixture.api.dispose();
  });
}

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/notifications_inbox_page.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/profile_notification.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme.dart';

import 'replacement_fixture.dart';

void main() {
  test('all rider event kinds have safe local inbox copy', () {
    for (final kind in RiderNotificationKindEnum.values) {
      final (title, body, icon) = notificationCopy(kind);
      expect(title, isNotEmpty);
      expect(body, isNotEmpty);
      expect(icon, isA<IconData>());
      expect('$title $body', isNot(contains('@')));
    }
  });

  testWidgets('minute-level saved ask time opens a valid time picker', (
    tester,
  ) async {
    final fixture = Fixture();
    await fixture.signedIn();
    fixture.reply = (request) => ResponseBody.fromString(
      jsonEncode({
        'data': {
          'dailyAskTime': '18:30',
          'optionalUpdatesEnabled': false,
          'updatedAt': timestamp,
          'version': 2,
        },
      }),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
        'etag': ['"notification-preferences:2"'],
      },
    );
    await tester.runAsync(() async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ProfileNotificationsPage(client: fixture.api),
        ),
      );
      for (
        var i = 0;
        i < 100 && find.byType(OutlinedButton).evaluate().isEmpty;
        i++
      ) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        await tester.pump();
      }
    });
    expect(find.text('6:30 PM'), findsOneWidget);
    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle();
    expect(find.byType(TimePickerDialog), findsOneWidget);
    expect(fixture.requests.single.path, '/v1/me/notification-preferences');
    await tester.pumpWidget(const SizedBox.shrink());
    fixture.api.dispose();
  });
}

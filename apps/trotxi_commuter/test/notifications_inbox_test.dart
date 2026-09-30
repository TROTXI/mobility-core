import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/notifications_inbox_page.dart';

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
}

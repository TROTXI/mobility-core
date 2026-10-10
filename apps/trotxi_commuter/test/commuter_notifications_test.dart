import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_commuter/core/notifications/commuter_notifications.dart';

import 'replacement_fixture.dart';

class _Settings implements NotificationSettings {
  _Settings(this.authorizationStatus);
  @override
  final AuthorizationStatus authorizationStatus;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Messaging implements FirebaseMessaging {
  AuthorizationStatus permission = AuthorizationStatus.authorized;
  int deletes = 0;

  @override
  Future<void> deleteToken() async {
    deletes++;
  }

  @override
  Future<NotificationSettings> getNotificationSettings() async =>
      _Settings(permission);

  @override
  Future<String?> getToken({
    String? vapidKey,
    String? serviceWorkerScriptPath,
  }) async => 'test-commuter-token';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'registration is scoped to the rider and denied permission sends nothing',
    () async {
      final fixture = Fixture();
      addTearDown(fixture.api.dispose);
      await fixture.signedIn();
      final messaging = _Messaging()..permission = AuthorizationStatus.denied;
      final alerts = CommuterNotifications(
        api: fixture.api,
        messagingOverride: messaging,
        openInbox: () {},
        showForegroundNotice: () {},
      );
      addTearDown(alerts.dispose);
      fixture.reply = (request) {
        if (request.path == '/v1/me/devices') {
          return jsonResponse({
            'data': {
              'id': 'device',
              'platform': 'android',
              'updatedAt': '2026-09-19T12:00:00Z',
            },
          });
        }
        return jsonResponse({
          'error': {'code': 'not_found', 'message': 'Unexpected route'},
        }, 404);
      };
      alerts.setOwner('rider-a');
      await alerts.sync();
      expect(
        fixture.requests.where((r) => r.path == '/v1/me/devices'),
        isEmpty,
      );
      messaging.permission = AuthorizationStatus.authorized;
      await alerts.sync();
      expect(alerts.enabled, isTrue);
      expect(
        fixture.requests.where((r) => r.path == '/v1/me/devices'),
        hasLength(1),
      );
      alerts.setOwner('rider-b');
      await alerts.sync();
      expect(messaging.deletes, 1);
      alerts.setOwner(null);
      await alerts.sync();
      expect(messaging.deletes, 2);
    },
  );
}

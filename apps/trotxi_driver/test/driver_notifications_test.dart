import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_driver/core/state/driver_notifications.dart';
import 'support/replacement_client.dart';

class Settings implements NotificationSettings {
  Settings(this.authorizationStatus);
  @override
  final AuthorizationStatus authorizationStatus;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class Messaging implements FirebaseMessaging {
  AuthorizationStatus permission = AuthorizationStatus.authorized;
  int deletes = 0;
  @override
  Future<void> deleteToken() async {
    deletes++;
  }

  @override
  Future<NotificationSettings> getNotificationSettings() async =>
      Settings(permission);
  @override
  Future<String?> getToken({
    String? vapidKey,
    String? serviceWorkerScriptPath,
  }) async => 'test-device-token';
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'driver device registration retries and clears its token on account change and logout',
    () async {
      var fail = true;
      final posts = <Map>[];
      final api = replacementClient(
        authenticate: false,
        dio: Dio()
          ..interceptors.add(
            InterceptorsWrapper(
              onRequest: (o, h) {
                posts.add(Map.from(o.data as Map));
                if (fail) {
                  h.reject(DioException(requestOptions: o));
                  return;
                }
                h.resolve(
                  Response(
                    requestOptions: o,
                    statusCode: 200,
                    data: {
                      'data': {
                        'id': 'device',
                        'platform': 'android',
                        'updatedAt': '2026-09-19T12:00:00Z',
                      },
                    },
                  ),
                );
              },
            ),
          ),
      );
      final messaging = Messaging();
      final alerts = DriverNotifications(
        api: api,
        refresh: () async {},
        messaging: messaging,
      );
      addTearDown(alerts.dispose);
      alerts.setOwner('driver-a');
      await alerts.sync();
      expect(alerts.enabled, isFalse);
      fail = false;
      await alerts.sync();
      expect(alerts.enabled, isTrue);
      expect(posts.last, {'platform': 'android', 'token': 'test-device-token'});
      messaging.permission = AuthorizationStatus.denied;
      await alerts.sync();
      expect(alerts.enabled, isFalse);
      messaging.permission = AuthorizationStatus.authorized;
      alerts.setOwner('driver-b');
      await alerts.sync();
      expect(messaging.deletes, 1);
      expect(alerts.enabled, isTrue);
      alerts.setOwner(null);
      await alerts.sync();
      expect(messaging.deletes, greaterThanOrEqualTo(2));
      expect(alerts.enabled, isFalse);
      expect(
        await api.store.storage.read(
          '${api.store.scope.storageKey}.push-owner',
        ),
        isNull,
      );
    },
  );

  test('denied permission never registers a push device', () async {
    var posts = 0;
    final api = replacementClient(
      authenticate: false,
      dio: Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (o, h) {
              posts++;
              h.reject(DioException(requestOptions: o));
            },
          ),
        ),
    );
    final alerts = DriverNotifications(
      api: api,
      refresh: () async {},
      messaging: Messaging()..permission = AuthorizationStatus.denied,
    );
    addTearDown(alerts.dispose);
    alerts.setOwner('driver');
    await alerts.sync();
    expect(posts, 0);
    expect(alerts.enabled, isFalse);
    expect(alerts.status, contains('Alerts are off'));
  });
}

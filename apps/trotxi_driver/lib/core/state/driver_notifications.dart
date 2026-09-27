import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import '../api/driver_api.dart';
import 'foreground_refresh.dart';

/// Push is a hint to re-read current assignments, never an authorization source.
/// Lock-screen messages carry no route, trip, driver or rider information.
class DriverNotifications extends ChangeNotifier {
  DriverNotifications({
    required this.api,
    required this.refresh,
    this._messaging,
  });
  final DriverApi api;
  final Future<void> Function() refresh;
  final FirebaseMessaging? _messaging;
  FirebaseMessaging get messaging => _messaging ?? FirebaseMessaging.instance;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  final Set<String> _seen = {};
  ForegroundRefresh? _retry;
  String? _owner;
  bool _disposed = false;
  bool _busy = false;
  bool enabled = false;
  String status = 'Enable assignment alerts on this device.';
  String? notice;
  Future<void> _tail = Future.value();

  void start() {
    unawaited(sync());
    try {
      _subscriptions.add(FirebaseMessaging.onMessage.listen(_message));
      _subscriptions.add(FirebaseMessaging.onMessageOpenedApp.listen(_message));
      _subscriptions.add(
        messaging.onTokenRefresh.listen(
          (_) => unawaited(sync()),
          onError: (Object _) {},
        ),
      );
      _retry = ForegroundRefresh(() async {
        if (_owner != null && !enabled) await sync();
      }, interval: const Duration(seconds: 30));
      messaging
          .getInitialMessage()
          .then((m) {
            if (m != null) _message(m);
          })
          .catchError((Object _) {});
    } catch (_) {
      status =
          'Notifications are unavailable. You can still refresh your schedule.';
    }
  }

  void setOwner(String? owner) {
    if (_owner == owner) return;
    _owner = owner;
    enabled = false;
    notice = null;
    _seen.clear();
    unawaited(sync());
  }

  Future<void> enable() async {
    try {
      await messaging.requestPermission(alert: true, badge: true, sound: true);
      await sync();
    } catch (_) {
      status =
          'Notifications are unavailable. You can still refresh your schedule.';
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> sync() {
    final task = _tail.then((_) => _sync());
    _tail = task.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return task;
  }

  Future<void> _sync() async {
    if (_disposed) return;
    final owner = _owner;
    final generation = api.store.generation;
    final key = '${api.store.scope.storageKey}.push-owner';
    _busy = true;
    enabled = false;
    try {
      final previous = await api.store.storage.read(key);
      if (owner == null || (previous != null && previous != owner)) {
        await messaging.deleteToken();
        await api.store.storage.delete(key);
      }
      if (_disposed || owner != _owner || owner == null) return;
      final permission = await messaging.getNotificationSettings();
      if (permission.authorizationStatus != AuthorizationStatus.authorized &&
          permission.authorizationStatus != AuthorizationStatus.provisional) {
        status = 'Alerts are off. Enable them here or in your phone settings.';
        return;
      }
      if (defaultTargetPlatform == TargetPlatform.iOS &&
          await messaging.getAPNSToken() == null) {
        status = 'Apple push setup is not available on this device yet.';
        return;
      }
      final token = await messaging.getToken();
      if (token == null || _disposed || owner != _owner) return;
      api.ensureSession(generation);
      await api.post(
        '/v1/me/devices',
        wire.DeviceResponse.serializer,
        body: {'platform': api.metadata.platform, 'token': token},
      );
      if (_disposed || owner != _owner) return;
      await api.store.storage.write(key, owner);
      enabled = true;
      status = 'Assignment alerts enabled on this device.';
    } catch (_) {
      enabled = false;
      status =
          'Could not register alerts. We will retry while the app is open.';
    } finally {
      _busy = false;
      if (!_disposed) notifyListeners();
    }
  }

  void _message(RemoteMessage message) {
    if (_disposed ||
        _owner == null ||
        message.data['type'] != 'driver_assignment') {
      return;
    }
    final id = message.data['notificationId'];
    if (id is! String || !_seen.add(id)) return;
    if (_seen.length > 100) _seen.remove(_seen.first);
    notice = 'Operations updated your schedule. Check your assignments.';
    notifyListeners();
    unawaited(refresh());
  }

  bool get busy => _busy;
  void dismiss() {
    notice = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _retry?.dispose();
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    super.dispose();
  }
}

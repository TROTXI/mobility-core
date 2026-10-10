import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';

/// Push is only a prompt to open the server-owned inbox. Payload fields never
/// grant access to a reservation or select a rider account.
class CommuterNotifications extends ChangeNotifier {
  CommuterNotifications({
    required this.api,
    required this.openInbox,
    required this.showForegroundNotice,
    this.messagingOverride,
  });

  final CommuterApi api;
  final VoidCallback openInbox;
  final VoidCallback showForegroundNotice;
  final FirebaseMessaging? messagingOverride;
  FirebaseMessaging get messaging =>
      messagingOverride ?? FirebaseMessaging.instance;

  final List<StreamSubscription<dynamic>> _subscriptions = [];
  final Set<String> _seenForeground = {};
  Future<void> _tail = Future.value();
  String? _owner;
  String? _lastOpened;
  bool _disposed = false;
  bool enabled = false;
  String status = 'Enable ride alerts on this device.';

  void start() {
    try {
      _subscriptions.add(FirebaseMessaging.onMessage.listen(_foreground));
      _subscriptions.add(FirebaseMessaging.onMessageOpenedApp.listen(_opened));
      _subscriptions.add(
        messaging.onTokenRefresh.listen(
          (_) => unawaited(sync()),
          onError: (Object _) {},
        ),
      );
      messaging
          .getInitialMessage()
          .then((message) {
            if (message != null) _opened(message);
          })
          .catchError((Object _) {});
    } catch (_) {
      status = 'Push alerts are unavailable. Your inbox is still available.';
      notifyListeners();
    }
  }

  void setOwner(String? owner) {
    if (_owner == owner) return;
    _owner = owner;
    enabled = false;
    _lastOpened = null;
    _seenForeground.clear();
    unawaited(sync());
  }

  Future<void> enable() async {
    final owner = _owner;
    final generation = api.store.generation;
    if (_disposed || owner == null) return;
    try {
      final permission = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (permission.authorizationStatus != AuthorizationStatus.authorized &&
          permission.authorizationStatus != AuthorizationStatus.provisional) {
        status = 'Alerts are off. You can enable them in your phone settings.';
        notifyListeners();
        return;
      }
      if (_disposed || owner != _owner) return;
      api.ensureSession(generation);
      await api.store.storage.write(
        '${api.store.scope.storageKey}.push-consent.$owner',
        'enabled',
      );
      if (_disposed || owner != _owner) return;
      await sync();
    } catch (_) {
      status = 'Could not enable push alerts. Your inbox is still available.';
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
    try {
      final previous = await api.store.storage.read(key);
      if (previous != null && previous != owner) {
        await messaging.deleteToken();
        await api.store.storage.delete(key);
      }
      if (_disposed || owner == null || owner != _owner) return;
      final consent = await api.store.storage.read(
        '${api.store.scope.storageKey}.push-consent.$owner',
      );
      if (_disposed || owner != _owner) return;
      if (consent != 'enabled') {
        enabled = false;
        status = 'Enable ride alerts on this device.';
        return;
      }
      final permission = await messaging.getNotificationSettings();
      if (permission.authorizationStatus != AuthorizationStatus.authorized &&
          permission.authorizationStatus != AuthorizationStatus.provisional) {
        enabled = false;
        status = 'Alerts are off. Enable them here or in your phone settings.';
        return;
      }
      if (defaultTargetPlatform == TargetPlatform.iOS &&
          await messaging.getAPNSToken() == null) {
        enabled = false;
        status = 'Apple push is not available on this device yet.';
        return;
      }
      final token = await messaging.getToken();
      if (token == null || _disposed || owner != _owner) return;
      api.ensureSession(generation);
      await api.registerPushDevice(token);
      if (_disposed || owner != _owner) return;
      await api.store.storage.write(key, owner);
      enabled = true;
      status = 'Ride alerts are enabled on this device.';
    } catch (_) {
      enabled = false;
      status = 'Could not register alerts. We will retry when the app opens.';
    } finally {
      if (!_disposed) notifyListeners();
    }
  }

  bool _isRidePrompt(RemoteMessage message) =>
      !_disposed && message.data['type'] == 'reservation_prompt';

  void _foreground(RemoteMessage message) {
    if (_owner == null || !_isRidePrompt(message)) return;
    final id = message.data['notificationId'];
    if (id is! String || id.isEmpty || !_seenForeground.add(id)) return;
    if (_seenForeground.length > 100) {
      _seenForeground.remove(_seenForeground.first);
    }
    showForegroundNotice();
  }

  void _opened(RemoteMessage message) {
    if (!_isRidePrompt(message)) return;
    final id = message.data['notificationId'];
    if (id is! String || id.isEmpty || id == _lastOpened) return;
    _lastOpened = id;
    openInbox();
  }

  @override
  void dispose() {
    _disposed = true;
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    super.dispose();
  }
}

class CommuterNotificationsScope
    extends InheritedNotifier<CommuterNotifications> {
  const CommuterNotificationsScope({
    super.key,
    required CommuterNotifications notifications,
    required super.child,
  }) : super(notifier: notifications);

  static CommuterNotifications? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<CommuterNotificationsScope>()
      ?.notifier;
}

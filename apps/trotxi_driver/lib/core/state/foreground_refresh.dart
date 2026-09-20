import 'dart:async';
import 'package:flutter/widgets.dart';

/// Bounded, non-overlapping reads. Never polls while the application is hidden.
class ForegroundRefresh with WidgetsBindingObserver {
  ForegroundRefresh(
    this.refresh, {
    this.interval = const Duration(seconds: 5),
  }) {
    WidgetsBinding.instance.addObserver(this);
    _resume();
  }
  final Future<void> Function() refresh;
  final Duration interval;
  Timer? _timer;
  bool _busy = false;
  bool _disposed = false;
  Future<void> tick() async {
    final state = WidgetsBinding.instance.lifecycleState;
    if (_disposed ||
        _busy ||
        (state != null && state != AppLifecycleState.resumed)) {
      return;
    }
    _busy = true;
    try {
      await refresh();
    } finally {
      _busy = false;
    }
  }

  void _resume() {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => unawaited(tick()));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _timer?.cancel();
    if (!_disposed && state == AppLifecycleState.resumed) {
      _resume();
      unawaited(tick());
    }
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }
}

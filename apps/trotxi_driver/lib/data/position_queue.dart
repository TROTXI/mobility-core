import 'dart:convert';
import 'package:trotxi_client/scoped_token_store.dart';

/// One encrypted, backend-scoped record in production. Writes are serialized;
/// enqueue commits before upload and acknowledgement commits before removal.
/// A full queue refuses new fixes instead of silently evicting unsent evidence.
class PositionQueue {
  PositionQueue({
    this.storage,
    this.key = 'driver-gps',
    this.limit = 1440,
    DateTime Function()? now,
  }) : now = now ?? DateTime.now;
  final DateTime Function() now;
  int expiredFixes = 0;
  final SessionStorage? storage;
  final String key;
  final int limit;
  String? _owner;
  List<Map<String, dynamic>> _rows = [];
  Future<void> _tail = Future.value();
  List<Map<String, dynamic>> get rows => List.unmodifiable(_rows);
  Future<T> _serial<T>(Future<T> Function() action) {
    final task = _tail.then((_) => action());
    _tail = task.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return task;
  }

  Future<void> bind(String? owner) => _serial(() async {
    final raw = await storage?.read(key);
    var rows = <Map<String, dynamic>>[];
    var expired = 0;
    if (owner != null && raw != null) {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      if (data['owner'] == owner) {
        rows = (data['rows'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        if (rows.length > limit) throw StateError('GPS queue exceeds capacity');
        expired = (data['expiredFixes'] as int?) ?? 0;
        final cutoff = now().subtract(const Duration(hours: 24));
        final retained = rows
            .where(
              (r) => DateTime.parse(r['capturedAt'] as String).isAfter(cutoff),
            )
            .toList();
        expired += rows.length - retained.length;
        rows = retained;
      }
    }
    // Never carry a previous driver's coordinates into the next login.
    if (owner == null || (raw != null && rows.isEmpty)) {
      await storage?.delete(key);
    }
    _owner = owner;
    expiredFixes = expired;
    await _save(rows);
  });
  Future<void> _save(List<Map<String, dynamic>> rows) async {
    if (storage != null && _owner == null && rows.isNotEmpty) {
      throw StateError('GPS queue has no owner');
    }
    if (rows.isEmpty && expiredFixes == 0) {
      await storage?.delete(key);
    } else {
      await storage?.write(
        key,
        jsonEncode({
          'owner': _owner,
          'rows': rows,
          'expiredFixes': expiredFixes,
        }),
      );
    }
    _rows = rows;
  }

  Future<void> add(Map<String, dynamic> row) => _serial(() async {
    if (_rows.length >= limit) throw StateError('GPS queue is full');
    final next = [..._rows, Map<String, dynamic>.from(row)];
    next.sort(
      (a, b) =>
          (a['capturedAt'] as String).compareTo(b['capturedAt'] as String),
    );
    await _save(next);
  });
  Future<void> acknowledge(String id) =>
      _serial(() => _save(_rows.where((r) => r['clientFixId'] != id).toList()));
  Future<void> pruneExpired() => _serial(() async {
    final cutoff = now().subtract(const Duration(hours: 24));
    final retained = _rows
        .where((r) => DateTime.parse(r['capturedAt'] as String).isAfter(cutoff))
        .toList();
    if (retained.length == _rows.length) return;
    final previous = expiredFixes;
    expiredFixes += _rows.length - retained.length;
    try {
      await _save(retained);
    } catch (_) {
      expiredFixes = previous;
      rethrow;
    }
  });
  Future<void> acknowledgeExpiry() => _serial(() async {
    final previous = expiredFixes;
    expiredFixes = 0;
    try {
      await _save(_rows);
    } catch (_) {
      expiredFixes = previous;
      rethrow;
    }
  });
}

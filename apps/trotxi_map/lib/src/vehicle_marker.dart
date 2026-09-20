import 'dart:async';
import 'dart:math' as math;

import 'package:maplibre_gl/maplibre_gl.dart';

/// A short visual transition between two *reported* positions. It never
/// predicts the next fix. Large jumps and stale/reconnected readings snap.
class VehicleMotion {
  VehicleMotion({
    this.duration = const Duration(milliseconds: 800),
    this.maxTransitionMeters = 250,
  });

  final Duration duration;
  final double maxTransitionMeters;
  LatLng? _from, _to;
  DateTime? _started, _sampleAt;
  bool _moving = false;

  LatLng? get position => _to;
  bool get moving => _moving;

  void clear() {
    _from = _to = null;
    _sampleAt = _started = null;
    _moving = false;
  }

  /// `fresh` is calculated from server age, not the handset wall clock.
  /// Pass the server receipt as sampleAt. Duplicate/older receipts cannot send
  /// the marker backwards, including after a device clock correction.
  void accept(
    LatLng point,
    DateTime sampleAt,
    DateTime now, {
    required bool fresh,
  }) {
    if (_sampleAt != null && !sampleAt.isAfter(_sampleAt!)) return;
    final start = at(now);
    _sampleAt = sampleAt;
    _to = point;
    final meters = start == null
        ? double.infinity
        : distanceMeters(start, point);
    _moving =
        fresh && start != null && meters > 0.5 && meters <= maxTransitionMeters;
    _from = _moving ? start : point;
    _started = now;
  }

  LatLng? at(DateTime now) {
    final target = _to;
    if (target == null || !_moving) return target;
    final elapsed = now.difference(_started!).inMicroseconds;
    final total = duration.inMicroseconds;
    if (elapsed >= total || elapsed < 0) {
      _moving = false;
      return target;
    }
    final t = elapsed / total;
    final start = _from!;
    return LatLng(
      start.latitude + (target.latitude - start.latitude) * t,
      start.longitude + (target.longitude - start.longitude) * t,
    );
  }

  static double distanceMeters(LatLng a, LatLng b) {
    const radius = 6371000.0;
    final p1 = a.latitude * math.pi / 180;
    final p2 = b.latitude * math.pi / 180;
    final dp = (b.latitude - a.latitude) * math.pi / 180;
    final dl = (b.longitude - a.longitude) * math.pi / 180;
    final h =
        math.pow(math.sin(dp / 2), 2) +
        math.cos(p1) * math.cos(p2) * math.pow(math.sin(dl / 2), 2);
    return 2 * radius * math.asin(math.sqrt(h.clamp(0, 1)));
  }
}

/// Owns one MapLibre circle. Route and stop annotations belong to the screen.
class VehicleMarker {
  VehicleMarker({required this.options, DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final CircleOptions Function(LatLng, bool fresh) options;
  final DateTime Function() _now;
  final VehicleMotion motion = VehicleMotion();
  MapLibreMapController? _controller;
  Circle? _circle;
  Timer? _timer;
  bool _busy = false, _disposed = false, _pending = false;
  bool _fresh = false;
  int _epoch = 0;

  /// Call after the style loads. Previous style annotations no longer exist.
  void attach(MapLibreMapController controller) {
    _epoch++;
    _controller = controller;
    _circle = null;
    _schedule();
  }

  void accept(LatLng point, DateTime sampleAt, {required bool fresh}) {
    if (_disposed) return;
    _fresh = fresh;
    motion.accept(point, sampleAt, _now(), fresh: fresh);
    _timer?.cancel();
    _schedule();
    if (motion.moving) {
      _timer = Timer.periodic(const Duration(milliseconds: 60), (_) {
        _schedule();
        if (!motion.moving) {
          _timer?.cancel();
          _timer = null;
        }
      });
    }
  }

  /// Stop rendering when access ends, a trip ends, or a new trip opens.
  void clear() {
    _timer?.cancel();
    _fresh = false;
    motion.clear();
    _schedule();
  }

  void _schedule() {
    if (_disposed) return;
    if (_busy) {
      _pending = true;
      return;
    }
    unawaited(_draw());
  }

  Future<void> _draw() async {
    _busy = true;
    final epoch = _epoch;
    final controller = _controller;
    try {
      if (controller == null) return;
      final position = motion.at(_now());
      if (position == null) {
        final circle = _circle;
        _circle = null;
        if (circle != null) await controller.removeCircle(circle);
      } else if (_circle == null) {
        final circle = await controller.addCircle(options(position, _fresh));
        if (!_disposed && epoch == _epoch) _circle = circle;
      } else {
        await controller.updateCircle(_circle!, options(position, _fresh));
      }
    } catch (_) {
      // A native map can disappear during style change or navigation. The next
      // style callback will attach a new controller and draw the latest fix.
    } finally {
      _busy = false;
      if (_pending && !_disposed) {
        _pending = false;
        _schedule();
      }
    }
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _controller = null;
    _circle = null;
    motion.clear();
  }
}

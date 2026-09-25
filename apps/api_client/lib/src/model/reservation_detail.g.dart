// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_detail.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReservationDetail extends ReservationDetail {
  @override
  final Reservation reservation;
  @override
  final ReservationDetailRoute? route;
  @override
  final ReservationDetailTrip? trip;
  @override
  final ReservationDetailPickupStop? pickupStop;
  @override
  final ReservationDetailPickupStop? dropoffStop;

  factory _$ReservationDetail(
          [void Function(ReservationDetailBuilder)? updates]) =>
      (ReservationDetailBuilder()..update(updates))._build();

  _$ReservationDetail._(
      {required this.reservation,
      this.route,
      this.trip,
      this.pickupStop,
      this.dropoffStop})
      : super._();
  @override
  ReservationDetail rebuild(void Function(ReservationDetailBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReservationDetailBuilder toBuilder() =>
      ReservationDetailBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReservationDetail &&
        reservation == other.reservation &&
        route == other.route &&
        trip == other.trip &&
        pickupStop == other.pickupStop &&
        dropoffStop == other.dropoffStop;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reservation.hashCode);
    _$hash = $jc(_$hash, route.hashCode);
    _$hash = $jc(_$hash, trip.hashCode);
    _$hash = $jc(_$hash, pickupStop.hashCode);
    _$hash = $jc(_$hash, dropoffStop.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReservationDetail')
          ..add('reservation', reservation)
          ..add('route', route)
          ..add('trip', trip)
          ..add('pickupStop', pickupStop)
          ..add('dropoffStop', dropoffStop))
        .toString();
  }
}

class ReservationDetailBuilder
    implements Builder<ReservationDetail, ReservationDetailBuilder> {
  _$ReservationDetail? _$v;

  ReservationBuilder? _reservation;
  ReservationBuilder get reservation =>
      _$this._reservation ??= ReservationBuilder();
  set reservation(ReservationBuilder? reservation) =>
      _$this._reservation = reservation;

  ReservationDetailRouteBuilder? _route;
  ReservationDetailRouteBuilder get route =>
      _$this._route ??= ReservationDetailRouteBuilder();
  set route(ReservationDetailRouteBuilder? route) => _$this._route = route;

  ReservationDetailTripBuilder? _trip;
  ReservationDetailTripBuilder get trip =>
      _$this._trip ??= ReservationDetailTripBuilder();
  set trip(ReservationDetailTripBuilder? trip) => _$this._trip = trip;

  ReservationDetailPickupStopBuilder? _pickupStop;
  ReservationDetailPickupStopBuilder get pickupStop =>
      _$this._pickupStop ??= ReservationDetailPickupStopBuilder();
  set pickupStop(ReservationDetailPickupStopBuilder? pickupStop) =>
      _$this._pickupStop = pickupStop;

  ReservationDetailPickupStopBuilder? _dropoffStop;
  ReservationDetailPickupStopBuilder get dropoffStop =>
      _$this._dropoffStop ??= ReservationDetailPickupStopBuilder();
  set dropoffStop(ReservationDetailPickupStopBuilder? dropoffStop) =>
      _$this._dropoffStop = dropoffStop;

  ReservationDetailBuilder() {
    ReservationDetail._defaults(this);
  }

  ReservationDetailBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reservation = $v.reservation.toBuilder();
      _route = $v.route?.toBuilder();
      _trip = $v.trip?.toBuilder();
      _pickupStop = $v.pickupStop?.toBuilder();
      _dropoffStop = $v.dropoffStop?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReservationDetail other) {
    _$v = other as _$ReservationDetail;
  }

  @override
  void update(void Function(ReservationDetailBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReservationDetail build() => _build();

  _$ReservationDetail _build() {
    _$ReservationDetail _$result;
    try {
      _$result = _$v ??
          _$ReservationDetail._(
            reservation: reservation.build(),
            route: _route?.build(),
            trip: _trip?.build(),
            pickupStop: _pickupStop?.build(),
            dropoffStop: _dropoffStop?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'reservation';
        reservation.build();
        _$failedField = 'route';
        _route?.build();
        _$failedField = 'trip';
        _trip?.build();
        _$failedField = 'pickupStop';
        _pickupStop?.build();
        _$failedField = 'dropoffStop';
        _dropoffStop?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ReservationDetail', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

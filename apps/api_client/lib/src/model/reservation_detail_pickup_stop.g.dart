// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_detail_pickup_stop.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReservationDetailPickupStop extends ReservationDetailPickupStop {
  @override
  final String occurrenceId;
  @override
  final String name;
  @override
  final Point location;
  @override
  final int ordinal;

  factory _$ReservationDetailPickupStop(
          [void Function(ReservationDetailPickupStopBuilder)? updates]) =>
      (ReservationDetailPickupStopBuilder()..update(updates))._build();

  _$ReservationDetailPickupStop._(
      {required this.occurrenceId,
      required this.name,
      required this.location,
      required this.ordinal})
      : super._();
  @override
  ReservationDetailPickupStop rebuild(
          void Function(ReservationDetailPickupStopBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReservationDetailPickupStopBuilder toBuilder() =>
      ReservationDetailPickupStopBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReservationDetailPickupStop &&
        occurrenceId == other.occurrenceId &&
        name == other.name &&
        location == other.location &&
        ordinal == other.ordinal;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, occurrenceId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, location.hashCode);
    _$hash = $jc(_$hash, ordinal.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReservationDetailPickupStop')
          ..add('occurrenceId', occurrenceId)
          ..add('name', name)
          ..add('location', location)
          ..add('ordinal', ordinal))
        .toString();
  }
}

class ReservationDetailPickupStopBuilder
    implements
        Builder<ReservationDetailPickupStop,
            ReservationDetailPickupStopBuilder> {
  _$ReservationDetailPickupStop? _$v;

  String? _occurrenceId;
  String? get occurrenceId => _$this._occurrenceId;
  set occurrenceId(String? occurrenceId) => _$this._occurrenceId = occurrenceId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  PointBuilder? _location;
  PointBuilder get location => _$this._location ??= PointBuilder();
  set location(PointBuilder? location) => _$this._location = location;

  int? _ordinal;
  int? get ordinal => _$this._ordinal;
  set ordinal(int? ordinal) => _$this._ordinal = ordinal;

  ReservationDetailPickupStopBuilder() {
    ReservationDetailPickupStop._defaults(this);
  }

  ReservationDetailPickupStopBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _occurrenceId = $v.occurrenceId;
      _name = $v.name;
      _location = $v.location.toBuilder();
      _ordinal = $v.ordinal;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReservationDetailPickupStop other) {
    _$v = other as _$ReservationDetailPickupStop;
  }

  @override
  void update(void Function(ReservationDetailPickupStopBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReservationDetailPickupStop build() => _build();

  _$ReservationDetailPickupStop _build() {
    _$ReservationDetailPickupStop _$result;
    try {
      _$result = _$v ??
          _$ReservationDetailPickupStop._(
            occurrenceId: BuiltValueNullFieldError.checkNotNull(
                occurrenceId, r'ReservationDetailPickupStop', 'occurrenceId'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'ReservationDetailPickupStop', 'name'),
            location: location.build(),
            ordinal: BuiltValueNullFieldError.checkNotNull(
                ordinal, r'ReservationDetailPickupStop', 'ordinal'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'location';
        location.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ReservationDetailPickupStop', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

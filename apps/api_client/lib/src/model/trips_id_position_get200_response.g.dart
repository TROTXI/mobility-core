// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trips_id_position_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TripsIdPositionGet200Response extends TripsIdPositionGet200Response {
  @override
  final String tripId;
  @override
  final TripsIdPositionGet200ResponsePosition position;
  @override
  final BuiltList<TripsIdPositionGet200ResponseEtaToStopsInner> etaToStops;

  factory _$TripsIdPositionGet200Response(
          [void Function(TripsIdPositionGet200ResponseBuilder)? updates]) =>
      (TripsIdPositionGet200ResponseBuilder()..update(updates))._build();

  _$TripsIdPositionGet200Response._(
      {required this.tripId, required this.position, required this.etaToStops})
      : super._();
  @override
  TripsIdPositionGet200Response rebuild(
          void Function(TripsIdPositionGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TripsIdPositionGet200ResponseBuilder toBuilder() =>
      TripsIdPositionGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TripsIdPositionGet200Response &&
        tripId == other.tripId &&
        position == other.position &&
        etaToStops == other.etaToStops;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jc(_$hash, position.hashCode);
    _$hash = $jc(_$hash, etaToStops.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TripsIdPositionGet200Response')
          ..add('tripId', tripId)
          ..add('position', position)
          ..add('etaToStops', etaToStops))
        .toString();
  }
}

class TripsIdPositionGet200ResponseBuilder
    implements
        Builder<TripsIdPositionGet200Response,
            TripsIdPositionGet200ResponseBuilder> {
  _$TripsIdPositionGet200Response? _$v;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  TripsIdPositionGet200ResponsePositionBuilder? _position;
  TripsIdPositionGet200ResponsePositionBuilder get position =>
      _$this._position ??= TripsIdPositionGet200ResponsePositionBuilder();
  set position(TripsIdPositionGet200ResponsePositionBuilder? position) =>
      _$this._position = position;

  ListBuilder<TripsIdPositionGet200ResponseEtaToStopsInner>? _etaToStops;
  ListBuilder<TripsIdPositionGet200ResponseEtaToStopsInner> get etaToStops =>
      _$this._etaToStops ??=
          ListBuilder<TripsIdPositionGet200ResponseEtaToStopsInner>();
  set etaToStops(
          ListBuilder<TripsIdPositionGet200ResponseEtaToStopsInner>?
              etaToStops) =>
      _$this._etaToStops = etaToStops;

  TripsIdPositionGet200ResponseBuilder() {
    TripsIdPositionGet200Response._defaults(this);
  }

  TripsIdPositionGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _tripId = $v.tripId;
      _position = $v.position.toBuilder();
      _etaToStops = $v.etaToStops.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TripsIdPositionGet200Response other) {
    _$v = other as _$TripsIdPositionGet200Response;
  }

  @override
  void update(void Function(TripsIdPositionGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TripsIdPositionGet200Response build() => _build();

  _$TripsIdPositionGet200Response _build() {
    _$TripsIdPositionGet200Response _$result;
    try {
      _$result = _$v ??
          _$TripsIdPositionGet200Response._(
            tripId: BuiltValueNullFieldError.checkNotNull(
                tripId, r'TripsIdPositionGet200Response', 'tripId'),
            position: position.build(),
            etaToStops: etaToStops.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'position';
        position.build();
        _$failedField = 'etaToStops';
        etaToStops.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TripsIdPositionGet200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trips_id_position_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TripsIdPositionPost200Response extends TripsIdPositionPost200Response {
  @override
  final String tripId;
  @override
  final TripsIdPositionGet200ResponsePosition position;

  factory _$TripsIdPositionPost200Response(
          [void Function(TripsIdPositionPost200ResponseBuilder)? updates]) =>
      (TripsIdPositionPost200ResponseBuilder()..update(updates))._build();

  _$TripsIdPositionPost200Response._(
      {required this.tripId, required this.position})
      : super._();
  @override
  TripsIdPositionPost200Response rebuild(
          void Function(TripsIdPositionPost200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TripsIdPositionPost200ResponseBuilder toBuilder() =>
      TripsIdPositionPost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TripsIdPositionPost200Response &&
        tripId == other.tripId &&
        position == other.position;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jc(_$hash, position.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TripsIdPositionPost200Response')
          ..add('tripId', tripId)
          ..add('position', position))
        .toString();
  }
}

class TripsIdPositionPost200ResponseBuilder
    implements
        Builder<TripsIdPositionPost200Response,
            TripsIdPositionPost200ResponseBuilder> {
  _$TripsIdPositionPost200Response? _$v;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  TripsIdPositionGet200ResponsePositionBuilder? _position;
  TripsIdPositionGet200ResponsePositionBuilder get position =>
      _$this._position ??= TripsIdPositionGet200ResponsePositionBuilder();
  set position(TripsIdPositionGet200ResponsePositionBuilder? position) =>
      _$this._position = position;

  TripsIdPositionPost200ResponseBuilder() {
    TripsIdPositionPost200Response._defaults(this);
  }

  TripsIdPositionPost200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _tripId = $v.tripId;
      _position = $v.position.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TripsIdPositionPost200Response other) {
    _$v = other as _$TripsIdPositionPost200Response;
  }

  @override
  void update(void Function(TripsIdPositionPost200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TripsIdPositionPost200Response build() => _build();

  _$TripsIdPositionPost200Response _build() {
    _$TripsIdPositionPost200Response _$result;
    try {
      _$result = _$v ??
          _$TripsIdPositionPost200Response._(
            tripId: BuiltValueNullFieldError.checkNotNull(
                tripId, r'TripsIdPositionPost200Response', 'tripId'),
            position: position.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'position';
        position.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TripsIdPositionPost200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

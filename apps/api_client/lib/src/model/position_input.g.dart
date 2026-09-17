// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'position_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PositionInput extends PositionInput {
  @override
  final String clientFixId;
  @override
  final DateTime capturedAt;
  @override
  final num latitude;
  @override
  final num longitude;
  @override
  final num? accuracyMeters;

  factory _$PositionInput([void Function(PositionInputBuilder)? updates]) =>
      (PositionInputBuilder()..update(updates))._build();

  _$PositionInput._(
      {required this.clientFixId,
      required this.capturedAt,
      required this.latitude,
      required this.longitude,
      this.accuracyMeters})
      : super._();
  @override
  PositionInput rebuild(void Function(PositionInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PositionInputBuilder toBuilder() => PositionInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PositionInput &&
        clientFixId == other.clientFixId &&
        capturedAt == other.capturedAt &&
        latitude == other.latitude &&
        longitude == other.longitude &&
        accuracyMeters == other.accuracyMeters;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientFixId.hashCode);
    _$hash = $jc(_$hash, capturedAt.hashCode);
    _$hash = $jc(_$hash, latitude.hashCode);
    _$hash = $jc(_$hash, longitude.hashCode);
    _$hash = $jc(_$hash, accuracyMeters.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PositionInput')
          ..add('clientFixId', clientFixId)
          ..add('capturedAt', capturedAt)
          ..add('latitude', latitude)
          ..add('longitude', longitude)
          ..add('accuracyMeters', accuracyMeters))
        .toString();
  }
}

class PositionInputBuilder
    implements Builder<PositionInput, PositionInputBuilder> {
  _$PositionInput? _$v;

  String? _clientFixId;
  String? get clientFixId => _$this._clientFixId;
  set clientFixId(String? clientFixId) => _$this._clientFixId = clientFixId;

  DateTime? _capturedAt;
  DateTime? get capturedAt => _$this._capturedAt;
  set capturedAt(DateTime? capturedAt) => _$this._capturedAt = capturedAt;

  num? _latitude;
  num? get latitude => _$this._latitude;
  set latitude(num? latitude) => _$this._latitude = latitude;

  num? _longitude;
  num? get longitude => _$this._longitude;
  set longitude(num? longitude) => _$this._longitude = longitude;

  num? _accuracyMeters;
  num? get accuracyMeters => _$this._accuracyMeters;
  set accuracyMeters(num? accuracyMeters) =>
      _$this._accuracyMeters = accuracyMeters;

  PositionInputBuilder() {
    PositionInput._defaults(this);
  }

  PositionInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientFixId = $v.clientFixId;
      _capturedAt = $v.capturedAt;
      _latitude = $v.latitude;
      _longitude = $v.longitude;
      _accuracyMeters = $v.accuracyMeters;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PositionInput other) {
    _$v = other as _$PositionInput;
  }

  @override
  void update(void Function(PositionInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PositionInput build() => _build();

  _$PositionInput _build() {
    final _$result = _$v ??
        _$PositionInput._(
          clientFixId: BuiltValueNullFieldError.checkNotNull(
              clientFixId, r'PositionInput', 'clientFixId'),
          capturedAt: BuiltValueNullFieldError.checkNotNull(
              capturedAt, r'PositionInput', 'capturedAt'),
          latitude: BuiltValueNullFieldError.checkNotNull(
              latitude, r'PositionInput', 'latitude'),
          longitude: BuiltValueNullFieldError.checkNotNull(
              longitude, r'PositionInput', 'longitude'),
          accuracyMeters: accuracyMeters,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

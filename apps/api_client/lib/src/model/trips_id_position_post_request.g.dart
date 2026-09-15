// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trips_id_position_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TripsIdPositionPostRequest extends TripsIdPositionPostRequest {
  @override
  final num latitude;
  @override
  final num longitude;
  @override
  final DateTime? recordedAt;
  @override
  final String? clientFixId;

  factory _$TripsIdPositionPostRequest(
          [void Function(TripsIdPositionPostRequestBuilder)? updates]) =>
      (TripsIdPositionPostRequestBuilder()..update(updates))._build();

  _$TripsIdPositionPostRequest._(
      {required this.latitude,
      required this.longitude,
      this.recordedAt,
      this.clientFixId})
      : super._();
  @override
  TripsIdPositionPostRequest rebuild(
          void Function(TripsIdPositionPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TripsIdPositionPostRequestBuilder toBuilder() =>
      TripsIdPositionPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TripsIdPositionPostRequest &&
        latitude == other.latitude &&
        longitude == other.longitude &&
        recordedAt == other.recordedAt &&
        clientFixId == other.clientFixId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, latitude.hashCode);
    _$hash = $jc(_$hash, longitude.hashCode);
    _$hash = $jc(_$hash, recordedAt.hashCode);
    _$hash = $jc(_$hash, clientFixId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TripsIdPositionPostRequest')
          ..add('latitude', latitude)
          ..add('longitude', longitude)
          ..add('recordedAt', recordedAt)
          ..add('clientFixId', clientFixId))
        .toString();
  }
}

class TripsIdPositionPostRequestBuilder
    implements
        Builder<TripsIdPositionPostRequest, TripsIdPositionPostRequestBuilder> {
  _$TripsIdPositionPostRequest? _$v;

  num? _latitude;
  num? get latitude => _$this._latitude;
  set latitude(num? latitude) => _$this._latitude = latitude;

  num? _longitude;
  num? get longitude => _$this._longitude;
  set longitude(num? longitude) => _$this._longitude = longitude;

  DateTime? _recordedAt;
  DateTime? get recordedAt => _$this._recordedAt;
  set recordedAt(DateTime? recordedAt) => _$this._recordedAt = recordedAt;

  String? _clientFixId;
  String? get clientFixId => _$this._clientFixId;
  set clientFixId(String? clientFixId) => _$this._clientFixId = clientFixId;

  TripsIdPositionPostRequestBuilder() {
    TripsIdPositionPostRequest._defaults(this);
  }

  TripsIdPositionPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _latitude = $v.latitude;
      _longitude = $v.longitude;
      _recordedAt = $v.recordedAt;
      _clientFixId = $v.clientFixId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TripsIdPositionPostRequest other) {
    _$v = other as _$TripsIdPositionPostRequest;
  }

  @override
  void update(void Function(TripsIdPositionPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TripsIdPositionPostRequest build() => _build();

  _$TripsIdPositionPostRequest _build() {
    final _$result = _$v ??
        _$TripsIdPositionPostRequest._(
          latitude: BuiltValueNullFieldError.checkNotNull(
              latitude, r'TripsIdPositionPostRequest', 'latitude'),
          longitude: BuiltValueNullFieldError.checkNotNull(
              longitude, r'TripsIdPositionPostRequest', 'longitude'),
          recordedAt: recordedAt,
          clientFixId: clientFixId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

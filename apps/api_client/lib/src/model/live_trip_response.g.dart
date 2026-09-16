// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_trip_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$LiveTripResponse extends LiveTripResponse {
  @override
  final LiveTrip data;

  factory _$LiveTripResponse(
          [void Function(LiveTripResponseBuilder)? updates]) =>
      (LiveTripResponseBuilder()..update(updates))._build();

  _$LiveTripResponse._({required this.data}) : super._();
  @override
  LiveTripResponse rebuild(void Function(LiveTripResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LiveTripResponseBuilder toBuilder() =>
      LiveTripResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LiveTripResponse && data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LiveTripResponse')..add('data', data))
        .toString();
  }
}

class LiveTripResponseBuilder
    implements Builder<LiveTripResponse, LiveTripResponseBuilder> {
  _$LiveTripResponse? _$v;

  LiveTripBuilder? _data;
  LiveTripBuilder get data => _$this._data ??= LiveTripBuilder();
  set data(LiveTripBuilder? data) => _$this._data = data;

  LiveTripResponseBuilder() {
    LiveTripResponse._defaults(this);
  }

  LiveTripResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LiveTripResponse other) {
    _$v = other as _$LiveTripResponse;
  }

  @override
  void update(void Function(LiveTripResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LiveTripResponse build() => _build();

  _$LiveTripResponse _build() {
    _$LiveTripResponse _$result;
    try {
      _$result = _$v ??
          _$LiveTripResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'LiveTripResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

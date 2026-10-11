// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_rating_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RideRatingResponse extends RideRatingResponse {
  @override
  final RideRating data;

  factory _$RideRatingResponse(
          [void Function(RideRatingResponseBuilder)? updates]) =>
      (RideRatingResponseBuilder()..update(updates))._build();

  _$RideRatingResponse._({required this.data}) : super._();
  @override
  RideRatingResponse rebuild(
          void Function(RideRatingResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RideRatingResponseBuilder toBuilder() =>
      RideRatingResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RideRatingResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'RideRatingResponse')
          ..add('data', data))
        .toString();
  }
}

class RideRatingResponseBuilder
    implements Builder<RideRatingResponse, RideRatingResponseBuilder> {
  _$RideRatingResponse? _$v;

  RideRatingBuilder? _data;
  RideRatingBuilder get data => _$this._data ??= RideRatingBuilder();
  set data(RideRatingBuilder? data) => _$this._data = data;

  RideRatingResponseBuilder() {
    RideRatingResponse._defaults(this);
  }

  RideRatingResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RideRatingResponse other) {
    _$v = other as _$RideRatingResponse;
  }

  @override
  void update(void Function(RideRatingResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RideRatingResponse build() => _build();

  _$RideRatingResponse _build() {
    _$RideRatingResponse _$result;
    try {
      _$result = _$v ??
          _$RideRatingResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RideRatingResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

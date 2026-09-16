// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fare_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FareResponse extends FareResponse {
  @override
  final Fare data;

  factory _$FareResponse([void Function(FareResponseBuilder)? updates]) =>
      (FareResponseBuilder()..update(updates))._build();

  _$FareResponse._({required this.data}) : super._();
  @override
  FareResponse rebuild(void Function(FareResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FareResponseBuilder toBuilder() => FareResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FareResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'FareResponse')..add('data', data))
        .toString();
  }
}

class FareResponseBuilder
    implements Builder<FareResponse, FareResponseBuilder> {
  _$FareResponse? _$v;

  FareBuilder? _data;
  FareBuilder get data => _$this._data ??= FareBuilder();
  set data(FareBuilder? data) => _$this._data = data;

  FareResponseBuilder() {
    FareResponse._defaults(this);
  }

  FareResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FareResponse other) {
    _$v = other as _$FareResponse;
  }

  @override
  void update(void Function(FareResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FareResponse build() => _build();

  _$FareResponse _build() {
    _$FareResponse _$result;
    try {
      _$result = _$v ??
          _$FareResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'FareResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

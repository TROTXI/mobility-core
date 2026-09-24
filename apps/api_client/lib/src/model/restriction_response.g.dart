// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restriction_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RestrictionResponse extends RestrictionResponse {
  @override
  final Restriction data;

  factory _$RestrictionResponse(
          [void Function(RestrictionResponseBuilder)? updates]) =>
      (RestrictionResponseBuilder()..update(updates))._build();

  _$RestrictionResponse._({required this.data}) : super._();
  @override
  RestrictionResponse rebuild(
          void Function(RestrictionResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RestrictionResponseBuilder toBuilder() =>
      RestrictionResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RestrictionResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'RestrictionResponse')
          ..add('data', data))
        .toString();
  }
}

class RestrictionResponseBuilder
    implements Builder<RestrictionResponse, RestrictionResponseBuilder> {
  _$RestrictionResponse? _$v;

  RestrictionBuilder? _data;
  RestrictionBuilder get data => _$this._data ??= RestrictionBuilder();
  set data(RestrictionBuilder? data) => _$this._data = data;

  RestrictionResponseBuilder() {
    RestrictionResponse._defaults(this);
  }

  RestrictionResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RestrictionResponse other) {
    _$v = other as _$RestrictionResponse;
  }

  @override
  void update(void Function(RestrictionResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RestrictionResponse build() => _build();

  _$RestrictionResponse _build() {
    _$RestrictionResponse _$result;
    try {
      _$result = _$v ??
          _$RestrictionResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RestrictionResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

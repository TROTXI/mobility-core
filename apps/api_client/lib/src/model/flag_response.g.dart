// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flag_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FlagResponse extends FlagResponse {
  @override
  final Flag data;

  factory _$FlagResponse([void Function(FlagResponseBuilder)? updates]) =>
      (FlagResponseBuilder()..update(updates))._build();

  _$FlagResponse._({required this.data}) : super._();
  @override
  FlagResponse rebuild(void Function(FlagResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FlagResponseBuilder toBuilder() => FlagResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FlagResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'FlagResponse')..add('data', data))
        .toString();
  }
}

class FlagResponseBuilder
    implements Builder<FlagResponse, FlagResponseBuilder> {
  _$FlagResponse? _$v;

  FlagBuilder? _data;
  FlagBuilder get data => _$this._data ??= FlagBuilder();
  set data(FlagBuilder? data) => _$this._data = data;

  FlagResponseBuilder() {
    FlagResponse._defaults(this);
  }

  FlagResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FlagResponse other) {
    _$v = other as _$FlagResponse;
  }

  @override
  void update(void Function(FlagResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FlagResponse build() => _build();

  _$FlagResponse _build() {
    _$FlagResponse _$result;
    try {
      _$result = _$v ??
          _$FlagResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'FlagResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

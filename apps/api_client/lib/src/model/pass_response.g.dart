// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pass_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PassResponse extends PassResponse {
  @override
  final Pass data;

  factory _$PassResponse([void Function(PassResponseBuilder)? updates]) =>
      (PassResponseBuilder()..update(updates))._build();

  _$PassResponse._({required this.data}) : super._();
  @override
  PassResponse rebuild(void Function(PassResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PassResponseBuilder toBuilder() => PassResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PassResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PassResponse')..add('data', data))
        .toString();
  }
}

class PassResponseBuilder
    implements Builder<PassResponse, PassResponseBuilder> {
  _$PassResponse? _$v;

  PassBuilder? _data;
  PassBuilder get data => _$this._data ??= PassBuilder();
  set data(PassBuilder? data) => _$this._data = data;

  PassResponseBuilder() {
    PassResponse._defaults(this);
  }

  PassResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PassResponse other) {
    _$v = other as _$PassResponse;
  }

  @override
  void update(void Function(PassResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PassResponse build() => _build();

  _$PassResponse _build() {
    _$PassResponse _$result;
    try {
      _$result = _$v ??
          _$PassResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PassResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

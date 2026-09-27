// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'passkey_authentication_options_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PasskeyAuthenticationOptionsResponse
    extends PasskeyAuthenticationOptionsResponse {
  @override
  final PasskeyAuthenticationOptions data;

  factory _$PasskeyAuthenticationOptionsResponse(
          [void Function(PasskeyAuthenticationOptionsResponseBuilder)?
              updates]) =>
      (PasskeyAuthenticationOptionsResponseBuilder()..update(updates))._build();

  _$PasskeyAuthenticationOptionsResponse._({required this.data}) : super._();
  @override
  PasskeyAuthenticationOptionsResponse rebuild(
          void Function(PasskeyAuthenticationOptionsResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PasskeyAuthenticationOptionsResponseBuilder toBuilder() =>
      PasskeyAuthenticationOptionsResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PasskeyAuthenticationOptionsResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PasskeyAuthenticationOptionsResponse')
          ..add('data', data))
        .toString();
  }
}

class PasskeyAuthenticationOptionsResponseBuilder
    implements
        Builder<PasskeyAuthenticationOptionsResponse,
            PasskeyAuthenticationOptionsResponseBuilder> {
  _$PasskeyAuthenticationOptionsResponse? _$v;

  PasskeyAuthenticationOptionsBuilder? _data;
  PasskeyAuthenticationOptionsBuilder get data =>
      _$this._data ??= PasskeyAuthenticationOptionsBuilder();
  set data(PasskeyAuthenticationOptionsBuilder? data) => _$this._data = data;

  PasskeyAuthenticationOptionsResponseBuilder() {
    PasskeyAuthenticationOptionsResponse._defaults(this);
  }

  PasskeyAuthenticationOptionsResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PasskeyAuthenticationOptionsResponse other) {
    _$v = other as _$PasskeyAuthenticationOptionsResponse;
  }

  @override
  void update(
      void Function(PasskeyAuthenticationOptionsResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PasskeyAuthenticationOptionsResponse build() => _build();

  _$PasskeyAuthenticationOptionsResponse _build() {
    _$PasskeyAuthenticationOptionsResponse _$result;
    try {
      _$result = _$v ??
          _$PasskeyAuthenticationOptionsResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PasskeyAuthenticationOptionsResponse',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

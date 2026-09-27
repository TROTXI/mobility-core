// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'passkey_status_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PasskeyStatusResponse extends PasskeyStatusResponse {
  @override
  final PasskeyStatus data;

  factory _$PasskeyStatusResponse(
          [void Function(PasskeyStatusResponseBuilder)? updates]) =>
      (PasskeyStatusResponseBuilder()..update(updates))._build();

  _$PasskeyStatusResponse._({required this.data}) : super._();
  @override
  PasskeyStatusResponse rebuild(
          void Function(PasskeyStatusResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PasskeyStatusResponseBuilder toBuilder() =>
      PasskeyStatusResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PasskeyStatusResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PasskeyStatusResponse')
          ..add('data', data))
        .toString();
  }
}

class PasskeyStatusResponseBuilder
    implements Builder<PasskeyStatusResponse, PasskeyStatusResponseBuilder> {
  _$PasskeyStatusResponse? _$v;

  PasskeyStatusBuilder? _data;
  PasskeyStatusBuilder get data => _$this._data ??= PasskeyStatusBuilder();
  set data(PasskeyStatusBuilder? data) => _$this._data = data;

  PasskeyStatusResponseBuilder() {
    PasskeyStatusResponse._defaults(this);
  }

  PasskeyStatusResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PasskeyStatusResponse other) {
    _$v = other as _$PasskeyStatusResponse;
  }

  @override
  void update(void Function(PasskeyStatusResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PasskeyStatusResponse build() => _build();

  _$PasskeyStatusResponse _build() {
    _$PasskeyStatusResponse _$result;
    try {
      _$result = _$v ??
          _$PasskeyStatusResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PasskeyStatusResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

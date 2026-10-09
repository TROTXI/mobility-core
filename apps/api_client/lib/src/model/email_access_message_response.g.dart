// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_access_message_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EmailAccessMessageResponse extends EmailAccessMessageResponse {
  @override
  final EmailAccessMessage data;

  factory _$EmailAccessMessageResponse(
          [void Function(EmailAccessMessageResponseBuilder)? updates]) =>
      (EmailAccessMessageResponseBuilder()..update(updates))._build();

  _$EmailAccessMessageResponse._({required this.data}) : super._();
  @override
  EmailAccessMessageResponse rebuild(
          void Function(EmailAccessMessageResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EmailAccessMessageResponseBuilder toBuilder() =>
      EmailAccessMessageResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EmailAccessMessageResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'EmailAccessMessageResponse')
          ..add('data', data))
        .toString();
  }
}

class EmailAccessMessageResponseBuilder
    implements
        Builder<EmailAccessMessageResponse, EmailAccessMessageResponseBuilder> {
  _$EmailAccessMessageResponse? _$v;

  EmailAccessMessageBuilder? _data;
  EmailAccessMessageBuilder get data =>
      _$this._data ??= EmailAccessMessageBuilder();
  set data(EmailAccessMessageBuilder? data) => _$this._data = data;

  EmailAccessMessageResponseBuilder() {
    EmailAccessMessageResponse._defaults(this);
  }

  EmailAccessMessageResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EmailAccessMessageResponse other) {
    _$v = other as _$EmailAccessMessageResponse;
  }

  @override
  void update(void Function(EmailAccessMessageResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EmailAccessMessageResponse build() => _build();

  _$EmailAccessMessageResponse _build() {
    _$EmailAccessMessageResponse _$result;
    try {
      _$result = _$v ??
          _$EmailAccessMessageResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'EmailAccessMessageResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

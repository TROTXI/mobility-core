// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_access_message.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EmailAccessMessage extends EmailAccessMessage {
  @override
  final String message;

  factory _$EmailAccessMessage(
          [void Function(EmailAccessMessageBuilder)? updates]) =>
      (EmailAccessMessageBuilder()..update(updates))._build();

  _$EmailAccessMessage._({required this.message}) : super._();
  @override
  EmailAccessMessage rebuild(
          void Function(EmailAccessMessageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EmailAccessMessageBuilder toBuilder() =>
      EmailAccessMessageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EmailAccessMessage && message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EmailAccessMessage')
          ..add('message', message))
        .toString();
  }
}

class EmailAccessMessageBuilder
    implements Builder<EmailAccessMessage, EmailAccessMessageBuilder> {
  _$EmailAccessMessage? _$v;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  EmailAccessMessageBuilder() {
    EmailAccessMessage._defaults(this);
  }

  EmailAccessMessageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EmailAccessMessage other) {
    _$v = other as _$EmailAccessMessage;
  }

  @override
  void update(void Function(EmailAccessMessageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EmailAccessMessage build() => _build();

  _$EmailAccessMessage _build() {
    final _$result = _$v ??
        _$EmailAccessMessage._(
          message: BuiltValueNullFieldError.checkNotNull(
              message, r'EmailAccessMessage', 'message'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webhook_ack.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WebhookAck extends WebhookAck {
  @override
  final bool received;

  factory _$WebhookAck([void Function(WebhookAckBuilder)? updates]) =>
      (WebhookAckBuilder()..update(updates))._build();

  _$WebhookAck._({required this.received}) : super._();
  @override
  WebhookAck rebuild(void Function(WebhookAckBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WebhookAckBuilder toBuilder() => WebhookAckBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WebhookAck && received == other.received;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, received.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WebhookAck')
          ..add('received', received))
        .toString();
  }
}

class WebhookAckBuilder implements Builder<WebhookAck, WebhookAckBuilder> {
  _$WebhookAck? _$v;

  bool? _received;
  bool? get received => _$this._received;
  set received(bool? received) => _$this._received = received;

  WebhookAckBuilder() {
    WebhookAck._defaults(this);
  }

  WebhookAckBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _received = $v.received;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WebhookAck other) {
    _$v = other as _$WebhookAck;
  }

  @override
  void update(void Function(WebhookAckBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WebhookAck build() => _build();

  _$WebhookAck _build() {
    final _$result = _$v ??
        _$WebhookAck._(
          received: BuiltValueNullFieldError.checkNotNull(
              received, r'WebhookAck', 'received'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

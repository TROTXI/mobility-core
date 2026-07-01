// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webhooks_paystack_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WebhooksPaystackPost200Response
    extends WebhooksPaystackPost200Response {
  @override
  final bool received;

  factory _$WebhooksPaystackPost200Response(
          [void Function(WebhooksPaystackPost200ResponseBuilder)? updates]) =>
      (WebhooksPaystackPost200ResponseBuilder()..update(updates))._build();

  _$WebhooksPaystackPost200Response._({required this.received}) : super._();
  @override
  WebhooksPaystackPost200Response rebuild(
          void Function(WebhooksPaystackPost200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WebhooksPaystackPost200ResponseBuilder toBuilder() =>
      WebhooksPaystackPost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WebhooksPaystackPost200Response &&
        received == other.received;
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
    return (newBuiltValueToStringHelper(r'WebhooksPaystackPost200Response')
          ..add('received', received))
        .toString();
  }
}

class WebhooksPaystackPost200ResponseBuilder
    implements
        Builder<WebhooksPaystackPost200Response,
            WebhooksPaystackPost200ResponseBuilder> {
  _$WebhooksPaystackPost200Response? _$v;

  bool? _received;
  bool? get received => _$this._received;
  set received(bool? received) => _$this._received = received;

  WebhooksPaystackPost200ResponseBuilder() {
    WebhooksPaystackPost200Response._defaults(this);
  }

  WebhooksPaystackPost200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _received = $v.received;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WebhooksPaystackPost200Response other) {
    _$v = other as _$WebhooksPaystackPost200Response;
  }

  @override
  void update(void Function(WebhooksPaystackPost200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WebhooksPaystackPost200Response build() => _build();

  _$WebhooksPaystackPost200Response _build() {
    final _$result = _$v ??
        _$WebhooksPaystackPost200Response._(
          received: BuiltValueNullFieldError.checkNotNull(
              received, r'WebhooksPaystackPost200Response', 'received'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

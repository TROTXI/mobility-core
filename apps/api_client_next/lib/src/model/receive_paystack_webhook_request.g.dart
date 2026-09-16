// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receive_paystack_webhook_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReceivePaystackWebhookRequest extends ReceivePaystackWebhookRequest {
  @override
  final String event;
  @override
  final BuiltMap<String, JsonObject?> data;

  factory _$ReceivePaystackWebhookRequest(
          [void Function(ReceivePaystackWebhookRequestBuilder)? updates]) =>
      (ReceivePaystackWebhookRequestBuilder()..update(updates))._build();

  _$ReceivePaystackWebhookRequest._({required this.event, required this.data})
      : super._();
  @override
  ReceivePaystackWebhookRequest rebuild(
          void Function(ReceivePaystackWebhookRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReceivePaystackWebhookRequestBuilder toBuilder() =>
      ReceivePaystackWebhookRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReceivePaystackWebhookRequest &&
        event == other.event &&
        data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, event.hashCode);
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReceivePaystackWebhookRequest')
          ..add('event', event)
          ..add('data', data))
        .toString();
  }
}

class ReceivePaystackWebhookRequestBuilder
    implements
        Builder<ReceivePaystackWebhookRequest,
            ReceivePaystackWebhookRequestBuilder> {
  _$ReceivePaystackWebhookRequest? _$v;

  String? _event;
  String? get event => _$this._event;
  set event(String? event) => _$this._event = event;

  MapBuilder<String, JsonObject?>? _data;
  MapBuilder<String, JsonObject?> get data =>
      _$this._data ??= MapBuilder<String, JsonObject?>();
  set data(MapBuilder<String, JsonObject?>? data) => _$this._data = data;

  ReceivePaystackWebhookRequestBuilder() {
    ReceivePaystackWebhookRequest._defaults(this);
  }

  ReceivePaystackWebhookRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _event = $v.event;
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReceivePaystackWebhookRequest other) {
    _$v = other as _$ReceivePaystackWebhookRequest;
  }

  @override
  void update(void Function(ReceivePaystackWebhookRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReceivePaystackWebhookRequest build() => _build();

  _$ReceivePaystackWebhookRequest _build() {
    _$ReceivePaystackWebhookRequest _$result;
    try {
      _$result = _$v ??
          _$ReceivePaystackWebhookRequest._(
            event: BuiltValueNullFieldError.checkNotNull(
                event, r'ReceivePaystackWebhookRequest', 'event'),
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ReceivePaystackWebhookRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

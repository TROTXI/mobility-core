// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payments_subscribe_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PaymentsSubscribePost200Response
    extends PaymentsSubscribePost200Response {
  @override
  final String authorizationUrl;
  @override
  final String reference;

  factory _$PaymentsSubscribePost200Response(
          [void Function(PaymentsSubscribePost200ResponseBuilder)? updates]) =>
      (PaymentsSubscribePost200ResponseBuilder()..update(updates))._build();

  _$PaymentsSubscribePost200Response._(
      {required this.authorizationUrl, required this.reference})
      : super._();
  @override
  PaymentsSubscribePost200Response rebuild(
          void Function(PaymentsSubscribePost200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PaymentsSubscribePost200ResponseBuilder toBuilder() =>
      PaymentsSubscribePost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PaymentsSubscribePost200Response &&
        authorizationUrl == other.authorizationUrl &&
        reference == other.reference;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, authorizationUrl.hashCode);
    _$hash = $jc(_$hash, reference.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PaymentsSubscribePost200Response')
          ..add('authorizationUrl', authorizationUrl)
          ..add('reference', reference))
        .toString();
  }
}

class PaymentsSubscribePost200ResponseBuilder
    implements
        Builder<PaymentsSubscribePost200Response,
            PaymentsSubscribePost200ResponseBuilder> {
  _$PaymentsSubscribePost200Response? _$v;

  String? _authorizationUrl;
  String? get authorizationUrl => _$this._authorizationUrl;
  set authorizationUrl(String? authorizationUrl) =>
      _$this._authorizationUrl = authorizationUrl;

  String? _reference;
  String? get reference => _$this._reference;
  set reference(String? reference) => _$this._reference = reference;

  PaymentsSubscribePost200ResponseBuilder() {
    PaymentsSubscribePost200Response._defaults(this);
  }

  PaymentsSubscribePost200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _authorizationUrl = $v.authorizationUrl;
      _reference = $v.reference;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PaymentsSubscribePost200Response other) {
    _$v = other as _$PaymentsSubscribePost200Response;
  }

  @override
  void update(void Function(PaymentsSubscribePost200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PaymentsSubscribePost200Response build() => _build();

  _$PaymentsSubscribePost200Response _build() {
    final _$result = _$v ??
        _$PaymentsSubscribePost200Response._(
          authorizationUrl: BuiltValueNullFieldError.checkNotNull(
              authorizationUrl,
              r'PaymentsSubscribePost200Response',
              'authorizationUrl'),
          reference: BuiltValueNullFieldError.checkNotNull(
              reference, r'PaymentsSubscribePost200Response', 'reference'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

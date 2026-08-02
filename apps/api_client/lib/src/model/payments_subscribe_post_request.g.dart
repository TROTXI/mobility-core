// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payments_subscribe_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PaymentsSubscribePostRequestPlanEnum
    _$paymentsSubscribePostRequestPlanEnum_monthly =
    const PaymentsSubscribePostRequestPlanEnum._('monthly');
const PaymentsSubscribePostRequestPlanEnum
    _$paymentsSubscribePostRequestPlanEnum_annual =
    const PaymentsSubscribePostRequestPlanEnum._('annual');

PaymentsSubscribePostRequestPlanEnum
    _$paymentsSubscribePostRequestPlanEnumValueOf(String name) {
  switch (name) {
    case 'monthly':
      return _$paymentsSubscribePostRequestPlanEnum_monthly;
    case 'annual':
      return _$paymentsSubscribePostRequestPlanEnum_annual;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PaymentsSubscribePostRequestPlanEnum>
    _$paymentsSubscribePostRequestPlanEnumValues = BuiltSet<
        PaymentsSubscribePostRequestPlanEnum>(const <PaymentsSubscribePostRequestPlanEnum>[
  _$paymentsSubscribePostRequestPlanEnum_monthly,
  _$paymentsSubscribePostRequestPlanEnum_annual,
]);

Serializer<PaymentsSubscribePostRequestPlanEnum>
    _$paymentsSubscribePostRequestPlanEnumSerializer =
    _$PaymentsSubscribePostRequestPlanEnumSerializer();

class _$PaymentsSubscribePostRequestPlanEnumSerializer
    implements PrimitiveSerializer<PaymentsSubscribePostRequestPlanEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'monthly': 'monthly',
    'annual': 'annual',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'monthly': 'monthly',
    'annual': 'annual',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PaymentsSubscribePostRequestPlanEnum
  ];
  @override
  final String wireName = 'PaymentsSubscribePostRequestPlanEnum';

  @override
  Object serialize(
          Serializers serializers, PaymentsSubscribePostRequestPlanEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PaymentsSubscribePostRequestPlanEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PaymentsSubscribePostRequestPlanEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PaymentsSubscribePostRequest extends PaymentsSubscribePostRequest {
  @override
  final PaymentsSubscribePostRequestPlanEnum plan;
  @override
  final String? routeId;

  factory _$PaymentsSubscribePostRequest(
          [void Function(PaymentsSubscribePostRequestBuilder)? updates]) =>
      (PaymentsSubscribePostRequestBuilder()..update(updates))._build();

  _$PaymentsSubscribePostRequest._({required this.plan, this.routeId})
      : super._();
  @override
  PaymentsSubscribePostRequest rebuild(
          void Function(PaymentsSubscribePostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PaymentsSubscribePostRequestBuilder toBuilder() =>
      PaymentsSubscribePostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PaymentsSubscribePostRequest &&
        plan == other.plan &&
        routeId == other.routeId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, plan.hashCode);
    _$hash = $jc(_$hash, routeId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PaymentsSubscribePostRequest')
          ..add('plan', plan)
          ..add('routeId', routeId))
        .toString();
  }
}

class PaymentsSubscribePostRequestBuilder
    implements
        Builder<PaymentsSubscribePostRequest,
            PaymentsSubscribePostRequestBuilder> {
  _$PaymentsSubscribePostRequest? _$v;

  PaymentsSubscribePostRequestPlanEnum? _plan;
  PaymentsSubscribePostRequestPlanEnum? get plan => _$this._plan;
  set plan(PaymentsSubscribePostRequestPlanEnum? plan) => _$this._plan = plan;

  String? _routeId;
  String? get routeId => _$this._routeId;
  set routeId(String? routeId) => _$this._routeId = routeId;

  PaymentsSubscribePostRequestBuilder() {
    PaymentsSubscribePostRequest._defaults(this);
  }

  PaymentsSubscribePostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _plan = $v.plan;
      _routeId = $v.routeId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PaymentsSubscribePostRequest other) {
    _$v = other as _$PaymentsSubscribePostRequest;
  }

  @override
  void update(void Function(PaymentsSubscribePostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PaymentsSubscribePostRequest build() => _build();

  _$PaymentsSubscribePostRequest _build() {
    final _$result = _$v ??
        _$PaymentsSubscribePostRequest._(
          plan: BuiltValueNullFieldError.checkNotNull(
              plan, r'PaymentsSubscribePostRequest', 'plan'),
          routeId: routeId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

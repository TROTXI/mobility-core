// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_purchase_attempts_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OpsPurchaseAttemptsInnerEnvironmentEnum
    _$opsPurchaseAttemptsInnerEnvironmentEnum_test =
    const OpsPurchaseAttemptsInnerEnvironmentEnum._('test');
const OpsPurchaseAttemptsInnerEnvironmentEnum
    _$opsPurchaseAttemptsInnerEnvironmentEnum_live =
    const OpsPurchaseAttemptsInnerEnvironmentEnum._('live');

OpsPurchaseAttemptsInnerEnvironmentEnum
    _$opsPurchaseAttemptsInnerEnvironmentEnumValueOf(String name) {
  switch (name) {
    case 'test':
      return _$opsPurchaseAttemptsInnerEnvironmentEnum_test;
    case 'live':
      return _$opsPurchaseAttemptsInnerEnvironmentEnum_live;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OpsPurchaseAttemptsInnerEnvironmentEnum>
    _$opsPurchaseAttemptsInnerEnvironmentEnumValues = BuiltSet<
        OpsPurchaseAttemptsInnerEnvironmentEnum>(const <OpsPurchaseAttemptsInnerEnvironmentEnum>[
  _$opsPurchaseAttemptsInnerEnvironmentEnum_test,
  _$opsPurchaseAttemptsInnerEnvironmentEnum_live,
]);

const OpsPurchaseAttemptsInnerStatusEnum
    _$opsPurchaseAttemptsInnerStatusEnum_pending =
    const OpsPurchaseAttemptsInnerStatusEnum._('pending');
const OpsPurchaseAttemptsInnerStatusEnum
    _$opsPurchaseAttemptsInnerStatusEnum_successful =
    const OpsPurchaseAttemptsInnerStatusEnum._('successful');
const OpsPurchaseAttemptsInnerStatusEnum
    _$opsPurchaseAttemptsInnerStatusEnum_failed =
    const OpsPurchaseAttemptsInnerStatusEnum._('failed');
const OpsPurchaseAttemptsInnerStatusEnum
    _$opsPurchaseAttemptsInnerStatusEnum_unknown =
    const OpsPurchaseAttemptsInnerStatusEnum._('unknown');

OpsPurchaseAttemptsInnerStatusEnum _$opsPurchaseAttemptsInnerStatusEnumValueOf(
    String name) {
  switch (name) {
    case 'pending':
      return _$opsPurchaseAttemptsInnerStatusEnum_pending;
    case 'successful':
      return _$opsPurchaseAttemptsInnerStatusEnum_successful;
    case 'failed':
      return _$opsPurchaseAttemptsInnerStatusEnum_failed;
    case 'unknown':
      return _$opsPurchaseAttemptsInnerStatusEnum_unknown;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OpsPurchaseAttemptsInnerStatusEnum>
    _$opsPurchaseAttemptsInnerStatusEnumValues = BuiltSet<
        OpsPurchaseAttemptsInnerStatusEnum>(const <OpsPurchaseAttemptsInnerStatusEnum>[
  _$opsPurchaseAttemptsInnerStatusEnum_pending,
  _$opsPurchaseAttemptsInnerStatusEnum_successful,
  _$opsPurchaseAttemptsInnerStatusEnum_failed,
  _$opsPurchaseAttemptsInnerStatusEnum_unknown,
]);

Serializer<OpsPurchaseAttemptsInnerEnvironmentEnum>
    _$opsPurchaseAttemptsInnerEnvironmentEnumSerializer =
    _$OpsPurchaseAttemptsInnerEnvironmentEnumSerializer();
Serializer<OpsPurchaseAttemptsInnerStatusEnum>
    _$opsPurchaseAttemptsInnerStatusEnumSerializer =
    _$OpsPurchaseAttemptsInnerStatusEnumSerializer();

class _$OpsPurchaseAttemptsInnerEnvironmentEnumSerializer
    implements PrimitiveSerializer<OpsPurchaseAttemptsInnerEnvironmentEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'test': 'test',
    'live': 'live',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'test': 'test',
    'live': 'live',
  };

  @override
  final Iterable<Type> types = const <Type>[
    OpsPurchaseAttemptsInnerEnvironmentEnum
  ];
  @override
  final String wireName = 'OpsPurchaseAttemptsInnerEnvironmentEnum';

  @override
  Object serialize(Serializers serializers,
          OpsPurchaseAttemptsInnerEnvironmentEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OpsPurchaseAttemptsInnerEnvironmentEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OpsPurchaseAttemptsInnerEnvironmentEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OpsPurchaseAttemptsInnerStatusEnumSerializer
    implements PrimitiveSerializer<OpsPurchaseAttemptsInnerStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'pending': 'pending',
    'successful': 'successful',
    'failed': 'failed',
    'unknown': 'unknown',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'pending': 'pending',
    'successful': 'successful',
    'failed': 'failed',
    'unknown': 'unknown',
  };

  @override
  final Iterable<Type> types = const <Type>[OpsPurchaseAttemptsInnerStatusEnum];
  @override
  final String wireName = 'OpsPurchaseAttemptsInnerStatusEnum';

  @override
  Object serialize(
          Serializers serializers, OpsPurchaseAttemptsInnerStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OpsPurchaseAttemptsInnerStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OpsPurchaseAttemptsInnerStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OpsPurchaseAttemptsInner extends OpsPurchaseAttemptsInner {
  @override
  final String id;
  @override
  final String providerReference;
  @override
  final String? providerTransactionId;
  @override
  final OpsPurchaseAttemptsInnerEnvironmentEnum environment;
  @override
  final OpsPurchaseAttemptsInnerStatusEnum status;
  @override
  final OpsPurchaseAttemptsInnerReceivedAmount? receivedAmount;

  factory _$OpsPurchaseAttemptsInner(
          [void Function(OpsPurchaseAttemptsInnerBuilder)? updates]) =>
      (OpsPurchaseAttemptsInnerBuilder()..update(updates))._build();

  _$OpsPurchaseAttemptsInner._(
      {required this.id,
      required this.providerReference,
      this.providerTransactionId,
      required this.environment,
      required this.status,
      this.receivedAmount})
      : super._();
  @override
  OpsPurchaseAttemptsInner rebuild(
          void Function(OpsPurchaseAttemptsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsPurchaseAttemptsInnerBuilder toBuilder() =>
      OpsPurchaseAttemptsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsPurchaseAttemptsInner &&
        id == other.id &&
        providerReference == other.providerReference &&
        providerTransactionId == other.providerTransactionId &&
        environment == other.environment &&
        status == other.status &&
        receivedAmount == other.receivedAmount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, providerReference.hashCode);
    _$hash = $jc(_$hash, providerTransactionId.hashCode);
    _$hash = $jc(_$hash, environment.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, receivedAmount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OpsPurchaseAttemptsInner')
          ..add('id', id)
          ..add('providerReference', providerReference)
          ..add('providerTransactionId', providerTransactionId)
          ..add('environment', environment)
          ..add('status', status)
          ..add('receivedAmount', receivedAmount))
        .toString();
  }
}

class OpsPurchaseAttemptsInnerBuilder
    implements
        Builder<OpsPurchaseAttemptsInner, OpsPurchaseAttemptsInnerBuilder> {
  _$OpsPurchaseAttemptsInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _providerReference;
  String? get providerReference => _$this._providerReference;
  set providerReference(String? providerReference) =>
      _$this._providerReference = providerReference;

  String? _providerTransactionId;
  String? get providerTransactionId => _$this._providerTransactionId;
  set providerTransactionId(String? providerTransactionId) =>
      _$this._providerTransactionId = providerTransactionId;

  OpsPurchaseAttemptsInnerEnvironmentEnum? _environment;
  OpsPurchaseAttemptsInnerEnvironmentEnum? get environment =>
      _$this._environment;
  set environment(OpsPurchaseAttemptsInnerEnvironmentEnum? environment) =>
      _$this._environment = environment;

  OpsPurchaseAttemptsInnerStatusEnum? _status;
  OpsPurchaseAttemptsInnerStatusEnum? get status => _$this._status;
  set status(OpsPurchaseAttemptsInnerStatusEnum? status) =>
      _$this._status = status;

  OpsPurchaseAttemptsInnerReceivedAmountBuilder? _receivedAmount;
  OpsPurchaseAttemptsInnerReceivedAmountBuilder get receivedAmount =>
      _$this._receivedAmount ??=
          OpsPurchaseAttemptsInnerReceivedAmountBuilder();
  set receivedAmount(
          OpsPurchaseAttemptsInnerReceivedAmountBuilder? receivedAmount) =>
      _$this._receivedAmount = receivedAmount;

  OpsPurchaseAttemptsInnerBuilder() {
    OpsPurchaseAttemptsInner._defaults(this);
  }

  OpsPurchaseAttemptsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _providerReference = $v.providerReference;
      _providerTransactionId = $v.providerTransactionId;
      _environment = $v.environment;
      _status = $v.status;
      _receivedAmount = $v.receivedAmount?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsPurchaseAttemptsInner other) {
    _$v = other as _$OpsPurchaseAttemptsInner;
  }

  @override
  void update(void Function(OpsPurchaseAttemptsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsPurchaseAttemptsInner build() => _build();

  _$OpsPurchaseAttemptsInner _build() {
    _$OpsPurchaseAttemptsInner _$result;
    try {
      _$result = _$v ??
          _$OpsPurchaseAttemptsInner._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'OpsPurchaseAttemptsInner', 'id'),
            providerReference: BuiltValueNullFieldError.checkNotNull(
                providerReference,
                r'OpsPurchaseAttemptsInner',
                'providerReference'),
            providerTransactionId: providerTransactionId,
            environment: BuiltValueNullFieldError.checkNotNull(
                environment, r'OpsPurchaseAttemptsInner', 'environment'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'OpsPurchaseAttemptsInner', 'status'),
            receivedAmount: _receivedAmount?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'receivedAmount';
        _receivedAmount?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OpsPurchaseAttemptsInner', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

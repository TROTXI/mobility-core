// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phone_verification_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PhoneVerificationResultStatusEnum
    _$phoneVerificationResultStatusEnum_verified =
    const PhoneVerificationResultStatusEnum._('verified');
const PhoneVerificationResultStatusEnum
    _$phoneVerificationResultStatusEnum_review =
    const PhoneVerificationResultStatusEnum._('review');

PhoneVerificationResultStatusEnum _$phoneVerificationResultStatusEnumValueOf(
    String name) {
  switch (name) {
    case 'verified':
      return _$phoneVerificationResultStatusEnum_verified;
    case 'review':
      return _$phoneVerificationResultStatusEnum_review;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PhoneVerificationResultStatusEnum>
    _$phoneVerificationResultStatusEnumValues = BuiltSet<
        PhoneVerificationResultStatusEnum>(const <PhoneVerificationResultStatusEnum>[
  _$phoneVerificationResultStatusEnum_verified,
  _$phoneVerificationResultStatusEnum_review,
]);

Serializer<PhoneVerificationResultStatusEnum>
    _$phoneVerificationResultStatusEnumSerializer =
    _$PhoneVerificationResultStatusEnumSerializer();

class _$PhoneVerificationResultStatusEnumSerializer
    implements PrimitiveSerializer<PhoneVerificationResultStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'verified': 'verified',
    'review': 'review',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'verified': 'verified',
    'review': 'review',
  };

  @override
  final Iterable<Type> types = const <Type>[PhoneVerificationResultStatusEnum];
  @override
  final String wireName = 'PhoneVerificationResultStatusEnum';

  @override
  Object serialize(
          Serializers serializers, PhoneVerificationResultStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PhoneVerificationResultStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PhoneVerificationResultStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PhoneVerificationResult extends PhoneVerificationResult {
  @override
  final PhoneVerificationResultStatusEnum status;

  factory _$PhoneVerificationResult(
          [void Function(PhoneVerificationResultBuilder)? updates]) =>
      (PhoneVerificationResultBuilder()..update(updates))._build();

  _$PhoneVerificationResult._({required this.status}) : super._();
  @override
  PhoneVerificationResult rebuild(
          void Function(PhoneVerificationResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PhoneVerificationResultBuilder toBuilder() =>
      PhoneVerificationResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PhoneVerificationResult && status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PhoneVerificationResult')
          ..add('status', status))
        .toString();
  }
}

class PhoneVerificationResultBuilder
    implements
        Builder<PhoneVerificationResult, PhoneVerificationResultBuilder> {
  _$PhoneVerificationResult? _$v;

  PhoneVerificationResultStatusEnum? _status;
  PhoneVerificationResultStatusEnum? get status => _$this._status;
  set status(PhoneVerificationResultStatusEnum? status) =>
      _$this._status = status;

  PhoneVerificationResultBuilder() {
    PhoneVerificationResult._defaults(this);
  }

  PhoneVerificationResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PhoneVerificationResult other) {
    _$v = other as _$PhoneVerificationResult;
  }

  @override
  void update(void Function(PhoneVerificationResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PhoneVerificationResult build() => _build();

  _$PhoneVerificationResult _build() {
    final _$result = _$v ??
        _$PhoneVerificationResult._(
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'PhoneVerificationResult', 'status'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

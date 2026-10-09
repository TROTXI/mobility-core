// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const VerificationStatusMissingEnum _$verificationStatusMissingEnum_phone =
    const VerificationStatusMissingEnum._('phone');
const VerificationStatusMissingEnum _$verificationStatusMissingEnum_profile =
    const VerificationStatusMissingEnum._('profile');

VerificationStatusMissingEnum _$verificationStatusMissingEnumValueOf(
    String name) {
  switch (name) {
    case 'phone':
      return _$verificationStatusMissingEnum_phone;
    case 'profile':
      return _$verificationStatusMissingEnum_profile;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<VerificationStatusMissingEnum>
    _$verificationStatusMissingEnumValues = BuiltSet<
        VerificationStatusMissingEnum>(const <VerificationStatusMissingEnum>[
  _$verificationStatusMissingEnum_phone,
  _$verificationStatusMissingEnum_profile,
]);

Serializer<VerificationStatusMissingEnum>
    _$verificationStatusMissingEnumSerializer =
    _$VerificationStatusMissingEnumSerializer();

class _$VerificationStatusMissingEnumSerializer
    implements PrimitiveSerializer<VerificationStatusMissingEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'phone': 'phone',
    'profile': 'profile',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'phone': 'phone',
    'profile': 'profile',
  };

  @override
  final Iterable<Type> types = const <Type>[VerificationStatusMissingEnum];
  @override
  final String wireName = 'VerificationStatusMissingEnum';

  @override
  Object serialize(
          Serializers serializers, VerificationStatusMissingEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  VerificationStatusMissingEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      VerificationStatusMissingEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$VerificationStatus extends VerificationStatus {
  @override
  final VerificationStatusPhone phone;
  @override
  final bool standbyEligible;
  @override
  final BuiltList<VerificationStatusMissingEnum> missing;

  factory _$VerificationStatus(
          [void Function(VerificationStatusBuilder)? updates]) =>
      (VerificationStatusBuilder()..update(updates))._build();

  _$VerificationStatus._(
      {required this.phone,
      required this.standbyEligible,
      required this.missing})
      : super._();
  @override
  VerificationStatus rebuild(
          void Function(VerificationStatusBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VerificationStatusBuilder toBuilder() =>
      VerificationStatusBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VerificationStatus &&
        phone == other.phone &&
        standbyEligible == other.standbyEligible &&
        missing == other.missing;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, standbyEligible.hashCode);
    _$hash = $jc(_$hash, missing.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'VerificationStatus')
          ..add('phone', phone)
          ..add('standbyEligible', standbyEligible)
          ..add('missing', missing))
        .toString();
  }
}

class VerificationStatusBuilder
    implements Builder<VerificationStatus, VerificationStatusBuilder> {
  _$VerificationStatus? _$v;

  VerificationStatusPhoneBuilder? _phone;
  VerificationStatusPhoneBuilder get phone =>
      _$this._phone ??= VerificationStatusPhoneBuilder();
  set phone(VerificationStatusPhoneBuilder? phone) => _$this._phone = phone;

  bool? _standbyEligible;
  bool? get standbyEligible => _$this._standbyEligible;
  set standbyEligible(bool? standbyEligible) =>
      _$this._standbyEligible = standbyEligible;

  ListBuilder<VerificationStatusMissingEnum>? _missing;
  ListBuilder<VerificationStatusMissingEnum> get missing =>
      _$this._missing ??= ListBuilder<VerificationStatusMissingEnum>();
  set missing(ListBuilder<VerificationStatusMissingEnum>? missing) =>
      _$this._missing = missing;

  VerificationStatusBuilder() {
    VerificationStatus._defaults(this);
  }

  VerificationStatusBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _phone = $v.phone.toBuilder();
      _standbyEligible = $v.standbyEligible;
      _missing = $v.missing.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VerificationStatus other) {
    _$v = other as _$VerificationStatus;
  }

  @override
  void update(void Function(VerificationStatusBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  VerificationStatus build() => _build();

  _$VerificationStatus _build() {
    _$VerificationStatus _$result;
    try {
      _$result = _$v ??
          _$VerificationStatus._(
            phone: phone.build(),
            standbyEligible: BuiltValueNullFieldError.checkNotNull(
                standbyEligible, r'VerificationStatus', 'standbyEligible'),
            missing: missing.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'phone';
        phone.build();

        _$failedField = 'missing';
        missing.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'VerificationStatus', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

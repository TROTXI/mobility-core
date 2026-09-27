//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'driver_self_credential.g.dart';

/// DriverSelfCredential
///
/// Properties:
<<<<<<< HEAD
/// * [driverCode] 
/// * [status] 
/// * [mustChangePin] 
/// * [lockedUntil] 
@BuiltValue()
abstract class DriverSelfCredential implements Built<DriverSelfCredential, DriverSelfCredentialBuilder> {
=======
/// * [driverCode]
/// * [status]
/// * [mustChangePin]
/// * [temporaryPinExpiresAt]
/// * [lockedUntil]
@BuiltValue()
abstract class DriverSelfCredential
    implements Built<DriverSelfCredential, DriverSelfCredentialBuilder> {
>>>>>>> origin/main
  @BuiltValueField(wireName: r'driverCode')
  String get driverCode;

  @BuiltValueField(wireName: r'status')
  DriverSelfCredentialStatusEnum get status;
  // enum statusEnum {  active,  suspended,  revoked,  };

  @BuiltValueField(wireName: r'mustChangePin')
  bool get mustChangePin;

<<<<<<< HEAD
=======
  @BuiltValueField(wireName: r'temporaryPinExpiresAt')
  DateTime? get temporaryPinExpiresAt;

>>>>>>> origin/main
  @BuiltValueField(wireName: r'lockedUntil')
  DateTime? get lockedUntil;

  DriverSelfCredential._();

<<<<<<< HEAD
  factory DriverSelfCredential([void updates(DriverSelfCredentialBuilder b)]) = _$DriverSelfCredential;
=======
  factory DriverSelfCredential([void updates(DriverSelfCredentialBuilder b)]) =
      _$DriverSelfCredential;
>>>>>>> origin/main

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DriverSelfCredentialBuilder b) => b;

  @BuiltValueSerializer(custom: true)
<<<<<<< HEAD
  static Serializer<DriverSelfCredential> get serializer => _$DriverSelfCredentialSerializer();
}

class _$DriverSelfCredentialSerializer implements PrimitiveSerializer<DriverSelfCredential> {
  @override
  final Iterable<Type> types = const [DriverSelfCredential, _$DriverSelfCredential];
=======
  static Serializer<DriverSelfCredential> get serializer =>
      _$DriverSelfCredentialSerializer();
}

class _$DriverSelfCredentialSerializer
    implements PrimitiveSerializer<DriverSelfCredential> {
  @override
  final Iterable<Type> types = const [
    DriverSelfCredential,
    _$DriverSelfCredential
  ];
>>>>>>> origin/main

  @override
  final String wireName = r'DriverSelfCredential';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DriverSelfCredential object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'driverCode';
    yield serializers.serialize(
      object.driverCode,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(DriverSelfCredentialStatusEnum),
    );
    yield r'mustChangePin';
    yield serializers.serialize(
      object.mustChangePin,
      specifiedType: const FullType(bool),
    );
<<<<<<< HEAD
    yield r'lockedUntil';
    yield object.lockedUntil == null ? null : serializers.serialize(
      object.lockedUntil,
      specifiedType: const FullType.nullable(DateTime),
    );
=======
    yield r'temporaryPinExpiresAt';
    yield object.temporaryPinExpiresAt == null
        ? null
        : serializers.serialize(
            object.temporaryPinExpiresAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'lockedUntil';
    yield object.lockedUntil == null
        ? null
        : serializers.serialize(
            object.lockedUntil,
            specifiedType: const FullType.nullable(DateTime),
          );
>>>>>>> origin/main
  }

  @override
  Object serialize(
    Serializers serializers,
    DriverSelfCredential object, {
    FullType specifiedType = FullType.unspecified,
  }) {
<<<<<<< HEAD
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
=======
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
>>>>>>> origin/main
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DriverSelfCredentialBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'driverCode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.driverCode = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DriverSelfCredentialStatusEnum),
          ) as DriverSelfCredentialStatusEnum;
          result.status = valueDes;
          break;
        case r'mustChangePin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.mustChangePin = valueDes;
          break;
<<<<<<< HEAD
=======
        case r'temporaryPinExpiresAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.temporaryPinExpiresAt = valueDes;
          break;
>>>>>>> origin/main
        case r'lockedUntil':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.lockedUntil = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DriverSelfCredential deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DriverSelfCredentialBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

class DriverSelfCredentialStatusEnum extends EnumClass {
<<<<<<< HEAD

  @BuiltValueEnumConst(wireName: r'active')
  static const DriverSelfCredentialStatusEnum active = _$driverSelfCredentialStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'suspended')
  static const DriverSelfCredentialStatusEnum suspended = _$driverSelfCredentialStatusEnum_suspended;
  @BuiltValueEnumConst(wireName: r'revoked')
  static const DriverSelfCredentialStatusEnum revoked = _$driverSelfCredentialStatusEnum_revoked;

  static Serializer<DriverSelfCredentialStatusEnum> get serializer => _$driverSelfCredentialStatusEnumSerializer;

  const DriverSelfCredentialStatusEnum._(String name): super(name);

  static BuiltSet<DriverSelfCredentialStatusEnum> get values => _$driverSelfCredentialStatusEnumValues;
  static DriverSelfCredentialStatusEnum valueOf(String name) => _$driverSelfCredentialStatusEnumValueOf(name);
}

=======
  @BuiltValueEnumConst(wireName: r'active')
  static const DriverSelfCredentialStatusEnum active =
      _$driverSelfCredentialStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'suspended')
  static const DriverSelfCredentialStatusEnum suspended =
      _$driverSelfCredentialStatusEnum_suspended;
  @BuiltValueEnumConst(wireName: r'revoked')
  static const DriverSelfCredentialStatusEnum revoked =
      _$driverSelfCredentialStatusEnum_revoked;

  static Serializer<DriverSelfCredentialStatusEnum> get serializer =>
      _$driverSelfCredentialStatusEnumSerializer;

  const DriverSelfCredentialStatusEnum._(String name) : super(name);

  static BuiltSet<DriverSelfCredentialStatusEnum> get values =>
      _$driverSelfCredentialStatusEnumValues;
  static DriverSelfCredentialStatusEnum valueOf(String name) =>
      _$driverSelfCredentialStatusEnumValueOf(name);
}
>>>>>>> origin/main

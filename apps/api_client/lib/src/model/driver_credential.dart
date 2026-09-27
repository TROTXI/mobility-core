//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'driver_credential.g.dart';

/// DriverCredential
///
/// Properties:
/// * [driverCode] 
/// * [status] 
/// * [mustChangePin] 
/// * [temporaryPinExpiresAt] 
/// * [lockedUntil] 
@BuiltValue()
abstract class DriverCredential implements Built<DriverCredential, DriverCredentialBuilder> {
  @BuiltValueField(wireName: r'driverCode')
  String get driverCode;

  @BuiltValueField(wireName: r'status')
  DriverCredentialStatusEnum get status;
  // enum statusEnum {  active,  suspended,  };

  @BuiltValueField(wireName: r'mustChangePin')
  bool get mustChangePin;

  @BuiltValueField(wireName: r'temporaryPinExpiresAt')
  DateTime? get temporaryPinExpiresAt;

  @BuiltValueField(wireName: r'lockedUntil')
  DateTime? get lockedUntil;

  DriverCredential._();

  factory DriverCredential([void updates(DriverCredentialBuilder b)]) = _$DriverCredential;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DriverCredentialBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DriverCredential> get serializer => _$DriverCredentialSerializer();
}

class _$DriverCredentialSerializer implements PrimitiveSerializer<DriverCredential> {
  @override
  final Iterable<Type> types = const [DriverCredential, _$DriverCredential];

  @override
  final String wireName = r'DriverCredential';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DriverCredential object, {
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
      specifiedType: const FullType(DriverCredentialStatusEnum),
    );
    yield r'mustChangePin';
    yield serializers.serialize(
      object.mustChangePin,
      specifiedType: const FullType(bool),
    );
    yield r'temporaryPinExpiresAt';
    yield object.temporaryPinExpiresAt == null ? null : serializers.serialize(
      object.temporaryPinExpiresAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'lockedUntil';
    yield object.lockedUntil == null ? null : serializers.serialize(
      object.lockedUntil,
      specifiedType: const FullType.nullable(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DriverCredential object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DriverCredentialBuilder result,
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
            specifiedType: const FullType(DriverCredentialStatusEnum),
          ) as DriverCredentialStatusEnum;
          result.status = valueDes;
          break;
        case r'mustChangePin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.mustChangePin = valueDes;
          break;
        case r'temporaryPinExpiresAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.temporaryPinExpiresAt = valueDes;
          break;
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
  DriverCredential deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DriverCredentialBuilder();
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

class DriverCredentialStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'active')
  static const DriverCredentialStatusEnum active = _$driverCredentialStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'suspended')
  static const DriverCredentialStatusEnum suspended = _$driverCredentialStatusEnum_suspended;

  static Serializer<DriverCredentialStatusEnum> get serializer => _$driverCredentialStatusEnumSerializer;

  const DriverCredentialStatusEnum._(String name): super(name);

  static BuiltSet<DriverCredentialStatusEnum> get values => _$driverCredentialStatusEnumValues;
  static DriverCredentialStatusEnum valueOf(String name) => _$driverCredentialStatusEnumValueOf(name);
}


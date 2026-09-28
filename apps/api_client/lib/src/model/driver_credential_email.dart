//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'driver_credential_email.g.dart';

/// DriverCredentialEmail
///
/// Properties:
/// * [purpose]
/// * [state]
/// * [failureCode]
/// * [queuedAt]
@BuiltValue()
abstract class DriverCredentialEmail
    implements Built<DriverCredentialEmail, DriverCredentialEmailBuilder> {
  @BuiltValueField(wireName: r'purpose')
  DriverCredentialEmailPurposeEnum get purpose;
  // enum purposeEnum {  onboarding,  pin_reset,  };

  @BuiltValueField(wireName: r'state')
  DriverCredentialEmailStateEnum get state;
  // enum stateEnum {  queued,  provider_accepted,  cancelled,  failed,  unknown,  };

  @BuiltValueField(wireName: r'failureCode')
  String? get failureCode;

  @BuiltValueField(wireName: r'queuedAt')
  DateTime get queuedAt;

  DriverCredentialEmail._();

  factory DriverCredentialEmail(
      [void updates(DriverCredentialEmailBuilder b)]) = _$DriverCredentialEmail;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DriverCredentialEmailBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DriverCredentialEmail> get serializer =>
      _$DriverCredentialEmailSerializer();
}

class _$DriverCredentialEmailSerializer
    implements PrimitiveSerializer<DriverCredentialEmail> {
  @override
  final Iterable<Type> types = const [
    DriverCredentialEmail,
    _$DriverCredentialEmail
  ];

  @override
  final String wireName = r'DriverCredentialEmail';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DriverCredentialEmail object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'purpose';
    yield serializers.serialize(
      object.purpose,
      specifiedType: const FullType(DriverCredentialEmailPurposeEnum),
    );
    yield r'state';
    yield serializers.serialize(
      object.state,
      specifiedType: const FullType(DriverCredentialEmailStateEnum),
    );
    yield r'failureCode';
    yield object.failureCode == null
        ? null
        : serializers.serialize(
            object.failureCode,
            specifiedType: const FullType.nullable(String),
          );
    yield r'queuedAt';
    yield serializers.serialize(
      object.queuedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DriverCredentialEmail object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DriverCredentialEmailBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'purpose':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DriverCredentialEmailPurposeEnum),
          ) as DriverCredentialEmailPurposeEnum;
          result.purpose = valueDes;
          break;
        case r'state':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DriverCredentialEmailStateEnum),
          ) as DriverCredentialEmailStateEnum;
          result.state = valueDes;
          break;
        case r'failureCode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.failureCode = valueDes;
          break;
        case r'queuedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.queuedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DriverCredentialEmail deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DriverCredentialEmailBuilder();
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

class DriverCredentialEmailPurposeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'onboarding')
  static const DriverCredentialEmailPurposeEnum onboarding =
      _$driverCredentialEmailPurposeEnum_onboarding;
  @BuiltValueEnumConst(wireName: r'pin_reset')
  static const DriverCredentialEmailPurposeEnum pinReset =
      _$driverCredentialEmailPurposeEnum_pinReset;

  static Serializer<DriverCredentialEmailPurposeEnum> get serializer =>
      _$driverCredentialEmailPurposeEnumSerializer;

  const DriverCredentialEmailPurposeEnum._(String name) : super(name);

  static BuiltSet<DriverCredentialEmailPurposeEnum> get values =>
      _$driverCredentialEmailPurposeEnumValues;
  static DriverCredentialEmailPurposeEnum valueOf(String name) =>
      _$driverCredentialEmailPurposeEnumValueOf(name);
}

class DriverCredentialEmailStateEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'queued')
  static const DriverCredentialEmailStateEnum queued =
      _$driverCredentialEmailStateEnum_queued;
  @BuiltValueEnumConst(wireName: r'provider_accepted')
  static const DriverCredentialEmailStateEnum providerAccepted =
      _$driverCredentialEmailStateEnum_providerAccepted;
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const DriverCredentialEmailStateEnum cancelled =
      _$driverCredentialEmailStateEnum_cancelled;
  @BuiltValueEnumConst(wireName: r'failed')
  static const DriverCredentialEmailStateEnum failed =
      _$driverCredentialEmailStateEnum_failed;
  @BuiltValueEnumConst(wireName: r'unknown')
  static const DriverCredentialEmailStateEnum unknown =
      _$driverCredentialEmailStateEnum_unknown;

  static Serializer<DriverCredentialEmailStateEnum> get serializer =>
      _$driverCredentialEmailStateEnumSerializer;

  const DriverCredentialEmailStateEnum._(String name) : super(name);

  static BuiltSet<DriverCredentialEmailStateEnum> get values =>
      _$driverCredentialEmailStateEnumValues;
  static DriverCredentialEmailStateEnum valueOf(String name) =>
      _$driverCredentialEmailStateEnumValueOf(name);
}

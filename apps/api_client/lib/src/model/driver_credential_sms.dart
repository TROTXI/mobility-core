//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'driver_credential_sms.g.dart';

/// DriverCredentialSms
///
/// Properties:
/// * [purpose]
/// * [state]
/// * [failureCode]
/// * [queuedAt]
@BuiltValue()
abstract class DriverCredentialSms
    implements Built<DriverCredentialSms, DriverCredentialSmsBuilder> {
  @BuiltValueField(wireName: r'purpose')
  DriverCredentialSmsPurposeEnum get purpose;
  // enum purposeEnum {  onboarding,  pin_reset,  };

  @BuiltValueField(wireName: r'state')
  DriverCredentialSmsStateEnum get state;
  // enum stateEnum {  queued,  sending,  provider_accepted,  cancelled,  unknown,  };

  @BuiltValueField(wireName: r'failureCode')
  String? get failureCode;

  @BuiltValueField(wireName: r'queuedAt')
  DateTime get queuedAt;

  DriverCredentialSms._();

  factory DriverCredentialSms([void updates(DriverCredentialSmsBuilder b)]) =
      _$DriverCredentialSms;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DriverCredentialSmsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DriverCredentialSms> get serializer =>
      _$DriverCredentialSmsSerializer();
}

class _$DriverCredentialSmsSerializer
    implements PrimitiveSerializer<DriverCredentialSms> {
  @override
  final Iterable<Type> types = const [
    DriverCredentialSms,
    _$DriverCredentialSms
  ];

  @override
  final String wireName = r'DriverCredentialSms';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DriverCredentialSms object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'purpose';
    yield serializers.serialize(
      object.purpose,
      specifiedType: const FullType(DriverCredentialSmsPurposeEnum),
    );
    yield r'state';
    yield serializers.serialize(
      object.state,
      specifiedType: const FullType(DriverCredentialSmsStateEnum),
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
    DriverCredentialSms object, {
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
    required DriverCredentialSmsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'purpose':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DriverCredentialSmsPurposeEnum),
          ) as DriverCredentialSmsPurposeEnum;
          result.purpose = valueDes;
          break;
        case r'state':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DriverCredentialSmsStateEnum),
          ) as DriverCredentialSmsStateEnum;
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
  DriverCredentialSms deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DriverCredentialSmsBuilder();
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

class DriverCredentialSmsPurposeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'onboarding')
  static const DriverCredentialSmsPurposeEnum onboarding =
      _$driverCredentialSmsPurposeEnum_onboarding;
  @BuiltValueEnumConst(wireName: r'pin_reset')
  static const DriverCredentialSmsPurposeEnum pinReset =
      _$driverCredentialSmsPurposeEnum_pinReset;

  static Serializer<DriverCredentialSmsPurposeEnum> get serializer =>
      _$driverCredentialSmsPurposeEnumSerializer;

  const DriverCredentialSmsPurposeEnum._(String name) : super(name);

  static BuiltSet<DriverCredentialSmsPurposeEnum> get values =>
      _$driverCredentialSmsPurposeEnumValues;
  static DriverCredentialSmsPurposeEnum valueOf(String name) =>
      _$driverCredentialSmsPurposeEnumValueOf(name);
}

class DriverCredentialSmsStateEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'queued')
  static const DriverCredentialSmsStateEnum queued =
      _$driverCredentialSmsStateEnum_queued;
  @BuiltValueEnumConst(wireName: r'sending')
  static const DriverCredentialSmsStateEnum sending =
      _$driverCredentialSmsStateEnum_sending;
  @BuiltValueEnumConst(wireName: r'provider_accepted')
  static const DriverCredentialSmsStateEnum providerAccepted =
      _$driverCredentialSmsStateEnum_providerAccepted;
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const DriverCredentialSmsStateEnum cancelled =
      _$driverCredentialSmsStateEnum_cancelled;
  @BuiltValueEnumConst(wireName: r'unknown')
  static const DriverCredentialSmsStateEnum unknown =
      _$driverCredentialSmsStateEnum_unknown;

  static Serializer<DriverCredentialSmsStateEnum> get serializer =>
      _$driverCredentialSmsStateEnumSerializer;

  const DriverCredentialSmsStateEnum._(String name) : super(name);

  static BuiltSet<DriverCredentialSmsStateEnum> get values =>
      _$driverCredentialSmsStateEnumValues;
  static DriverCredentialSmsStateEnum valueOf(String name) =>
      _$driverCredentialSmsStateEnumValueOf(name);
}

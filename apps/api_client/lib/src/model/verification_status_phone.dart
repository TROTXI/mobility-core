//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'verification_status_phone.g.dart';

/// VerificationStatusPhone
///
/// Properties:
/// * [status]
/// * [maskedNumber]
/// * [verifiedAt]
@BuiltValue()
abstract class VerificationStatusPhone
    implements Built<VerificationStatusPhone, VerificationStatusPhoneBuilder> {
  @BuiltValueField(wireName: r'status')
  VerificationStatusPhoneStatusEnum get status;
  // enum statusEnum {  incomplete,  pending,  verified,  review,  unavailable,  };

  @BuiltValueField(wireName: r'maskedNumber')
  String? get maskedNumber;

  @BuiltValueField(wireName: r'verifiedAt')
  DateTime? get verifiedAt;

  VerificationStatusPhone._();

  factory VerificationStatusPhone(
          [void updates(VerificationStatusPhoneBuilder b)]) =
      _$VerificationStatusPhone;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(VerificationStatusPhoneBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<VerificationStatusPhone> get serializer =>
      _$VerificationStatusPhoneSerializer();
}

class _$VerificationStatusPhoneSerializer
    implements PrimitiveSerializer<VerificationStatusPhone> {
  @override
  final Iterable<Type> types = const [
    VerificationStatusPhone,
    _$VerificationStatusPhone
  ];

  @override
  final String wireName = r'VerificationStatusPhone';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    VerificationStatusPhone object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(VerificationStatusPhoneStatusEnum),
    );
    yield r'maskedNumber';
    yield object.maskedNumber == null
        ? null
        : serializers.serialize(
            object.maskedNumber,
            specifiedType: const FullType.nullable(String),
          );
    yield r'verifiedAt';
    yield object.verifiedAt == null
        ? null
        : serializers.serialize(
            object.verifiedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    VerificationStatusPhone object, {
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
    required VerificationStatusPhoneBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(VerificationStatusPhoneStatusEnum),
          ) as VerificationStatusPhoneStatusEnum;
          result.status = valueDes;
          break;
        case r'maskedNumber':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.maskedNumber = valueDes;
          break;
        case r'verifiedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.verifiedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  VerificationStatusPhone deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = VerificationStatusPhoneBuilder();
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

class VerificationStatusPhoneStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'incomplete')
  static const VerificationStatusPhoneStatusEnum incomplete =
      _$verificationStatusPhoneStatusEnum_incomplete;
  @BuiltValueEnumConst(wireName: r'pending')
  static const VerificationStatusPhoneStatusEnum pending =
      _$verificationStatusPhoneStatusEnum_pending;
  @BuiltValueEnumConst(wireName: r'verified')
  static const VerificationStatusPhoneStatusEnum verified =
      _$verificationStatusPhoneStatusEnum_verified;
  @BuiltValueEnumConst(wireName: r'review')
  static const VerificationStatusPhoneStatusEnum review =
      _$verificationStatusPhoneStatusEnum_review;
  @BuiltValueEnumConst(wireName: r'unavailable')
  static const VerificationStatusPhoneStatusEnum unavailable =
      _$verificationStatusPhoneStatusEnum_unavailable;

  static Serializer<VerificationStatusPhoneStatusEnum> get serializer =>
      _$verificationStatusPhoneStatusEnumSerializer;

  const VerificationStatusPhoneStatusEnum._(String name) : super(name);

  static BuiltSet<VerificationStatusPhoneStatusEnum> get values =>
      _$verificationStatusPhoneStatusEnumValues;
  static VerificationStatusPhoneStatusEnum valueOf(String name) =>
      _$verificationStatusPhoneStatusEnumValueOf(name);
}

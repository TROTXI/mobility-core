//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'phone_verification_result.g.dart';

/// PhoneVerificationResult
///
/// Properties:
/// * [status]
@BuiltValue()
abstract class PhoneVerificationResult
    implements Built<PhoneVerificationResult, PhoneVerificationResultBuilder> {
  @BuiltValueField(wireName: r'status')
  PhoneVerificationResultStatusEnum get status;
  // enum statusEnum {  verified,  review,  };

  PhoneVerificationResult._();

  factory PhoneVerificationResult(
          [void updates(PhoneVerificationResultBuilder b)]) =
      _$PhoneVerificationResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PhoneVerificationResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PhoneVerificationResult> get serializer =>
      _$PhoneVerificationResultSerializer();
}

class _$PhoneVerificationResultSerializer
    implements PrimitiveSerializer<PhoneVerificationResult> {
  @override
  final Iterable<Type> types = const [
    PhoneVerificationResult,
    _$PhoneVerificationResult
  ];

  @override
  final String wireName = r'PhoneVerificationResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PhoneVerificationResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(PhoneVerificationResultStatusEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PhoneVerificationResult object, {
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
    required PhoneVerificationResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PhoneVerificationResultStatusEnum),
          ) as PhoneVerificationResultStatusEnum;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PhoneVerificationResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PhoneVerificationResultBuilder();
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

class PhoneVerificationResultStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'verified')
  static const PhoneVerificationResultStatusEnum verified =
      _$phoneVerificationResultStatusEnum_verified;
  @BuiltValueEnumConst(wireName: r'review')
  static const PhoneVerificationResultStatusEnum review =
      _$phoneVerificationResultStatusEnum_review;

  static Serializer<PhoneVerificationResultStatusEnum> get serializer =>
      _$phoneVerificationResultStatusEnumSerializer;

  const PhoneVerificationResultStatusEnum._(String name) : super(name);

  static BuiltSet<PhoneVerificationResultStatusEnum> get values =>
      _$phoneVerificationResultStatusEnumValues;
  static PhoneVerificationResultStatusEnum valueOf(String name) =>
      _$phoneVerificationResultStatusEnumValueOf(name);
}

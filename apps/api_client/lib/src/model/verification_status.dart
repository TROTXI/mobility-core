//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/verification_status_phone.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'verification_status.g.dart';

/// VerificationStatus
///
/// Properties:
/// * [phone]
/// * [standbyEligible]
/// * [missing]
@BuiltValue()
abstract class VerificationStatus
    implements Built<VerificationStatus, VerificationStatusBuilder> {
  @BuiltValueField(wireName: r'phone')
  VerificationStatusPhone get phone;

  @BuiltValueField(wireName: r'standbyEligible')
  bool get standbyEligible;

  @BuiltValueField(wireName: r'missing')
  BuiltList<VerificationStatusMissingEnum> get missing;
  // enum missingEnum {  phone,  profile,  };

  VerificationStatus._();

  factory VerificationStatus([void updates(VerificationStatusBuilder b)]) =
      _$VerificationStatus;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(VerificationStatusBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<VerificationStatus> get serializer =>
      _$VerificationStatusSerializer();
}

class _$VerificationStatusSerializer
    implements PrimitiveSerializer<VerificationStatus> {
  @override
  final Iterable<Type> types = const [VerificationStatus, _$VerificationStatus];

  @override
  final String wireName = r'VerificationStatus';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    VerificationStatus object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'phone';
    yield serializers.serialize(
      object.phone,
      specifiedType: const FullType(VerificationStatusPhone),
    );
    yield r'standbyEligible';
    yield serializers.serialize(
      object.standbyEligible,
      specifiedType: const FullType(bool),
    );
    yield r'missing';
    yield serializers.serialize(
      object.missing,
      specifiedType:
          const FullType(BuiltList, [FullType(VerificationStatusMissingEnum)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    VerificationStatus object, {
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
    required VerificationStatusBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(VerificationStatusPhone),
          ) as VerificationStatusPhone;
          result.phone.replace(valueDes);
          break;
        case r'standbyEligible':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.standbyEligible = valueDes;
          break;
        case r'missing':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltList, [FullType(VerificationStatusMissingEnum)]),
          ) as BuiltList<VerificationStatusMissingEnum>;
          result.missing.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  VerificationStatus deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = VerificationStatusBuilder();
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

class VerificationStatusMissingEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'phone')
  static const VerificationStatusMissingEnum phone =
      _$verificationStatusMissingEnum_phone;
  @BuiltValueEnumConst(wireName: r'profile')
  static const VerificationStatusMissingEnum profile =
      _$verificationStatusMissingEnum_profile;

  static Serializer<VerificationStatusMissingEnum> get serializer =>
      _$verificationStatusMissingEnumSerializer;

  const VerificationStatusMissingEnum._(String name) : super(name);

  static BuiltSet<VerificationStatusMissingEnum> get values =>
      _$verificationStatusMissingEnumValues;
  static VerificationStatusMissingEnum valueOf(String name) =>
      _$verificationStatusMissingEnumValueOf(name);
}

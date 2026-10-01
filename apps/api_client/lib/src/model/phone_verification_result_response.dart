//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/phone_verification_result.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'phone_verification_result_response.g.dart';

/// PhoneVerificationResultResponse
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PhoneVerificationResultResponse
    implements
        Built<PhoneVerificationResultResponse,
            PhoneVerificationResultResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  PhoneVerificationResult get data;

  PhoneVerificationResultResponse._();

  factory PhoneVerificationResultResponse(
          [void updates(PhoneVerificationResultResponseBuilder b)]) =
      _$PhoneVerificationResultResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PhoneVerificationResultResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PhoneVerificationResultResponse> get serializer =>
      _$PhoneVerificationResultResponseSerializer();
}

class _$PhoneVerificationResultResponseSerializer
    implements PrimitiveSerializer<PhoneVerificationResultResponse> {
  @override
  final Iterable<Type> types = const [
    PhoneVerificationResultResponse,
    _$PhoneVerificationResultResponse
  ];

  @override
  final String wireName = r'PhoneVerificationResultResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PhoneVerificationResultResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(PhoneVerificationResult),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PhoneVerificationResultResponse object, {
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
    required PhoneVerificationResultResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PhoneVerificationResult),
          ) as PhoneVerificationResult;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PhoneVerificationResultResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PhoneVerificationResultResponseBuilder();
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

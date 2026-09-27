//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/phone_challenge.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'phone_challenge_response.g.dart';

/// PhoneChallengeResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class PhoneChallengeResponse implements Built<PhoneChallengeResponse, PhoneChallengeResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  PhoneChallenge get data;

  PhoneChallengeResponse._();

  factory PhoneChallengeResponse([void updates(PhoneChallengeResponseBuilder b)]) = _$PhoneChallengeResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PhoneChallengeResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PhoneChallengeResponse> get serializer => _$PhoneChallengeResponseSerializer();
}

class _$PhoneChallengeResponseSerializer implements PrimitiveSerializer<PhoneChallengeResponse> {
  @override
  final Iterable<Type> types = const [PhoneChallengeResponse, _$PhoneChallengeResponse];

  @override
  final String wireName = r'PhoneChallengeResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PhoneChallengeResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(PhoneChallenge),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PhoneChallengeResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PhoneChallengeResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PhoneChallenge),
          ) as PhoneChallenge;
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
  PhoneChallengeResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PhoneChallengeResponseBuilder();
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


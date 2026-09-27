//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'phone_sign_in_request.g.dart';

/// PhoneSignInRequest
///
/// Properties:
/// * [phone]
@BuiltValue()
abstract class PhoneSignInRequest
    implements Built<PhoneSignInRequest, PhoneSignInRequestBuilder> {
  @BuiltValueField(wireName: r'phone')
  String get phone;

  PhoneSignInRequest._();

  factory PhoneSignInRequest([void updates(PhoneSignInRequestBuilder b)]) =
      _$PhoneSignInRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PhoneSignInRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PhoneSignInRequest> get serializer =>
      _$PhoneSignInRequestSerializer();
}

class _$PhoneSignInRequestSerializer
    implements PrimitiveSerializer<PhoneSignInRequest> {
  @override
  final Iterable<Type> types = const [PhoneSignInRequest, _$PhoneSignInRequest];

  @override
  final String wireName = r'PhoneSignInRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PhoneSignInRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'phone';
    yield serializers.serialize(
      object.phone,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PhoneSignInRequest object, {
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
    required PhoneSignInRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.phone = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PhoneSignInRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PhoneSignInRequestBuilder();
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

//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'payments_subscribe_post200_response.g.dart';

/// PaymentsSubscribePost200Response
///
/// Properties:
/// * [authorizationUrl] 
/// * [reference] 
@BuiltValue()
abstract class PaymentsSubscribePost200Response implements Built<PaymentsSubscribePost200Response, PaymentsSubscribePost200ResponseBuilder> {
  @BuiltValueField(wireName: r'authorizationUrl')
  String get authorizationUrl;

  @BuiltValueField(wireName: r'reference')
  String get reference;

  PaymentsSubscribePost200Response._();

  factory PaymentsSubscribePost200Response([void updates(PaymentsSubscribePost200ResponseBuilder b)]) = _$PaymentsSubscribePost200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PaymentsSubscribePost200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PaymentsSubscribePost200Response> get serializer => _$PaymentsSubscribePost200ResponseSerializer();
}

class _$PaymentsSubscribePost200ResponseSerializer implements PrimitiveSerializer<PaymentsSubscribePost200Response> {
  @override
  final Iterable<Type> types = const [PaymentsSubscribePost200Response, _$PaymentsSubscribePost200Response];

  @override
  final String wireName = r'PaymentsSubscribePost200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PaymentsSubscribePost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'authorizationUrl';
    yield serializers.serialize(
      object.authorizationUrl,
      specifiedType: const FullType(String),
    );
    yield r'reference';
    yield serializers.serialize(
      object.reference,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PaymentsSubscribePost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PaymentsSubscribePost200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'authorizationUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.authorizationUrl = valueDes;
          break;
        case r'reference':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reference = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PaymentsSubscribePost200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PaymentsSubscribePost200ResponseBuilder();
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


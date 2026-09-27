//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/passkey_registration_options.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'passkey_registration_options_response.g.dart';

/// PasskeyRegistrationOptionsResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class PasskeyRegistrationOptionsResponse implements Built<PasskeyRegistrationOptionsResponse, PasskeyRegistrationOptionsResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  PasskeyRegistrationOptions get data;

  PasskeyRegistrationOptionsResponse._();

  factory PasskeyRegistrationOptionsResponse([void updates(PasskeyRegistrationOptionsResponseBuilder b)]) = _$PasskeyRegistrationOptionsResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PasskeyRegistrationOptionsResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PasskeyRegistrationOptionsResponse> get serializer => _$PasskeyRegistrationOptionsResponseSerializer();
}

class _$PasskeyRegistrationOptionsResponseSerializer implements PrimitiveSerializer<PasskeyRegistrationOptionsResponse> {
  @override
  final Iterable<Type> types = const [PasskeyRegistrationOptionsResponse, _$PasskeyRegistrationOptionsResponse];

  @override
  final String wireName = r'PasskeyRegistrationOptionsResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PasskeyRegistrationOptionsResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(PasskeyRegistrationOptions),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PasskeyRegistrationOptionsResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PasskeyRegistrationOptionsResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PasskeyRegistrationOptions),
          ) as PasskeyRegistrationOptions;
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
  PasskeyRegistrationOptionsResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PasskeyRegistrationOptionsResponseBuilder();
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


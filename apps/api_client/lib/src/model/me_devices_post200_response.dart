//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'me_devices_post200_response.g.dart';

/// MeDevicesPost200Response
///
/// Properties:
/// * [registered] 
@BuiltValue()
abstract class MeDevicesPost200Response implements Built<MeDevicesPost200Response, MeDevicesPost200ResponseBuilder> {
  @BuiltValueField(wireName: r'registered')
  bool get registered;

  MeDevicesPost200Response._();

  factory MeDevicesPost200Response([void updates(MeDevicesPost200ResponseBuilder b)]) = _$MeDevicesPost200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MeDevicesPost200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MeDevicesPost200Response> get serializer => _$MeDevicesPost200ResponseSerializer();
}

class _$MeDevicesPost200ResponseSerializer implements PrimitiveSerializer<MeDevicesPost200Response> {
  @override
  final Iterable<Type> types = const [MeDevicesPost200Response, _$MeDevicesPost200Response];

  @override
  final String wireName = r'MeDevicesPost200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MeDevicesPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'registered';
    yield serializers.serialize(
      object.registered,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MeDevicesPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MeDevicesPost200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'registered':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.registered = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MeDevicesPost200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MeDevicesPost200ResponseBuilder();
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


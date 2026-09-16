//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/minimum_version.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'minimum_version_response.g.dart';

/// MinimumVersionResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class MinimumVersionResponse implements Built<MinimumVersionResponse, MinimumVersionResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MinimumVersion get data;

  MinimumVersionResponse._();

  factory MinimumVersionResponse([void updates(MinimumVersionResponseBuilder b)]) = _$MinimumVersionResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MinimumVersionResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MinimumVersionResponse> get serializer => _$MinimumVersionResponseSerializer();
}

class _$MinimumVersionResponseSerializer implements PrimitiveSerializer<MinimumVersionResponse> {
  @override
  final Iterable<Type> types = const [MinimumVersionResponse, _$MinimumVersionResponse];

  @override
  final String wireName = r'MinimumVersionResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MinimumVersionResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(MinimumVersion),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MinimumVersionResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MinimumVersionResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MinimumVersion),
          ) as MinimumVersion;
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
  MinimumVersionResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MinimumVersionResponseBuilder();
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


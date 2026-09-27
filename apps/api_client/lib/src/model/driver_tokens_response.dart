//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/driver_tokens.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'driver_tokens_response.g.dart';

/// DriverTokensResponse
///
/// Properties:
<<<<<<< HEAD
/// * [data] 
@BuiltValue()
abstract class DriverTokensResponse implements Built<DriverTokensResponse, DriverTokensResponseBuilder> {
=======
/// * [data]
@BuiltValue()
abstract class DriverTokensResponse
    implements Built<DriverTokensResponse, DriverTokensResponseBuilder> {
>>>>>>> origin/main
  @BuiltValueField(wireName: r'data')
  DriverTokens get data;

  DriverTokensResponse._();

<<<<<<< HEAD
  factory DriverTokensResponse([void updates(DriverTokensResponseBuilder b)]) = _$DriverTokensResponse;
=======
  factory DriverTokensResponse([void updates(DriverTokensResponseBuilder b)]) =
      _$DriverTokensResponse;
>>>>>>> origin/main

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DriverTokensResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
<<<<<<< HEAD
  static Serializer<DriverTokensResponse> get serializer => _$DriverTokensResponseSerializer();
}

class _$DriverTokensResponseSerializer implements PrimitiveSerializer<DriverTokensResponse> {
  @override
  final Iterable<Type> types = const [DriverTokensResponse, _$DriverTokensResponse];
=======
  static Serializer<DriverTokensResponse> get serializer =>
      _$DriverTokensResponseSerializer();
}

class _$DriverTokensResponseSerializer
    implements PrimitiveSerializer<DriverTokensResponse> {
  @override
  final Iterable<Type> types = const [
    DriverTokensResponse,
    _$DriverTokensResponse
  ];
>>>>>>> origin/main

  @override
  final String wireName = r'DriverTokensResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DriverTokensResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(DriverTokens),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DriverTokensResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
<<<<<<< HEAD
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
=======
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
>>>>>>> origin/main
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DriverTokensResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DriverTokens),
          ) as DriverTokens;
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
  DriverTokensResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DriverTokensResponseBuilder();
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
<<<<<<< HEAD

=======
>>>>>>> origin/main

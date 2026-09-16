//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/commute_request.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commute_request_response.g.dart';

/// CommuteRequestResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class CommuteRequestResponse implements Built<CommuteRequestResponse, CommuteRequestResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  CommuteRequest get data;

  CommuteRequestResponse._();

  factory CommuteRequestResponse([void updates(CommuteRequestResponseBuilder b)]) = _$CommuteRequestResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommuteRequestResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommuteRequestResponse> get serializer => _$CommuteRequestResponseSerializer();
}

class _$CommuteRequestResponseSerializer implements PrimitiveSerializer<CommuteRequestResponse> {
  @override
  final Iterable<Type> types = const [CommuteRequestResponse, _$CommuteRequestResponse];

  @override
  final String wireName = r'CommuteRequestResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommuteRequestResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(CommuteRequest),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CommuteRequestResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CommuteRequestResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CommuteRequest),
          ) as CommuteRequest;
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
  CommuteRequestResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommuteRequestResponseBuilder();
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


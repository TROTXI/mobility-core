//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/fare.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'fare_response.g.dart';

/// FareResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class FareResponse implements Built<FareResponse, FareResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  Fare get data;

  FareResponse._();

  factory FareResponse([void updates(FareResponseBuilder b)]) = _$FareResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FareResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FareResponse> get serializer => _$FareResponseSerializer();
}

class _$FareResponseSerializer implements PrimitiveSerializer<FareResponse> {
  @override
  final Iterable<Type> types = const [FareResponse, _$FareResponse];

  @override
  final String wireName = r'FareResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FareResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(Fare),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FareResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FareResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Fare),
          ) as Fare;
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
  FareResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FareResponseBuilder();
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


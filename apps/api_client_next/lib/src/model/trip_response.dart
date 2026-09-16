//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/trip.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'trip_response.g.dart';

/// TripResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class TripResponse implements Built<TripResponse, TripResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  Trip get data;

  TripResponse._();

  factory TripResponse([void updates(TripResponseBuilder b)]) = _$TripResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TripResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TripResponse> get serializer => _$TripResponseSerializer();
}

class _$TripResponseSerializer implements PrimitiveSerializer<TripResponse> {
  @override
  final Iterable<Type> types = const [TripResponse, _$TripResponse];

  @override
  final String wireName = r'TripResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TripResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(Trip),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TripResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TripResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Trip),
          ) as Trip;
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
  TripResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TripResponseBuilder();
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


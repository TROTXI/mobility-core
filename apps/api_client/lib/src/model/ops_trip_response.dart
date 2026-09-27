//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/ops_trip.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_trip_response.g.dart';

/// OpsTripResponse
///
/// Properties:
<<<<<<< HEAD
/// * [data] 
@BuiltValue()
abstract class OpsTripResponse implements Built<OpsTripResponse, OpsTripResponseBuilder> {
=======
/// * [data]
@BuiltValue()
abstract class OpsTripResponse
    implements Built<OpsTripResponse, OpsTripResponseBuilder> {
>>>>>>> origin/main
  @BuiltValueField(wireName: r'data')
  OpsTrip get data;

  OpsTripResponse._();

<<<<<<< HEAD
  factory OpsTripResponse([void updates(OpsTripResponseBuilder b)]) = _$OpsTripResponse;
=======
  factory OpsTripResponse([void updates(OpsTripResponseBuilder b)]) =
      _$OpsTripResponse;
>>>>>>> origin/main

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsTripResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
<<<<<<< HEAD
  static Serializer<OpsTripResponse> get serializer => _$OpsTripResponseSerializer();
}

class _$OpsTripResponseSerializer implements PrimitiveSerializer<OpsTripResponse> {
=======
  static Serializer<OpsTripResponse> get serializer =>
      _$OpsTripResponseSerializer();
}

class _$OpsTripResponseSerializer
    implements PrimitiveSerializer<OpsTripResponse> {
>>>>>>> origin/main
  @override
  final Iterable<Type> types = const [OpsTripResponse, _$OpsTripResponse];

  @override
  final String wireName = r'OpsTripResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsTripResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(OpsTrip),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsTripResponse object, {
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
    required OpsTripResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OpsTrip),
          ) as OpsTrip;
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
  OpsTripResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsTripResponseBuilder();
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

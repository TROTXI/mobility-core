//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'trips_id_arrive_post_request.g.dart';

/// TripsIdArrivePostRequest
///
/// Properties:
/// * [seq] 
@BuiltValue()
abstract class TripsIdArrivePostRequest implements Built<TripsIdArrivePostRequest, TripsIdArrivePostRequestBuilder> {
  @BuiltValueField(wireName: r'seq')
  int get seq;

  TripsIdArrivePostRequest._();

  factory TripsIdArrivePostRequest([void updates(TripsIdArrivePostRequestBuilder b)]) = _$TripsIdArrivePostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TripsIdArrivePostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TripsIdArrivePostRequest> get serializer => _$TripsIdArrivePostRequestSerializer();
}

class _$TripsIdArrivePostRequestSerializer implements PrimitiveSerializer<TripsIdArrivePostRequest> {
  @override
  final Iterable<Type> types = const [TripsIdArrivePostRequest, _$TripsIdArrivePostRequest];

  @override
  final String wireName = r'TripsIdArrivePostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TripsIdArrivePostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'seq';
    yield serializers.serialize(
      object.seq,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TripsIdArrivePostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TripsIdArrivePostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'seq':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.seq = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TripsIdArrivePostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TripsIdArrivePostRequestBuilder();
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


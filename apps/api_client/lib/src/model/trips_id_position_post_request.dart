//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'trips_id_position_post_request.g.dart';

/// TripsIdPositionPostRequest
///
/// Properties:
/// * [latitude] 
/// * [longitude] 
@BuiltValue()
abstract class TripsIdPositionPostRequest implements Built<TripsIdPositionPostRequest, TripsIdPositionPostRequestBuilder> {
  @BuiltValueField(wireName: r'latitude')
  num get latitude;

  @BuiltValueField(wireName: r'longitude')
  num get longitude;

  TripsIdPositionPostRequest._();

  factory TripsIdPositionPostRequest([void updates(TripsIdPositionPostRequestBuilder b)]) = _$TripsIdPositionPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TripsIdPositionPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TripsIdPositionPostRequest> get serializer => _$TripsIdPositionPostRequestSerializer();
}

class _$TripsIdPositionPostRequestSerializer implements PrimitiveSerializer<TripsIdPositionPostRequest> {
  @override
  final Iterable<Type> types = const [TripsIdPositionPostRequest, _$TripsIdPositionPostRequest];

  @override
  final String wireName = r'TripsIdPositionPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TripsIdPositionPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'latitude';
    yield serializers.serialize(
      object.latitude,
      specifiedType: const FullType(num),
    );
    yield r'longitude';
    yield serializers.serialize(
      object.longitude,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TripsIdPositionPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TripsIdPositionPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'latitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.latitude = valueDes;
          break;
        case r'longitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.longitude = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TripsIdPositionPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TripsIdPositionPostRequestBuilder();
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


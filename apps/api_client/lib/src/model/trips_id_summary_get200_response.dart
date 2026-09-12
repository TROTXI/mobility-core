//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/trips_id_summary_get200_response_by_method.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'trips_id_summary_get200_response.g.dart';

/// TripsIdSummaryGet200Response
///
/// Properties:
/// * [tripId] 
/// * [boarded] 
/// * [notBoarded] 
/// * [byMethod] 
/// * [startedAt] 
/// * [completedAt] 
/// * [stopCount] 
@BuiltValue()
abstract class TripsIdSummaryGet200Response implements Built<TripsIdSummaryGet200Response, TripsIdSummaryGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'tripId')
  String get tripId;

  @BuiltValueField(wireName: r'boarded')
  int get boarded;

  @BuiltValueField(wireName: r'notBoarded')
  int get notBoarded;

  @BuiltValueField(wireName: r'byMethod')
  TripsIdSummaryGet200ResponseByMethod get byMethod;

  @BuiltValueField(wireName: r'startedAt')
  DateTime? get startedAt;

  @BuiltValueField(wireName: r'completedAt')
  DateTime? get completedAt;

  @BuiltValueField(wireName: r'stopCount')
  int get stopCount;

  TripsIdSummaryGet200Response._();

  factory TripsIdSummaryGet200Response([void updates(TripsIdSummaryGet200ResponseBuilder b)]) = _$TripsIdSummaryGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TripsIdSummaryGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TripsIdSummaryGet200Response> get serializer => _$TripsIdSummaryGet200ResponseSerializer();
}

class _$TripsIdSummaryGet200ResponseSerializer implements PrimitiveSerializer<TripsIdSummaryGet200Response> {
  @override
  final Iterable<Type> types = const [TripsIdSummaryGet200Response, _$TripsIdSummaryGet200Response];

  @override
  final String wireName = r'TripsIdSummaryGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TripsIdSummaryGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'tripId';
    yield serializers.serialize(
      object.tripId,
      specifiedType: const FullType(String),
    );
    yield r'boarded';
    yield serializers.serialize(
      object.boarded,
      specifiedType: const FullType(int),
    );
    yield r'notBoarded';
    yield serializers.serialize(
      object.notBoarded,
      specifiedType: const FullType(int),
    );
    yield r'byMethod';
    yield serializers.serialize(
      object.byMethod,
      specifiedType: const FullType(TripsIdSummaryGet200ResponseByMethod),
    );
    yield r'startedAt';
    yield object.startedAt == null ? null : serializers.serialize(
      object.startedAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'completedAt';
    yield object.completedAt == null ? null : serializers.serialize(
      object.completedAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'stopCount';
    yield serializers.serialize(
      object.stopCount,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TripsIdSummaryGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TripsIdSummaryGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'tripId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.tripId = valueDes;
          break;
        case r'boarded':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.boarded = valueDes;
          break;
        case r'notBoarded':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.notBoarded = valueDes;
          break;
        case r'byMethod':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TripsIdSummaryGet200ResponseByMethod),
          ) as TripsIdSummaryGet200ResponseByMethod;
          result.byMethod.replace(valueDes);
          break;
        case r'startedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.startedAt = valueDes;
          break;
        case r'completedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.completedAt = valueDes;
          break;
        case r'stopCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.stopCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TripsIdSummaryGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TripsIdSummaryGet200ResponseBuilder();
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



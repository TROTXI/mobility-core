//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client_next/src/model/live_trip_position.dart';
import 'package:trotxi_api_client_next/src/model/stop_eta.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'live_trip.g.dart';

/// LiveTrip
///
/// Properties:
/// * [tripId] 
/// * [patternVersionId] 
/// * [geometryId] 
/// * [riderPickupOccurrenceId] 
/// * [state] 
/// * [position] 
/// * [etas] 
/// * [serverTime] 
@BuiltValue()
abstract class LiveTrip implements Built<LiveTrip, LiveTripBuilder> {
  @BuiltValueField(wireName: r'tripId')
  String get tripId;

  @BuiltValueField(wireName: r'patternVersionId')
  String get patternVersionId;

  @BuiltValueField(wireName: r'geometryId')
  String? get geometryId;

  @BuiltValueField(wireName: r'riderPickupOccurrenceId')
  String? get riderPickupOccurrenceId;

  @BuiltValueField(wireName: r'state')
  LiveTripStateEnum get state;
  // enum stateEnum {  not_started,  awaiting_fix,  live,  stale,  ended,  };

  @BuiltValueField(wireName: r'position')
  LiveTripPosition? get position;

  @BuiltValueField(wireName: r'etas')
  BuiltList<StopEta> get etas;

  @BuiltValueField(wireName: r'serverTime')
  DateTime get serverTime;

  LiveTrip._();

  factory LiveTrip([void updates(LiveTripBuilder b)]) = _$LiveTrip;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LiveTripBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LiveTrip> get serializer => _$LiveTripSerializer();
}

class _$LiveTripSerializer implements PrimitiveSerializer<LiveTrip> {
  @override
  final Iterable<Type> types = const [LiveTrip, _$LiveTrip];

  @override
  final String wireName = r'LiveTrip';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LiveTrip object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'tripId';
    yield serializers.serialize(
      object.tripId,
      specifiedType: const FullType(String),
    );
    yield r'patternVersionId';
    yield serializers.serialize(
      object.patternVersionId,
      specifiedType: const FullType(String),
    );
    yield r'geometryId';
    yield object.geometryId == null ? null : serializers.serialize(
      object.geometryId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'riderPickupOccurrenceId';
    yield object.riderPickupOccurrenceId == null ? null : serializers.serialize(
      object.riderPickupOccurrenceId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'state';
    yield serializers.serialize(
      object.state,
      specifiedType: const FullType(LiveTripStateEnum),
    );
    yield r'position';
    yield object.position == null ? null : serializers.serialize(
      object.position,
      specifiedType: const FullType.nullable(LiveTripPosition),
    );
    yield r'etas';
    yield serializers.serialize(
      object.etas,
      specifiedType: const FullType(BuiltList, [FullType(StopEta)]),
    );
    yield r'serverTime';
    yield serializers.serialize(
      object.serverTime,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    LiveTrip object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required LiveTripBuilder result,
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
        case r'patternVersionId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.patternVersionId = valueDes;
          break;
        case r'geometryId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.geometryId = valueDes;
          break;
        case r'riderPickupOccurrenceId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.riderPickupOccurrenceId = valueDes;
          break;
        case r'state':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(LiveTripStateEnum),
          ) as LiveTripStateEnum;
          result.state = valueDes;
          break;
        case r'position':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(LiveTripPosition),
          ) as LiveTripPosition?;
          if (valueDes == null) continue;
          result.position.replace(valueDes);
          break;
        case r'etas':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(StopEta)]),
          ) as BuiltList<StopEta>;
          result.etas.replace(valueDes);
          break;
        case r'serverTime':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.serverTime = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  LiveTrip deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LiveTripBuilder();
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

class LiveTripStateEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'not_started')
  static const LiveTripStateEnum notStarted = _$liveTripStateEnum_notStarted;
  @BuiltValueEnumConst(wireName: r'awaiting_fix')
  static const LiveTripStateEnum awaitingFix = _$liveTripStateEnum_awaitingFix;
  @BuiltValueEnumConst(wireName: r'live')
  static const LiveTripStateEnum live = _$liveTripStateEnum_live;
  @BuiltValueEnumConst(wireName: r'stale')
  static const LiveTripStateEnum stale = _$liveTripStateEnum_stale;
  @BuiltValueEnumConst(wireName: r'ended')
  static const LiveTripStateEnum ended = _$liveTripStateEnum_ended;

  static Serializer<LiveTripStateEnum> get serializer => _$liveTripStateEnumSerializer;

  const LiveTripStateEnum._(String name): super(name);

  static BuiltSet<LiveTripStateEnum> get values => _$liveTripStateEnumValues;
  static LiveTripStateEnum valueOf(String name) => _$liveTripStateEnumValueOf(name);
}


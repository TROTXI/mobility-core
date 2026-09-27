//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_overview_tiles.g.dart';

/// OpsOverviewTiles
///
/// Properties:
/// * [trips] 
/// * [inProgress] 
/// * [completed] 
/// * [cancelled] 
/// * [seatCapacity] 
/// * [seatsConfirmed] 
/// * [boarded] 
/// * [noShows] 
/// * [awaitingResolution] 
/// * [staleGps] 
/// * [unassigned] 
@BuiltValue()
abstract class OpsOverviewTiles implements Built<OpsOverviewTiles, OpsOverviewTilesBuilder> {
  @BuiltValueField(wireName: r'trips')
  int get trips;

  @BuiltValueField(wireName: r'inProgress')
  int get inProgress;

  @BuiltValueField(wireName: r'completed')
  int get completed;

  @BuiltValueField(wireName: r'cancelled')
  int get cancelled;

  @BuiltValueField(wireName: r'seatCapacity')
  int get seatCapacity;

  @BuiltValueField(wireName: r'seatsConfirmed')
  int get seatsConfirmed;

  @BuiltValueField(wireName: r'boarded')
  int get boarded;

  @BuiltValueField(wireName: r'noShows')
  int get noShows;

  @BuiltValueField(wireName: r'awaitingResolution')
  int get awaitingResolution;

  @BuiltValueField(wireName: r'staleGps')
  int get staleGps;

  @BuiltValueField(wireName: r'unassigned')
  int get unassigned;

  OpsOverviewTiles._();

  factory OpsOverviewTiles([void updates(OpsOverviewTilesBuilder b)]) = _$OpsOverviewTiles;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsOverviewTilesBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsOverviewTiles> get serializer => _$OpsOverviewTilesSerializer();
}

class _$OpsOverviewTilesSerializer implements PrimitiveSerializer<OpsOverviewTiles> {
  @override
  final Iterable<Type> types = const [OpsOverviewTiles, _$OpsOverviewTiles];

  @override
  final String wireName = r'OpsOverviewTiles';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsOverviewTiles object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'trips';
    yield serializers.serialize(
      object.trips,
      specifiedType: const FullType(int),
    );
    yield r'inProgress';
    yield serializers.serialize(
      object.inProgress,
      specifiedType: const FullType(int),
    );
    yield r'completed';
    yield serializers.serialize(
      object.completed,
      specifiedType: const FullType(int),
    );
    yield r'cancelled';
    yield serializers.serialize(
      object.cancelled,
      specifiedType: const FullType(int),
    );
    yield r'seatCapacity';
    yield serializers.serialize(
      object.seatCapacity,
      specifiedType: const FullType(int),
    );
    yield r'seatsConfirmed';
    yield serializers.serialize(
      object.seatsConfirmed,
      specifiedType: const FullType(int),
    );
    yield r'boarded';
    yield serializers.serialize(
      object.boarded,
      specifiedType: const FullType(int),
    );
    yield r'noShows';
    yield serializers.serialize(
      object.noShows,
      specifiedType: const FullType(int),
    );
    yield r'awaitingResolution';
    yield serializers.serialize(
      object.awaitingResolution,
      specifiedType: const FullType(int),
    );
    yield r'staleGps';
    yield serializers.serialize(
      object.staleGps,
      specifiedType: const FullType(int),
    );
    yield r'unassigned';
    yield serializers.serialize(
      object.unassigned,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsOverviewTiles object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OpsOverviewTilesBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'trips':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.trips = valueDes;
          break;
        case r'inProgress':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.inProgress = valueDes;
          break;
        case r'completed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.completed = valueDes;
          break;
        case r'cancelled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.cancelled = valueDes;
          break;
        case r'seatCapacity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.seatCapacity = valueDes;
          break;
        case r'seatsConfirmed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.seatsConfirmed = valueDes;
          break;
        case r'boarded':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.boarded = valueDes;
          break;
        case r'noShows':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.noShows = valueDes;
          break;
        case r'awaitingResolution':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.awaitingResolution = valueDes;
          break;
        case r'staleGps':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.staleGps = valueDes;
          break;
        case r'unassigned':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.unassigned = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OpsOverviewTiles deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsOverviewTilesBuilder();
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


//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'trips_id_position_get200_response_eta_to_stops_inner.g.dart';

/// TripsIdPositionGet200ResponseEtaToStopsInner
///
/// Properties:
/// * [stopId] 
/// * [seq] 
/// * [name] 
/// * [distanceMeters] 
/// * [etaSeconds] 
@BuiltValue()
abstract class TripsIdPositionGet200ResponseEtaToStopsInner implements Built<TripsIdPositionGet200ResponseEtaToStopsInner, TripsIdPositionGet200ResponseEtaToStopsInnerBuilder> {
  @BuiltValueField(wireName: r'stopId')
  String get stopId;

  @BuiltValueField(wireName: r'seq')
  int get seq;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'distanceMeters')
  num get distanceMeters;

  @BuiltValueField(wireName: r'etaSeconds')
  num get etaSeconds;

  TripsIdPositionGet200ResponseEtaToStopsInner._();

  factory TripsIdPositionGet200ResponseEtaToStopsInner([void updates(TripsIdPositionGet200ResponseEtaToStopsInnerBuilder b)]) = _$TripsIdPositionGet200ResponseEtaToStopsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TripsIdPositionGet200ResponseEtaToStopsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TripsIdPositionGet200ResponseEtaToStopsInner> get serializer => _$TripsIdPositionGet200ResponseEtaToStopsInnerSerializer();
}

class _$TripsIdPositionGet200ResponseEtaToStopsInnerSerializer implements PrimitiveSerializer<TripsIdPositionGet200ResponseEtaToStopsInner> {
  @override
  final Iterable<Type> types = const [TripsIdPositionGet200ResponseEtaToStopsInner, _$TripsIdPositionGet200ResponseEtaToStopsInner];

  @override
  final String wireName = r'TripsIdPositionGet200ResponseEtaToStopsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TripsIdPositionGet200ResponseEtaToStopsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'stopId';
    yield serializers.serialize(
      object.stopId,
      specifiedType: const FullType(String),
    );
    yield r'seq';
    yield serializers.serialize(
      object.seq,
      specifiedType: const FullType(int),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'distanceMeters';
    yield serializers.serialize(
      object.distanceMeters,
      specifiedType: const FullType(num),
    );
    yield r'etaSeconds';
    yield serializers.serialize(
      object.etaSeconds,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TripsIdPositionGet200ResponseEtaToStopsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TripsIdPositionGet200ResponseEtaToStopsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'stopId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.stopId = valueDes;
          break;
        case r'seq':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.seq = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'distanceMeters':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.distanceMeters = valueDes;
          break;
        case r'etaSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.etaSeconds = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TripsIdPositionGet200ResponseEtaToStopsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TripsIdPositionGet200ResponseEtaToStopsInnerBuilder();
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


//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'trip_summary.g.dart';

/// TripSummary
///
/// Properties:
/// * [tripId] 
/// * [status] 
/// * [boarded] 
/// * [noShows] 
/// * [unseated] 
/// * [scanned] 
/// * [codeVerified] 
/// * [photoVerified] 
@BuiltValue()
abstract class TripSummary implements Built<TripSummary, TripSummaryBuilder> {
  @BuiltValueField(wireName: r'tripId')
  String get tripId;

  @BuiltValueField(wireName: r'status')
  TripSummaryStatusEnum get status;
  // enum statusEnum {  scheduled,  active,  completed,  cancelled,  };

  @BuiltValueField(wireName: r'boarded')
  int get boarded;

  @BuiltValueField(wireName: r'noShows')
  int get noShows;

  @BuiltValueField(wireName: r'unseated')
  int get unseated;

  @BuiltValueField(wireName: r'scanned')
  int get scanned;

  @BuiltValueField(wireName: r'codeVerified')
  int get codeVerified;

  @BuiltValueField(wireName: r'photoVerified')
  int get photoVerified;

  TripSummary._();

  factory TripSummary([void updates(TripSummaryBuilder b)]) = _$TripSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TripSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TripSummary> get serializer => _$TripSummarySerializer();
}

class _$TripSummarySerializer implements PrimitiveSerializer<TripSummary> {
  @override
  final Iterable<Type> types = const [TripSummary, _$TripSummary];

  @override
  final String wireName = r'TripSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TripSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'tripId';
    yield serializers.serialize(
      object.tripId,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(TripSummaryStatusEnum),
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
    yield r'unseated';
    yield serializers.serialize(
      object.unseated,
      specifiedType: const FullType(int),
    );
    yield r'scanned';
    yield serializers.serialize(
      object.scanned,
      specifiedType: const FullType(int),
    );
    yield r'codeVerified';
    yield serializers.serialize(
      object.codeVerified,
      specifiedType: const FullType(int),
    );
    yield r'photoVerified';
    yield serializers.serialize(
      object.photoVerified,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TripSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TripSummaryBuilder result,
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
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TripSummaryStatusEnum),
          ) as TripSummaryStatusEnum;
          result.status = valueDes;
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
        case r'unseated':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.unseated = valueDes;
          break;
        case r'scanned':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.scanned = valueDes;
          break;
        case r'codeVerified':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.codeVerified = valueDes;
          break;
        case r'photoVerified':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.photoVerified = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TripSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TripSummaryBuilder();
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

class TripSummaryStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'scheduled')
  static const TripSummaryStatusEnum scheduled = _$tripSummaryStatusEnum_scheduled;
  @BuiltValueEnumConst(wireName: r'active')
  static const TripSummaryStatusEnum active = _$tripSummaryStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'completed')
  static const TripSummaryStatusEnum completed = _$tripSummaryStatusEnum_completed;
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const TripSummaryStatusEnum cancelled = _$tripSummaryStatusEnum_cancelled;

  static Serializer<TripSummaryStatusEnum> get serializer => _$tripSummaryStatusEnumSerializer;

  const TripSummaryStatusEnum._(String name): super(name);

  static BuiltSet<TripSummaryStatusEnum> get values => _$tripSummaryStatusEnumValues;
  static TripSummaryStatusEnum valueOf(String name) => _$tripSummaryStatusEnumValueOf(name);
}


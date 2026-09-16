//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commute_leg_view.g.dart';

/// CommuteLegView
///
/// Properties:
/// * [direction] 
/// * [scheduleId] 
/// * [patternVersionId] 
/// * [pickupOccurrenceId] 
/// * [dropoffOccurrenceId] 
/// * [localDeparture] 
/// * [timeZone] 
/// * [pickupName] 
/// * [dropoffName] 
@BuiltValue()
abstract class CommuteLegView implements Built<CommuteLegView, CommuteLegViewBuilder> {
  @BuiltValueField(wireName: r'direction')
  CommuteLegViewDirectionEnum get direction;
  // enum directionEnum {  outbound,  return,  };

  @BuiltValueField(wireName: r'scheduleId')
  String get scheduleId;

  @BuiltValueField(wireName: r'patternVersionId')
  String get patternVersionId;

  @BuiltValueField(wireName: r'pickupOccurrenceId')
  String get pickupOccurrenceId;

  @BuiltValueField(wireName: r'dropoffOccurrenceId')
  String get dropoffOccurrenceId;

  @BuiltValueField(wireName: r'localDeparture')
  String get localDeparture;

  @BuiltValueField(wireName: r'timeZone')
  CommuteLegViewTimeZoneEnum get timeZone;
  // enum timeZoneEnum {  Africa/Accra,  };

  @BuiltValueField(wireName: r'pickupName')
  String get pickupName;

  @BuiltValueField(wireName: r'dropoffName')
  String get dropoffName;

  CommuteLegView._();

  factory CommuteLegView([void updates(CommuteLegViewBuilder b)]) = _$CommuteLegView;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommuteLegViewBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommuteLegView> get serializer => _$CommuteLegViewSerializer();
}

class _$CommuteLegViewSerializer implements PrimitiveSerializer<CommuteLegView> {
  @override
  final Iterable<Type> types = const [CommuteLegView, _$CommuteLegView];

  @override
  final String wireName = r'CommuteLegView';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommuteLegView object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'direction';
    yield serializers.serialize(
      object.direction,
      specifiedType: const FullType(CommuteLegViewDirectionEnum),
    );
    yield r'scheduleId';
    yield serializers.serialize(
      object.scheduleId,
      specifiedType: const FullType(String),
    );
    yield r'patternVersionId';
    yield serializers.serialize(
      object.patternVersionId,
      specifiedType: const FullType(String),
    );
    yield r'pickupOccurrenceId';
    yield serializers.serialize(
      object.pickupOccurrenceId,
      specifiedType: const FullType(String),
    );
    yield r'dropoffOccurrenceId';
    yield serializers.serialize(
      object.dropoffOccurrenceId,
      specifiedType: const FullType(String),
    );
    yield r'localDeparture';
    yield serializers.serialize(
      object.localDeparture,
      specifiedType: const FullType(String),
    );
    yield r'timeZone';
    yield serializers.serialize(
      object.timeZone,
      specifiedType: const FullType(CommuteLegViewTimeZoneEnum),
    );
    yield r'pickupName';
    yield serializers.serialize(
      object.pickupName,
      specifiedType: const FullType(String),
    );
    yield r'dropoffName';
    yield serializers.serialize(
      object.dropoffName,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CommuteLegView object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CommuteLegViewBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'direction':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CommuteLegViewDirectionEnum),
          ) as CommuteLegViewDirectionEnum;
          result.direction = valueDes;
          break;
        case r'scheduleId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.scheduleId = valueDes;
          break;
        case r'patternVersionId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.patternVersionId = valueDes;
          break;
        case r'pickupOccurrenceId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.pickupOccurrenceId = valueDes;
          break;
        case r'dropoffOccurrenceId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.dropoffOccurrenceId = valueDes;
          break;
        case r'localDeparture':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.localDeparture = valueDes;
          break;
        case r'timeZone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CommuteLegViewTimeZoneEnum),
          ) as CommuteLegViewTimeZoneEnum;
          result.timeZone = valueDes;
          break;
        case r'pickupName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.pickupName = valueDes;
          break;
        case r'dropoffName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.dropoffName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CommuteLegView deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommuteLegViewBuilder();
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

class CommuteLegViewDirectionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'outbound')
  static const CommuteLegViewDirectionEnum outbound = _$commuteLegViewDirectionEnum_outbound;
  @BuiltValueEnumConst(wireName: r'return')
  static const CommuteLegViewDirectionEnum return_ = _$commuteLegViewDirectionEnum_return_;

  static Serializer<CommuteLegViewDirectionEnum> get serializer => _$commuteLegViewDirectionEnumSerializer;

  const CommuteLegViewDirectionEnum._(String name): super(name);

  static BuiltSet<CommuteLegViewDirectionEnum> get values => _$commuteLegViewDirectionEnumValues;
  static CommuteLegViewDirectionEnum valueOf(String name) => _$commuteLegViewDirectionEnumValueOf(name);
}

class CommuteLegViewTimeZoneEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'Africa/Accra')
  static const CommuteLegViewTimeZoneEnum africaSlashAccra = _$commuteLegViewTimeZoneEnum_africaSlashAccra;

  static Serializer<CommuteLegViewTimeZoneEnum> get serializer => _$commuteLegViewTimeZoneEnumSerializer;

  const CommuteLegViewTimeZoneEnum._(String name): super(name);

  static BuiltSet<CommuteLegViewTimeZoneEnum> get values => _$commuteLegViewTimeZoneEnumValues;
  static CommuteLegViewTimeZoneEnum valueOf(String name) => _$commuteLegViewTimeZoneEnumValueOf(name);
}


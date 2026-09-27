//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/incident_location.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'incident.g.dart';

/// Incident
///
/// Properties:
/// * [id] 
/// * [tripId] 
/// * [vehicleId] 
/// * [category] 
/// * [note] 
/// * [location] 
/// * [status] 
/// * [resolution] 
/// * [createdAt] 
@BuiltValue()
abstract class Incident implements Built<Incident, IncidentBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'tripId')
  String? get tripId;

  @BuiltValueField(wireName: r'vehicleId')
  String? get vehicleId;

  @BuiltValueField(wireName: r'category')
  IncidentCategoryEnum get category;
  // enum categoryEnum {  vehicle,  collision,  passenger_safety,  route_blocked,  other,  };

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'location')
  IncidentLocation? get location;

  @BuiltValueField(wireName: r'status')
  IncidentStatusEnum get status;
  // enum statusEnum {  open,  acknowledged,  resolved,  };

  @BuiltValueField(wireName: r'resolution')
  String? get resolution;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  Incident._();

  factory Incident([void updates(IncidentBuilder b)]) = _$Incident;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(IncidentBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Incident> get serializer => _$IncidentSerializer();
}

class _$IncidentSerializer implements PrimitiveSerializer<Incident> {
  @override
  final Iterable<Type> types = const [Incident, _$Incident];

  @override
  final String wireName = r'Incident';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Incident object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'tripId';
    yield object.tripId == null ? null : serializers.serialize(
      object.tripId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'vehicleId';
    yield object.vehicleId == null ? null : serializers.serialize(
      object.vehicleId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'category';
    yield serializers.serialize(
      object.category,
      specifiedType: const FullType(IncidentCategoryEnum),
    );
    yield r'note';
    yield object.note == null ? null : serializers.serialize(
      object.note,
      specifiedType: const FullType.nullable(String),
    );
    yield r'location';
    yield object.location == null ? null : serializers.serialize(
      object.location,
      specifiedType: const FullType.nullable(IncidentLocation),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(IncidentStatusEnum),
    );
    yield r'resolution';
    yield object.resolution == null ? null : serializers.serialize(
      object.resolution,
      specifiedType: const FullType.nullable(String),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Incident object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required IncidentBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'tripId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.tripId = valueDes;
          break;
        case r'vehicleId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.vehicleId = valueDes;
          break;
        case r'category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(IncidentCategoryEnum),
          ) as IncidentCategoryEnum;
          result.category = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        case r'location':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(IncidentLocation),
          ) as IncidentLocation?;
          if (valueDes == null) continue;
          result.location.replace(valueDes);
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(IncidentStatusEnum),
          ) as IncidentStatusEnum;
          result.status = valueDes;
          break;
        case r'resolution':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.resolution = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Incident deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = IncidentBuilder();
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

class IncidentCategoryEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'vehicle')
  static const IncidentCategoryEnum vehicle = _$incidentCategoryEnum_vehicle;
  @BuiltValueEnumConst(wireName: r'collision')
  static const IncidentCategoryEnum collision = _$incidentCategoryEnum_collision;
  @BuiltValueEnumConst(wireName: r'passenger_safety')
  static const IncidentCategoryEnum passengerSafety = _$incidentCategoryEnum_passengerSafety;
  @BuiltValueEnumConst(wireName: r'route_blocked')
  static const IncidentCategoryEnum routeBlocked = _$incidentCategoryEnum_routeBlocked;
  @BuiltValueEnumConst(wireName: r'other')
  static const IncidentCategoryEnum other = _$incidentCategoryEnum_other;

  static Serializer<IncidentCategoryEnum> get serializer => _$incidentCategoryEnumSerializer;

  const IncidentCategoryEnum._(String name): super(name);

  static BuiltSet<IncidentCategoryEnum> get values => _$incidentCategoryEnumValues;
  static IncidentCategoryEnum valueOf(String name) => _$incidentCategoryEnumValueOf(name);
}

class IncidentStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'open')
  static const IncidentStatusEnum open = _$incidentStatusEnum_open;
  @BuiltValueEnumConst(wireName: r'acknowledged')
  static const IncidentStatusEnum acknowledged = _$incidentStatusEnum_acknowledged;
  @BuiltValueEnumConst(wireName: r'resolved')
  static const IncidentStatusEnum resolved = _$incidentStatusEnum_resolved;

  static Serializer<IncidentStatusEnum> get serializer => _$incidentStatusEnumSerializer;

  const IncidentStatusEnum._(String name): super(name);

  static BuiltSet<IncidentStatusEnum> get values => _$incidentStatusEnumValues;
  static IncidentStatusEnum valueOf(String name) => _$incidentStatusEnumValueOf(name);
}


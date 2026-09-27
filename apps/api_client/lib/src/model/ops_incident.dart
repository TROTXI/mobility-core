//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/incident_location.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_incident.g.dart';

/// OpsIncident
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
/// * [driverId] 
/// * [handledBy] 
/// * [handledAt] 
/// * [version] 
/// * [editToken] 
@BuiltValue()
abstract class OpsIncident implements Built<OpsIncident, OpsIncidentBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'tripId')
  String? get tripId;

  @BuiltValueField(wireName: r'vehicleId')
  String? get vehicleId;

  @BuiltValueField(wireName: r'category')
  OpsIncidentCategoryEnum get category;
  // enum categoryEnum {  vehicle,  collision,  passenger_safety,  route_blocked,  other,  };

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'location')
  IncidentLocation? get location;

  @BuiltValueField(wireName: r'status')
  OpsIncidentStatusEnum get status;
  // enum statusEnum {  open,  acknowledged,  resolved,  };

  @BuiltValueField(wireName: r'resolution')
  String? get resolution;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'driverId')
  String get driverId;

  @BuiltValueField(wireName: r'handledBy')
  String? get handledBy;

  @BuiltValueField(wireName: r'handledAt')
  DateTime? get handledAt;

  @BuiltValueField(wireName: r'version')
  int get version;

  @BuiltValueField(wireName: r'editToken')
  String get editToken;

  OpsIncident._();

  factory OpsIncident([void updates(OpsIncidentBuilder b)]) = _$OpsIncident;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsIncidentBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsIncident> get serializer => _$OpsIncidentSerializer();
}

class _$OpsIncidentSerializer implements PrimitiveSerializer<OpsIncident> {
  @override
  final Iterable<Type> types = const [OpsIncident, _$OpsIncident];

  @override
  final String wireName = r'OpsIncident';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsIncident object, {
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
      specifiedType: const FullType(OpsIncidentCategoryEnum),
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
      specifiedType: const FullType(OpsIncidentStatusEnum),
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
    yield r'driverId';
    yield serializers.serialize(
      object.driverId,
      specifiedType: const FullType(String),
    );
    yield r'handledBy';
    yield object.handledBy == null ? null : serializers.serialize(
      object.handledBy,
      specifiedType: const FullType.nullable(String),
    );
    yield r'handledAt';
    yield object.handledAt == null ? null : serializers.serialize(
      object.handledAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
    );
    yield r'editToken';
    yield serializers.serialize(
      object.editToken,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsIncident object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OpsIncidentBuilder result,
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
            specifiedType: const FullType(OpsIncidentCategoryEnum),
          ) as OpsIncidentCategoryEnum;
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
            specifiedType: const FullType(OpsIncidentStatusEnum),
          ) as OpsIncidentStatusEnum;
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
        case r'driverId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.driverId = valueDes;
          break;
        case r'handledBy':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.handledBy = valueDes;
          break;
        case r'handledAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.handledAt = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.version = valueDes;
          break;
        case r'editToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.editToken = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OpsIncident deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsIncidentBuilder();
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

class OpsIncidentCategoryEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'vehicle')
  static const OpsIncidentCategoryEnum vehicle = _$opsIncidentCategoryEnum_vehicle;
  @BuiltValueEnumConst(wireName: r'collision')
  static const OpsIncidentCategoryEnum collision = _$opsIncidentCategoryEnum_collision;
  @BuiltValueEnumConst(wireName: r'passenger_safety')
  static const OpsIncidentCategoryEnum passengerSafety = _$opsIncidentCategoryEnum_passengerSafety;
  @BuiltValueEnumConst(wireName: r'route_blocked')
  static const OpsIncidentCategoryEnum routeBlocked = _$opsIncidentCategoryEnum_routeBlocked;
  @BuiltValueEnumConst(wireName: r'other')
  static const OpsIncidentCategoryEnum other = _$opsIncidentCategoryEnum_other;

  static Serializer<OpsIncidentCategoryEnum> get serializer => _$opsIncidentCategoryEnumSerializer;

  const OpsIncidentCategoryEnum._(String name): super(name);

  static BuiltSet<OpsIncidentCategoryEnum> get values => _$opsIncidentCategoryEnumValues;
  static OpsIncidentCategoryEnum valueOf(String name) => _$opsIncidentCategoryEnumValueOf(name);
}

class OpsIncidentStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'open')
  static const OpsIncidentStatusEnum open = _$opsIncidentStatusEnum_open;
  @BuiltValueEnumConst(wireName: r'acknowledged')
  static const OpsIncidentStatusEnum acknowledged = _$opsIncidentStatusEnum_acknowledged;
  @BuiltValueEnumConst(wireName: r'resolved')
  static const OpsIncidentStatusEnum resolved = _$opsIncidentStatusEnum_resolved;

  static Serializer<OpsIncidentStatusEnum> get serializer => _$opsIncidentStatusEnumSerializer;

  const OpsIncidentStatusEnum._(String name): super(name);

  static BuiltSet<OpsIncidentStatusEnum> get values => _$opsIncidentStatusEnumValues;
  static OpsIncidentStatusEnum valueOf(String name) => _$opsIncidentStatusEnumValueOf(name);
}


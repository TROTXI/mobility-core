//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_incidents_get200_response_incidents_inner.g.dart';

/// AdminIncidentsGet200ResponseIncidentsInner
///
/// Properties:
/// * [id] 
/// * [tripId] 
/// * [vehicleId] 
/// * [category] 
/// * [note] 
/// * [lat] 
/// * [lng] 
/// * [status] 
/// * [resolution] 
/// * [occurredAt] 
/// * [createdAt] 
/// * [driverId] 
/// * [handledBy] 
/// * [handledAt] 
@BuiltValue()
abstract class AdminIncidentsGet200ResponseIncidentsInner implements Built<AdminIncidentsGet200ResponseIncidentsInner, AdminIncidentsGet200ResponseIncidentsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'tripId')
  String? get tripId;

  @BuiltValueField(wireName: r'vehicleId')
  String? get vehicleId;

  @BuiltValueField(wireName: r'category')
  AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum get category;
  // enum categoryEnum {  vehicle,  collision,  passenger_safety,  route_blocked,  other,  };

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'lat')
  num? get lat;

  @BuiltValueField(wireName: r'lng')
  num? get lng;

  @BuiltValueField(wireName: r'status')
  AdminIncidentsGet200ResponseIncidentsInnerStatusEnum get status;
  // enum statusEnum {  open,  acknowledged,  resolved,  };

  @BuiltValueField(wireName: r'resolution')
  String? get resolution;

  @BuiltValueField(wireName: r'occurredAt')
  DateTime get occurredAt;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'driverId')
  String get driverId;

  @BuiltValueField(wireName: r'handledBy')
  String? get handledBy;

  @BuiltValueField(wireName: r'handledAt')
  DateTime? get handledAt;

  AdminIncidentsGet200ResponseIncidentsInner._();

  factory AdminIncidentsGet200ResponseIncidentsInner([void updates(AdminIncidentsGet200ResponseIncidentsInnerBuilder b)]) = _$AdminIncidentsGet200ResponseIncidentsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminIncidentsGet200ResponseIncidentsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminIncidentsGet200ResponseIncidentsInner> get serializer => _$AdminIncidentsGet200ResponseIncidentsInnerSerializer();
}

class _$AdminIncidentsGet200ResponseIncidentsInnerSerializer implements PrimitiveSerializer<AdminIncidentsGet200ResponseIncidentsInner> {
  @override
  final Iterable<Type> types = const [AdminIncidentsGet200ResponseIncidentsInner, _$AdminIncidentsGet200ResponseIncidentsInner];

  @override
  final String wireName = r'AdminIncidentsGet200ResponseIncidentsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminIncidentsGet200ResponseIncidentsInner object, {
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
      specifiedType: const FullType(AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum),
    );
    yield r'note';
    yield object.note == null ? null : serializers.serialize(
      object.note,
      specifiedType: const FullType.nullable(String),
    );
    yield r'lat';
    yield object.lat == null ? null : serializers.serialize(
      object.lat,
      specifiedType: const FullType.nullable(num),
    );
    yield r'lng';
    yield object.lng == null ? null : serializers.serialize(
      object.lng,
      specifiedType: const FullType.nullable(num),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(AdminIncidentsGet200ResponseIncidentsInnerStatusEnum),
    );
    yield r'resolution';
    yield object.resolution == null ? null : serializers.serialize(
      object.resolution,
      specifiedType: const FullType.nullable(String),
    );
    yield r'occurredAt';
    yield serializers.serialize(
      object.occurredAt,
      specifiedType: const FullType(DateTime),
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
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminIncidentsGet200ResponseIncidentsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminIncidentsGet200ResponseIncidentsInnerBuilder result,
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
            specifiedType: const FullType(AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum),
          ) as AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum;
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
        case r'lat':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.lat = valueDes;
          break;
        case r'lng':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.lng = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminIncidentsGet200ResponseIncidentsInnerStatusEnum),
          ) as AdminIncidentsGet200ResponseIncidentsInnerStatusEnum;
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
        case r'occurredAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.occurredAt = valueDes;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminIncidentsGet200ResponseIncidentsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminIncidentsGet200ResponseIncidentsInnerBuilder();
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

class AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'vehicle')
  static const AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum vehicle = _$adminIncidentsGet200ResponseIncidentsInnerCategoryEnum_vehicle;
  @BuiltValueEnumConst(wireName: r'collision')
  static const AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum collision = _$adminIncidentsGet200ResponseIncidentsInnerCategoryEnum_collision;
  @BuiltValueEnumConst(wireName: r'passenger_safety')
  static const AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum passengerSafety = _$adminIncidentsGet200ResponseIncidentsInnerCategoryEnum_passengerSafety;
  @BuiltValueEnumConst(wireName: r'route_blocked')
  static const AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum routeBlocked = _$adminIncidentsGet200ResponseIncidentsInnerCategoryEnum_routeBlocked;
  @BuiltValueEnumConst(wireName: r'other')
  static const AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum other = _$adminIncidentsGet200ResponseIncidentsInnerCategoryEnum_other;

  static Serializer<AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum> get serializer => _$adminIncidentsGet200ResponseIncidentsInnerCategoryEnumSerializer;

  const AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum._(String name): super(name);

  static BuiltSet<AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum> get values => _$adminIncidentsGet200ResponseIncidentsInnerCategoryEnumValues;
  static AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum valueOf(String name) => _$adminIncidentsGet200ResponseIncidentsInnerCategoryEnumValueOf(name);
}

class AdminIncidentsGet200ResponseIncidentsInnerStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'open')
  static const AdminIncidentsGet200ResponseIncidentsInnerStatusEnum open = _$adminIncidentsGet200ResponseIncidentsInnerStatusEnum_open;
  @BuiltValueEnumConst(wireName: r'acknowledged')
  static const AdminIncidentsGet200ResponseIncidentsInnerStatusEnum acknowledged = _$adminIncidentsGet200ResponseIncidentsInnerStatusEnum_acknowledged;
  @BuiltValueEnumConst(wireName: r'resolved')
  static const AdminIncidentsGet200ResponseIncidentsInnerStatusEnum resolved = _$adminIncidentsGet200ResponseIncidentsInnerStatusEnum_resolved;

  static Serializer<AdminIncidentsGet200ResponseIncidentsInnerStatusEnum> get serializer => _$adminIncidentsGet200ResponseIncidentsInnerStatusEnumSerializer;

  const AdminIncidentsGet200ResponseIncidentsInnerStatusEnum._(String name): super(name);

  static BuiltSet<AdminIncidentsGet200ResponseIncidentsInnerStatusEnum> get values => _$adminIncidentsGet200ResponseIncidentsInnerStatusEnumValues;
  static AdminIncidentsGet200ResponseIncidentsInnerStatusEnum valueOf(String name) => _$adminIncidentsGet200ResponseIncidentsInnerStatusEnumValueOf(name);
}


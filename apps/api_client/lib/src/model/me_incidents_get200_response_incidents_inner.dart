//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'me_incidents_get200_response_incidents_inner.g.dart';

/// MeIncidentsGet200ResponseIncidentsInner
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
@BuiltValue()
abstract class MeIncidentsGet200ResponseIncidentsInner implements Built<MeIncidentsGet200ResponseIncidentsInner, MeIncidentsGet200ResponseIncidentsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'tripId')
  String? get tripId;

  @BuiltValueField(wireName: r'vehicleId')
  String? get vehicleId;

  @BuiltValueField(wireName: r'category')
  MeIncidentsGet200ResponseIncidentsInnerCategoryEnum get category;
  // enum categoryEnum {  vehicle,  collision,  passenger_safety,  route_blocked,  other,  };

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'lat')
  num? get lat;

  @BuiltValueField(wireName: r'lng')
  num? get lng;

  @BuiltValueField(wireName: r'status')
  MeIncidentsGet200ResponseIncidentsInnerStatusEnum get status;
  // enum statusEnum {  open,  acknowledged,  resolved,  };

  @BuiltValueField(wireName: r'resolution')
  String? get resolution;

  @BuiltValueField(wireName: r'occurredAt')
  DateTime get occurredAt;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  MeIncidentsGet200ResponseIncidentsInner._();

  factory MeIncidentsGet200ResponseIncidentsInner([void updates(MeIncidentsGet200ResponseIncidentsInnerBuilder b)]) = _$MeIncidentsGet200ResponseIncidentsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MeIncidentsGet200ResponseIncidentsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MeIncidentsGet200ResponseIncidentsInner> get serializer => _$MeIncidentsGet200ResponseIncidentsInnerSerializer();
}

class _$MeIncidentsGet200ResponseIncidentsInnerSerializer implements PrimitiveSerializer<MeIncidentsGet200ResponseIncidentsInner> {
  @override
  final Iterable<Type> types = const [MeIncidentsGet200ResponseIncidentsInner, _$MeIncidentsGet200ResponseIncidentsInner];

  @override
  final String wireName = r'MeIncidentsGet200ResponseIncidentsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MeIncidentsGet200ResponseIncidentsInner object, {
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
      specifiedType: const FullType(MeIncidentsGet200ResponseIncidentsInnerCategoryEnum),
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
      specifiedType: const FullType(MeIncidentsGet200ResponseIncidentsInnerStatusEnum),
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
  }

  @override
  Object serialize(
    Serializers serializers,
    MeIncidentsGet200ResponseIncidentsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MeIncidentsGet200ResponseIncidentsInnerBuilder result,
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
            specifiedType: const FullType(MeIncidentsGet200ResponseIncidentsInnerCategoryEnum),
          ) as MeIncidentsGet200ResponseIncidentsInnerCategoryEnum;
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
            specifiedType: const FullType(MeIncidentsGet200ResponseIncidentsInnerStatusEnum),
          ) as MeIncidentsGet200ResponseIncidentsInnerStatusEnum;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MeIncidentsGet200ResponseIncidentsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MeIncidentsGet200ResponseIncidentsInnerBuilder();
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

class MeIncidentsGet200ResponseIncidentsInnerCategoryEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'vehicle')
  static const MeIncidentsGet200ResponseIncidentsInnerCategoryEnum vehicle = _$meIncidentsGet200ResponseIncidentsInnerCategoryEnum_vehicle;
  @BuiltValueEnumConst(wireName: r'collision')
  static const MeIncidentsGet200ResponseIncidentsInnerCategoryEnum collision = _$meIncidentsGet200ResponseIncidentsInnerCategoryEnum_collision;
  @BuiltValueEnumConst(wireName: r'passenger_safety')
  static const MeIncidentsGet200ResponseIncidentsInnerCategoryEnum passengerSafety = _$meIncidentsGet200ResponseIncidentsInnerCategoryEnum_passengerSafety;
  @BuiltValueEnumConst(wireName: r'route_blocked')
  static const MeIncidentsGet200ResponseIncidentsInnerCategoryEnum routeBlocked = _$meIncidentsGet200ResponseIncidentsInnerCategoryEnum_routeBlocked;
  @BuiltValueEnumConst(wireName: r'other')
  static const MeIncidentsGet200ResponseIncidentsInnerCategoryEnum other = _$meIncidentsGet200ResponseIncidentsInnerCategoryEnum_other;

  static Serializer<MeIncidentsGet200ResponseIncidentsInnerCategoryEnum> get serializer => _$meIncidentsGet200ResponseIncidentsInnerCategoryEnumSerializer;

  const MeIncidentsGet200ResponseIncidentsInnerCategoryEnum._(String name): super(name);

  static BuiltSet<MeIncidentsGet200ResponseIncidentsInnerCategoryEnum> get values => _$meIncidentsGet200ResponseIncidentsInnerCategoryEnumValues;
  static MeIncidentsGet200ResponseIncidentsInnerCategoryEnum valueOf(String name) => _$meIncidentsGet200ResponseIncidentsInnerCategoryEnumValueOf(name);
}

class MeIncidentsGet200ResponseIncidentsInnerStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'open')
  static const MeIncidentsGet200ResponseIncidentsInnerStatusEnum open = _$meIncidentsGet200ResponseIncidentsInnerStatusEnum_open;
  @BuiltValueEnumConst(wireName: r'acknowledged')
  static const MeIncidentsGet200ResponseIncidentsInnerStatusEnum acknowledged = _$meIncidentsGet200ResponseIncidentsInnerStatusEnum_acknowledged;
  @BuiltValueEnumConst(wireName: r'resolved')
  static const MeIncidentsGet200ResponseIncidentsInnerStatusEnum resolved = _$meIncidentsGet200ResponseIncidentsInnerStatusEnum_resolved;

  static Serializer<MeIncidentsGet200ResponseIncidentsInnerStatusEnum> get serializer => _$meIncidentsGet200ResponseIncidentsInnerStatusEnumSerializer;

  const MeIncidentsGet200ResponseIncidentsInnerStatusEnum._(String name): super(name);

  static BuiltSet<MeIncidentsGet200ResponseIncidentsInnerStatusEnum> get values => _$meIncidentsGet200ResponseIncidentsInnerStatusEnumValues;
  static MeIncidentsGet200ResponseIncidentsInnerStatusEnum valueOf(String name) => _$meIncidentsGet200ResponseIncidentsInnerStatusEnumValueOf(name);
}


//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/incident_location.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_overview_trips_inner.g.dart';

/// OpsOverviewTripsInner
///
/// Properties:
/// * [tripId] 
/// * [scheduledAt] 
/// * [status] 
/// * [routeName] 
/// * [driverId] 
/// * [driverName] 
/// * [vehicleId] 
/// * [vehicleLabel] 
/// * [capacity] 
/// * [confirmed] 
/// * [boarded] 
/// * [noShow] 
/// * [lastFixAt] 
/// * [fixAgeSeconds] 
/// * [lastPosition] 
/// * [badge] 
@BuiltValue()
abstract class OpsOverviewTripsInner implements Built<OpsOverviewTripsInner, OpsOverviewTripsInnerBuilder> {
  @BuiltValueField(wireName: r'tripId')
  String get tripId;

  @BuiltValueField(wireName: r'scheduledAt')
  DateTime get scheduledAt;

  @BuiltValueField(wireName: r'status')
  OpsOverviewTripsInnerStatusEnum get status;
  // enum statusEnum {  scheduled,  active,  completed,  cancelled,  };

  @BuiltValueField(wireName: r'routeName')
  String? get routeName;

  @BuiltValueField(wireName: r'driverId')
  String? get driverId;

  @BuiltValueField(wireName: r'driverName')
  String? get driverName;

  @BuiltValueField(wireName: r'vehicleId')
  String? get vehicleId;

  @BuiltValueField(wireName: r'vehicleLabel')
  String? get vehicleLabel;

  @BuiltValueField(wireName: r'capacity')
  int? get capacity;

  @BuiltValueField(wireName: r'confirmed')
  int get confirmed;

  @BuiltValueField(wireName: r'boarded')
  int get boarded;

  @BuiltValueField(wireName: r'noShow')
  int get noShow;

  @BuiltValueField(wireName: r'lastFixAt')
  DateTime? get lastFixAt;

  @BuiltValueField(wireName: r'fixAgeSeconds')
  int? get fixAgeSeconds;

  @BuiltValueField(wireName: r'lastPosition')
  IncidentLocation? get lastPosition;

  @BuiltValueField(wireName: r'badge')
  OpsOverviewTripsInnerBadgeEnum get badge;
  // enum badgeEnum {  on_time,  stale_gps,  unassigned,  };

  OpsOverviewTripsInner._();

  factory OpsOverviewTripsInner([void updates(OpsOverviewTripsInnerBuilder b)]) = _$OpsOverviewTripsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsOverviewTripsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsOverviewTripsInner> get serializer => _$OpsOverviewTripsInnerSerializer();
}

class _$OpsOverviewTripsInnerSerializer implements PrimitiveSerializer<OpsOverviewTripsInner> {
  @override
  final Iterable<Type> types = const [OpsOverviewTripsInner, _$OpsOverviewTripsInner];

  @override
  final String wireName = r'OpsOverviewTripsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsOverviewTripsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'tripId';
    yield serializers.serialize(
      object.tripId,
      specifiedType: const FullType(String),
    );
    yield r'scheduledAt';
    yield serializers.serialize(
      object.scheduledAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(OpsOverviewTripsInnerStatusEnum),
    );
    yield r'routeName';
    yield object.routeName == null ? null : serializers.serialize(
      object.routeName,
      specifiedType: const FullType.nullable(String),
    );
    yield r'driverId';
    yield object.driverId == null ? null : serializers.serialize(
      object.driverId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'driverName';
    yield object.driverName == null ? null : serializers.serialize(
      object.driverName,
      specifiedType: const FullType.nullable(String),
    );
    yield r'vehicleId';
    yield object.vehicleId == null ? null : serializers.serialize(
      object.vehicleId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'vehicleLabel';
    yield object.vehicleLabel == null ? null : serializers.serialize(
      object.vehicleLabel,
      specifiedType: const FullType.nullable(String),
    );
    yield r'capacity';
    yield object.capacity == null ? null : serializers.serialize(
      object.capacity,
      specifiedType: const FullType.nullable(int),
    );
    yield r'confirmed';
    yield serializers.serialize(
      object.confirmed,
      specifiedType: const FullType(int),
    );
    yield r'boarded';
    yield serializers.serialize(
      object.boarded,
      specifiedType: const FullType(int),
    );
    yield r'noShow';
    yield serializers.serialize(
      object.noShow,
      specifiedType: const FullType(int),
    );
    yield r'lastFixAt';
    yield object.lastFixAt == null ? null : serializers.serialize(
      object.lastFixAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'fixAgeSeconds';
    yield object.fixAgeSeconds == null ? null : serializers.serialize(
      object.fixAgeSeconds,
      specifiedType: const FullType.nullable(int),
    );
    yield r'lastPosition';
    yield object.lastPosition == null ? null : serializers.serialize(
      object.lastPosition,
      specifiedType: const FullType.nullable(IncidentLocation),
    );
    yield r'badge';
    yield serializers.serialize(
      object.badge,
      specifiedType: const FullType(OpsOverviewTripsInnerBadgeEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsOverviewTripsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OpsOverviewTripsInnerBuilder result,
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
        case r'scheduledAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.scheduledAt = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OpsOverviewTripsInnerStatusEnum),
          ) as OpsOverviewTripsInnerStatusEnum;
          result.status = valueDes;
          break;
        case r'routeName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.routeName = valueDes;
          break;
        case r'driverId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.driverId = valueDes;
          break;
        case r'driverName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.driverName = valueDes;
          break;
        case r'vehicleId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.vehicleId = valueDes;
          break;
        case r'vehicleLabel':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.vehicleLabel = valueDes;
          break;
        case r'capacity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.capacity = valueDes;
          break;
        case r'confirmed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.confirmed = valueDes;
          break;
        case r'boarded':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.boarded = valueDes;
          break;
        case r'noShow':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.noShow = valueDes;
          break;
        case r'lastFixAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.lastFixAt = valueDes;
          break;
        case r'fixAgeSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.fixAgeSeconds = valueDes;
          break;
        case r'lastPosition':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(IncidentLocation),
          ) as IncidentLocation?;
          if (valueDes == null) continue;
          result.lastPosition.replace(valueDes);
          break;
        case r'badge':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OpsOverviewTripsInnerBadgeEnum),
          ) as OpsOverviewTripsInnerBadgeEnum;
          result.badge = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OpsOverviewTripsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsOverviewTripsInnerBuilder();
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

class OpsOverviewTripsInnerStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'scheduled')
  static const OpsOverviewTripsInnerStatusEnum scheduled = _$opsOverviewTripsInnerStatusEnum_scheduled;
  @BuiltValueEnumConst(wireName: r'active')
  static const OpsOverviewTripsInnerStatusEnum active = _$opsOverviewTripsInnerStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'completed')
  static const OpsOverviewTripsInnerStatusEnum completed = _$opsOverviewTripsInnerStatusEnum_completed;
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const OpsOverviewTripsInnerStatusEnum cancelled = _$opsOverviewTripsInnerStatusEnum_cancelled;

  static Serializer<OpsOverviewTripsInnerStatusEnum> get serializer => _$opsOverviewTripsInnerStatusEnumSerializer;

  const OpsOverviewTripsInnerStatusEnum._(String name): super(name);

  static BuiltSet<OpsOverviewTripsInnerStatusEnum> get values => _$opsOverviewTripsInnerStatusEnumValues;
  static OpsOverviewTripsInnerStatusEnum valueOf(String name) => _$opsOverviewTripsInnerStatusEnumValueOf(name);
}

class OpsOverviewTripsInnerBadgeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'on_time')
  static const OpsOverviewTripsInnerBadgeEnum onTime = _$opsOverviewTripsInnerBadgeEnum_onTime;
  @BuiltValueEnumConst(wireName: r'stale_gps')
  static const OpsOverviewTripsInnerBadgeEnum staleGps = _$opsOverviewTripsInnerBadgeEnum_staleGps;
  @BuiltValueEnumConst(wireName: r'unassigned')
  static const OpsOverviewTripsInnerBadgeEnum unassigned = _$opsOverviewTripsInnerBadgeEnum_unassigned;

  static Serializer<OpsOverviewTripsInnerBadgeEnum> get serializer => _$opsOverviewTripsInnerBadgeEnumSerializer;

  const OpsOverviewTripsInnerBadgeEnum._(String name): super(name);

  static BuiltSet<OpsOverviewTripsInnerBadgeEnum> get values => _$opsOverviewTripsInnerBadgeEnumValues;
  static OpsOverviewTripsInnerBadgeEnum valueOf(String name) => _$opsOverviewTripsInnerBadgeEnumValueOf(name);
}


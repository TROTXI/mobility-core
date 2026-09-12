//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/trips_id_get200_response_vehicle.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'trips_id_get200_response.g.dart';

/// TripsIdGet200Response
///
/// Properties:
/// * [id] 
/// * [routeId] 
/// * [vehicleId] 
/// * [assignedDriverId] 
/// * [status] 
/// * [scheduledAt] 
/// * [createdAt] 
/// * [startedAt] 
/// * [completedAt] 
/// * [durationSeconds] 
/// * [vehicle] 
@BuiltValue()
abstract class TripsIdGet200Response implements Built<TripsIdGet200Response, TripsIdGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'routeId')
  String get routeId;

  @BuiltValueField(wireName: r'vehicleId')
  String? get vehicleId;

  @BuiltValueField(wireName: r'assignedDriverId')
  String? get assignedDriverId;

  @BuiltValueField(wireName: r'status')
  TripsIdGet200ResponseStatusEnum get status;
  // enum statusEnum {  scheduled,  active,  completed,  cancelled,  };

  @BuiltValueField(wireName: r'scheduledAt')
  DateTime get scheduledAt;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'startedAt')
  DateTime? get startedAt;

  @BuiltValueField(wireName: r'completedAt')
  DateTime? get completedAt;

  @BuiltValueField(wireName: r'durationSeconds')
  int? get durationSeconds;

  @BuiltValueField(wireName: r'vehicle')
  TripsIdGet200ResponseVehicle? get vehicle;

  TripsIdGet200Response._();

  factory TripsIdGet200Response([void updates(TripsIdGet200ResponseBuilder b)]) = _$TripsIdGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TripsIdGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TripsIdGet200Response> get serializer => _$TripsIdGet200ResponseSerializer();
}

class _$TripsIdGet200ResponseSerializer implements PrimitiveSerializer<TripsIdGet200Response> {
  @override
  final Iterable<Type> types = const [TripsIdGet200Response, _$TripsIdGet200Response];

  @override
  final String wireName = r'TripsIdGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TripsIdGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'routeId';
    yield serializers.serialize(
      object.routeId,
      specifiedType: const FullType(String),
    );
    yield r'vehicleId';
    yield object.vehicleId == null ? null : serializers.serialize(
      object.vehicleId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'assignedDriverId';
    yield object.assignedDriverId == null ? null : serializers.serialize(
      object.assignedDriverId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(TripsIdGet200ResponseStatusEnum),
    );
    yield r'scheduledAt';
    yield serializers.serialize(
      object.scheduledAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'startedAt';
    yield object.startedAt == null ? null : serializers.serialize(
      object.startedAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'completedAt';
    yield object.completedAt == null ? null : serializers.serialize(
      object.completedAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'durationSeconds';
    yield object.durationSeconds == null ? null : serializers.serialize(
      object.durationSeconds,
      specifiedType: const FullType.nullable(int),
    );
    yield r'vehicle';
    yield object.vehicle == null ? null : serializers.serialize(
      object.vehicle,
      specifiedType: const FullType.nullable(TripsIdGet200ResponseVehicle),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TripsIdGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TripsIdGet200ResponseBuilder result,
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
        case r'routeId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.routeId = valueDes;
          break;
        case r'vehicleId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.vehicleId = valueDes;
          break;
        case r'assignedDriverId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.assignedDriverId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TripsIdGet200ResponseStatusEnum),
          ) as TripsIdGet200ResponseStatusEnum;
          result.status = valueDes;
          break;
        case r'scheduledAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.scheduledAt = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'startedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.startedAt = valueDes;
          break;
        case r'completedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.completedAt = valueDes;
          break;
        case r'durationSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.durationSeconds = valueDes;
          break;
        case r'vehicle':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(TripsIdGet200ResponseVehicle),
          ) as TripsIdGet200ResponseVehicle?;
          if (valueDes == null) continue;
          result.vehicle.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TripsIdGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TripsIdGet200ResponseBuilder();
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


class TripsIdGet200ResponseStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'scheduled')
  static const TripsIdGet200ResponseStatusEnum scheduled = _$tripsIdGet200ResponseStatusEnum_scheduled;
  @BuiltValueEnumConst(wireName: r'active')
  static const TripsIdGet200ResponseStatusEnum active = _$tripsIdGet200ResponseStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'completed')
  static const TripsIdGet200ResponseStatusEnum completed = _$tripsIdGet200ResponseStatusEnum_completed;
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const TripsIdGet200ResponseStatusEnum cancelled = _$tripsIdGet200ResponseStatusEnum_cancelled;

  static Serializer<TripsIdGet200ResponseStatusEnum> get serializer => _$tripsIdGet200ResponseStatusEnumSerializer;

  const TripsIdGet200ResponseStatusEnum._(String name): super(name);

  static BuiltSet<TripsIdGet200ResponseStatusEnum> get values => _$tripsIdGet200ResponseStatusEnumValues;
  static TripsIdGet200ResponseStatusEnum valueOf(String name) => _$tripsIdGet200ResponseStatusEnumValueOf(name);
}


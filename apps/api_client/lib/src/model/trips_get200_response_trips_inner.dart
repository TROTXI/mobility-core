//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'trips_get200_response_trips_inner.g.dart';

/// TripsGet200ResponseTripsInner
///
/// Properties:
/// * [id] 
/// * [routeId] 
/// * [vehicleId] 
/// * [assignedDriverId] 
/// * [status] 
/// * [scheduledAt] 
/// * [createdAt] 
@BuiltValue()
abstract class TripsGet200ResponseTripsInner implements Built<TripsGet200ResponseTripsInner, TripsGet200ResponseTripsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'routeId')
  String get routeId;

  @BuiltValueField(wireName: r'vehicleId')
  String? get vehicleId;

  @BuiltValueField(wireName: r'assignedDriverId')
  String? get assignedDriverId;

  @BuiltValueField(wireName: r'status')
  TripsGet200ResponseTripsInnerStatusEnum get status;
  // enum statusEnum {  scheduled,  active,  completed,  cancelled,  };

  @BuiltValueField(wireName: r'scheduledAt')
  DateTime get scheduledAt;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  TripsGet200ResponseTripsInner._();

  factory TripsGet200ResponseTripsInner([void updates(TripsGet200ResponseTripsInnerBuilder b)]) = _$TripsGet200ResponseTripsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TripsGet200ResponseTripsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TripsGet200ResponseTripsInner> get serializer => _$TripsGet200ResponseTripsInnerSerializer();
}

class _$TripsGet200ResponseTripsInnerSerializer implements PrimitiveSerializer<TripsGet200ResponseTripsInner> {
  @override
  final Iterable<Type> types = const [TripsGet200ResponseTripsInner, _$TripsGet200ResponseTripsInner];

  @override
  final String wireName = r'TripsGet200ResponseTripsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TripsGet200ResponseTripsInner object, {
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
      specifiedType: const FullType(TripsGet200ResponseTripsInnerStatusEnum),
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
  }

  @override
  Object serialize(
    Serializers serializers,
    TripsGet200ResponseTripsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TripsGet200ResponseTripsInnerBuilder result,
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
            specifiedType: const FullType(TripsGet200ResponseTripsInnerStatusEnum),
          ) as TripsGet200ResponseTripsInnerStatusEnum;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TripsGet200ResponseTripsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TripsGet200ResponseTripsInnerBuilder();
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

class TripsGet200ResponseTripsInnerStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'scheduled')
  static const TripsGet200ResponseTripsInnerStatusEnum scheduled = _$tripsGet200ResponseTripsInnerStatusEnum_scheduled;
  @BuiltValueEnumConst(wireName: r'active')
  static const TripsGet200ResponseTripsInnerStatusEnum active = _$tripsGet200ResponseTripsInnerStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'completed')
  static const TripsGet200ResponseTripsInnerStatusEnum completed = _$tripsGet200ResponseTripsInnerStatusEnum_completed;
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const TripsGet200ResponseTripsInnerStatusEnum cancelled = _$tripsGet200ResponseTripsInnerStatusEnum_cancelled;

  static Serializer<TripsGet200ResponseTripsInnerStatusEnum> get serializer => _$tripsGet200ResponseTripsInnerStatusEnumSerializer;

  const TripsGet200ResponseTripsInnerStatusEnum._(String name): super(name);

  static BuiltSet<TripsGet200ResponseTripsInnerStatusEnum> get values => _$tripsGet200ResponseTripsInnerStatusEnumValues;
  static TripsGet200ResponseTripsInnerStatusEnum valueOf(String name) => _$tripsGet200ResponseTripsInnerStatusEnumValueOf(name);
}


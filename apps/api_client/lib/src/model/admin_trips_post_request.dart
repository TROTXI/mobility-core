//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_trips_post_request.g.dart';

/// AdminTripsPostRequest
///
/// Properties:
/// * [routeId] 
/// * [vehicleId] 
/// * [assignedDriverId] 
/// * [status] 
/// * [scheduledAt] 
@BuiltValue()
abstract class AdminTripsPostRequest implements Built<AdminTripsPostRequest, AdminTripsPostRequestBuilder> {
  @BuiltValueField(wireName: r'routeId')
  String get routeId;

  @BuiltValueField(wireName: r'vehicleId')
  String? get vehicleId;

  @BuiltValueField(wireName: r'assignedDriverId')
  String? get assignedDriverId;

  @BuiltValueField(wireName: r'status')
  AdminTripsPostRequestStatusEnum? get status;
  // enum statusEnum {  scheduled,  active,  completed,  cancelled,  };

  @BuiltValueField(wireName: r'scheduledAt')
  DateTime get scheduledAt;

  AdminTripsPostRequest._();

  factory AdminTripsPostRequest([void updates(AdminTripsPostRequestBuilder b)]) = _$AdminTripsPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminTripsPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminTripsPostRequest> get serializer => _$AdminTripsPostRequestSerializer();
}

class _$AdminTripsPostRequestSerializer implements PrimitiveSerializer<AdminTripsPostRequest> {
  @override
  final Iterable<Type> types = const [AdminTripsPostRequest, _$AdminTripsPostRequest];

  @override
  final String wireName = r'AdminTripsPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminTripsPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'routeId';
    yield serializers.serialize(
      object.routeId,
      specifiedType: const FullType(String),
    );
    if (object.vehicleId != null) {
      yield r'vehicleId';
      yield serializers.serialize(
        object.vehicleId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.assignedDriverId != null) {
      yield r'assignedDriverId';
      yield serializers.serialize(
        object.assignedDriverId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(AdminTripsPostRequestStatusEnum),
      );
    }
    yield r'scheduledAt';
    yield serializers.serialize(
      object.scheduledAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminTripsPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminTripsPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
            specifiedType: const FullType(AdminTripsPostRequestStatusEnum),
          ) as AdminTripsPostRequestStatusEnum;
          result.status = valueDes;
          break;
        case r'scheduledAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.scheduledAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminTripsPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminTripsPostRequestBuilder();
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

class AdminTripsPostRequestStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'scheduled')
  static const AdminTripsPostRequestStatusEnum scheduled = _$adminTripsPostRequestStatusEnum_scheduled;
  @BuiltValueEnumConst(wireName: r'active')
  static const AdminTripsPostRequestStatusEnum active = _$adminTripsPostRequestStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'completed')
  static const AdminTripsPostRequestStatusEnum completed = _$adminTripsPostRequestStatusEnum_completed;
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const AdminTripsPostRequestStatusEnum cancelled = _$adminTripsPostRequestStatusEnum_cancelled;

  static Serializer<AdminTripsPostRequestStatusEnum> get serializer => _$adminTripsPostRequestStatusEnumSerializer;

  const AdminTripsPostRequestStatusEnum._(String name): super(name);

  static BuiltSet<AdminTripsPostRequestStatusEnum> get values => _$adminTripsPostRequestStatusEnumValues;
  static AdminTripsPostRequestStatusEnum valueOf(String name) => _$adminTripsPostRequestStatusEnumValueOf(name);
}


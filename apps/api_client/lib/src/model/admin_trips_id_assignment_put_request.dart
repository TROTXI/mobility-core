//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_trips_id_assignment_put_request.g.dart';

/// AdminTripsIdAssignmentPutRequest
///
/// Properties:
/// * [vehicleId] 
/// * [assignedDriverId] 
@BuiltValue()
abstract class AdminTripsIdAssignmentPutRequest implements Built<AdminTripsIdAssignmentPutRequest, AdminTripsIdAssignmentPutRequestBuilder> {
  @BuiltValueField(wireName: r'vehicleId')
  String? get vehicleId;

  @BuiltValueField(wireName: r'assignedDriverId')
  String? get assignedDriverId;

  AdminTripsIdAssignmentPutRequest._();

  factory AdminTripsIdAssignmentPutRequest([void updates(AdminTripsIdAssignmentPutRequestBuilder b)]) = _$AdminTripsIdAssignmentPutRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminTripsIdAssignmentPutRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminTripsIdAssignmentPutRequest> get serializer => _$AdminTripsIdAssignmentPutRequestSerializer();
}

class _$AdminTripsIdAssignmentPutRequestSerializer implements PrimitiveSerializer<AdminTripsIdAssignmentPutRequest> {
  @override
  final Iterable<Type> types = const [AdminTripsIdAssignmentPutRequest, _$AdminTripsIdAssignmentPutRequest];

  @override
  final String wireName = r'AdminTripsIdAssignmentPutRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminTripsIdAssignmentPutRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminTripsIdAssignmentPutRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminTripsIdAssignmentPutRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminTripsIdAssignmentPutRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminTripsIdAssignmentPutRequestBuilder();
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


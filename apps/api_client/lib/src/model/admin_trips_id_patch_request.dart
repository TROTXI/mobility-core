//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_trips_id_patch_request.g.dart';

/// AdminTripsIdPatchRequest
///
/// Properties:
/// * [status] 
/// * [scheduledAt] 
@BuiltValue()
abstract class AdminTripsIdPatchRequest implements Built<AdminTripsIdPatchRequest, AdminTripsIdPatchRequestBuilder> {
  @BuiltValueField(wireName: r'status')
  AdminTripsIdPatchRequestStatusEnum? get status;
  // enum statusEnum {  scheduled,  active,  completed,  cancelled,  };

  @BuiltValueField(wireName: r'scheduledAt')
  DateTime? get scheduledAt;

  AdminTripsIdPatchRequest._();

  factory AdminTripsIdPatchRequest([void updates(AdminTripsIdPatchRequestBuilder b)]) = _$AdminTripsIdPatchRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminTripsIdPatchRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminTripsIdPatchRequest> get serializer => _$AdminTripsIdPatchRequestSerializer();
}

class _$AdminTripsIdPatchRequestSerializer implements PrimitiveSerializer<AdminTripsIdPatchRequest> {
  @override
  final Iterable<Type> types = const [AdminTripsIdPatchRequest, _$AdminTripsIdPatchRequest];

  @override
  final String wireName = r'AdminTripsIdPatchRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminTripsIdPatchRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(AdminTripsIdPatchRequestStatusEnum),
      );
    }
    if (object.scheduledAt != null) {
      yield r'scheduledAt';
      yield serializers.serialize(
        object.scheduledAt,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminTripsIdPatchRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminTripsIdPatchRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminTripsIdPatchRequestStatusEnum),
          ) as AdminTripsIdPatchRequestStatusEnum;
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
  AdminTripsIdPatchRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminTripsIdPatchRequestBuilder();
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

class AdminTripsIdPatchRequestStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'scheduled')
  static const AdminTripsIdPatchRequestStatusEnum scheduled = _$adminTripsIdPatchRequestStatusEnum_scheduled;
  @BuiltValueEnumConst(wireName: r'active')
  static const AdminTripsIdPatchRequestStatusEnum active = _$adminTripsIdPatchRequestStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'completed')
  static const AdminTripsIdPatchRequestStatusEnum completed = _$adminTripsIdPatchRequestStatusEnum_completed;
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const AdminTripsIdPatchRequestStatusEnum cancelled = _$adminTripsIdPatchRequestStatusEnum_cancelled;

  static Serializer<AdminTripsIdPatchRequestStatusEnum> get serializer => _$adminTripsIdPatchRequestStatusEnumSerializer;

  const AdminTripsIdPatchRequestStatusEnum._(String name): super(name);

  static BuiltSet<AdminTripsIdPatchRequestStatusEnum> get values => _$adminTripsIdPatchRequestStatusEnumValues;
  static AdminTripsIdPatchRequestStatusEnum valueOf(String name) => _$adminTripsIdPatchRequestStatusEnumValueOf(name);
}


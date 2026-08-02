//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_vehicles_id_patch_request.g.dart';

/// AdminVehiclesIdPatchRequest
///
/// Properties:
/// * [registration] 
/// * [label] 
/// * [capacity] 
@BuiltValue()
abstract class AdminVehiclesIdPatchRequest implements Built<AdminVehiclesIdPatchRequest, AdminVehiclesIdPatchRequestBuilder> {
  @BuiltValueField(wireName: r'registration')
  String? get registration;

  @BuiltValueField(wireName: r'label')
  String? get label;

  @BuiltValueField(wireName: r'capacity')
  int? get capacity;

  AdminVehiclesIdPatchRequest._();

  factory AdminVehiclesIdPatchRequest([void updates(AdminVehiclesIdPatchRequestBuilder b)]) = _$AdminVehiclesIdPatchRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminVehiclesIdPatchRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminVehiclesIdPatchRequest> get serializer => _$AdminVehiclesIdPatchRequestSerializer();
}

class _$AdminVehiclesIdPatchRequestSerializer implements PrimitiveSerializer<AdminVehiclesIdPatchRequest> {
  @override
  final Iterable<Type> types = const [AdminVehiclesIdPatchRequest, _$AdminVehiclesIdPatchRequest];

  @override
  final String wireName = r'AdminVehiclesIdPatchRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminVehiclesIdPatchRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.registration != null) {
      yield r'registration';
      yield serializers.serialize(
        object.registration,
        specifiedType: const FullType(String),
      );
    }
    if (object.label != null) {
      yield r'label';
      yield serializers.serialize(
        object.label,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.capacity != null) {
      yield r'capacity';
      yield serializers.serialize(
        object.capacity,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminVehiclesIdPatchRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminVehiclesIdPatchRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'registration':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.registration = valueDes;
          break;
        case r'label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.label = valueDes;
          break;
        case r'capacity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.capacity = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminVehiclesIdPatchRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminVehiclesIdPatchRequestBuilder();
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


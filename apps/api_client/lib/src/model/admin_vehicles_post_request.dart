//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_vehicles_post_request.g.dart';

/// AdminVehiclesPostRequest
///
/// Properties:
/// * [registration] 
/// * [label] 
/// * [capacity] 
@BuiltValue()
abstract class AdminVehiclesPostRequest implements Built<AdminVehiclesPostRequest, AdminVehiclesPostRequestBuilder> {
  @BuiltValueField(wireName: r'registration')
  String get registration;

  @BuiltValueField(wireName: r'label')
  String? get label;

  @BuiltValueField(wireName: r'capacity')
  int? get capacity;

  AdminVehiclesPostRequest._();

  factory AdminVehiclesPostRequest([void updates(AdminVehiclesPostRequestBuilder b)]) = _$AdminVehiclesPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminVehiclesPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminVehiclesPostRequest> get serializer => _$AdminVehiclesPostRequestSerializer();
}

class _$AdminVehiclesPostRequestSerializer implements PrimitiveSerializer<AdminVehiclesPostRequest> {
  @override
  final Iterable<Type> types = const [AdminVehiclesPostRequest, _$AdminVehiclesPostRequest];

  @override
  final String wireName = r'AdminVehiclesPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminVehiclesPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'registration';
    yield serializers.serialize(
      object.registration,
      specifiedType: const FullType(String),
    );
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
    AdminVehiclesPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminVehiclesPostRequestBuilder result,
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
  AdminVehiclesPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminVehiclesPostRequestBuilder();
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


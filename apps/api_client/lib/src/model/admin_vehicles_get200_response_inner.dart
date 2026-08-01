//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_vehicles_get200_response_inner.g.dart';

/// AdminVehiclesGet200ResponseInner
///
/// Properties:
/// * [id] 
/// * [registration] 
/// * [label] 
/// * [capacity] 
/// * [createdAt] 
@BuiltValue()
abstract class AdminVehiclesGet200ResponseInner implements Built<AdminVehiclesGet200ResponseInner, AdminVehiclesGet200ResponseInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'registration')
  String get registration;

  @BuiltValueField(wireName: r'label')
  String? get label;

  @BuiltValueField(wireName: r'capacity')
  int get capacity;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  AdminVehiclesGet200ResponseInner._();

  factory AdminVehiclesGet200ResponseInner([void updates(AdminVehiclesGet200ResponseInnerBuilder b)]) = _$AdminVehiclesGet200ResponseInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminVehiclesGet200ResponseInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminVehiclesGet200ResponseInner> get serializer => _$AdminVehiclesGet200ResponseInnerSerializer();
}

class _$AdminVehiclesGet200ResponseInnerSerializer implements PrimitiveSerializer<AdminVehiclesGet200ResponseInner> {
  @override
  final Iterable<Type> types = const [AdminVehiclesGet200ResponseInner, _$AdminVehiclesGet200ResponseInner];

  @override
  final String wireName = r'AdminVehiclesGet200ResponseInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminVehiclesGet200ResponseInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'registration';
    yield serializers.serialize(
      object.registration,
      specifiedType: const FullType(String),
    );
    yield r'label';
    yield object.label == null ? null : serializers.serialize(
      object.label,
      specifiedType: const FullType.nullable(String),
    );
    yield r'capacity';
    yield serializers.serialize(
      object.capacity,
      specifiedType: const FullType(int),
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
    AdminVehiclesGet200ResponseInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminVehiclesGet200ResponseInnerBuilder result,
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
  AdminVehiclesGet200ResponseInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminVehiclesGet200ResponseInnerBuilder();
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


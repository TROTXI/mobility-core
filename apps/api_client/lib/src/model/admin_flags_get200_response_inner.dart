//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_flags_get200_response_inner.g.dart';

/// AdminFlagsGet200ResponseInner
///
/// Properties:
/// * [key] 
/// * [enabled] 
/// * [rolloutPercentage] 
/// * [description] 
/// * [updatedAt] 
@BuiltValue()
abstract class AdminFlagsGet200ResponseInner implements Built<AdminFlagsGet200ResponseInner, AdminFlagsGet200ResponseInnerBuilder> {
  @BuiltValueField(wireName: r'key')
  String get key;

  @BuiltValueField(wireName: r'enabled')
  bool get enabled;

  @BuiltValueField(wireName: r'rolloutPercentage')
  int get rolloutPercentage;

  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  AdminFlagsGet200ResponseInner._();

  factory AdminFlagsGet200ResponseInner([void updates(AdminFlagsGet200ResponseInnerBuilder b)]) = _$AdminFlagsGet200ResponseInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminFlagsGet200ResponseInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminFlagsGet200ResponseInner> get serializer => _$AdminFlagsGet200ResponseInnerSerializer();
}

class _$AdminFlagsGet200ResponseInnerSerializer implements PrimitiveSerializer<AdminFlagsGet200ResponseInner> {
  @override
  final Iterable<Type> types = const [AdminFlagsGet200ResponseInner, _$AdminFlagsGet200ResponseInner];

  @override
  final String wireName = r'AdminFlagsGet200ResponseInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminFlagsGet200ResponseInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'key';
    yield serializers.serialize(
      object.key,
      specifiedType: const FullType(String),
    );
    yield r'enabled';
    yield serializers.serialize(
      object.enabled,
      specifiedType: const FullType(bool),
    );
    yield r'rolloutPercentage';
    yield serializers.serialize(
      object.rolloutPercentage,
      specifiedType: const FullType(int),
    );
    yield r'description';
    yield object.description == null ? null : serializers.serialize(
      object.description,
      specifiedType: const FullType.nullable(String),
    );
    yield r'updatedAt';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminFlagsGet200ResponseInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminFlagsGet200ResponseInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.key = valueDes;
          break;
        case r'enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.enabled = valueDes;
          break;
        case r'rolloutPercentage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.rolloutPercentage = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.description = valueDes;
          break;
        case r'updatedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminFlagsGet200ResponseInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminFlagsGet200ResponseInnerBuilder();
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


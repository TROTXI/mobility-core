//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'route_edit.g.dart';

/// RouteEdit
///
/// Properties:
/// * [name] 
/// * [description] 
/// * [acceptsDriverRequests] 
/// * [archived] 
@BuiltValue()
abstract class RouteEdit implements Built<RouteEdit, RouteEditBuilder> {
  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'acceptsDriverRequests')
  bool? get acceptsDriverRequests;

  @BuiltValueField(wireName: r'archived')
  bool? get archived;

  RouteEdit._();

  factory RouteEdit([void updates(RouteEditBuilder b)]) = _$RouteEdit;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RouteEditBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RouteEdit> get serializer => _$RouteEditSerializer();
}

class _$RouteEditSerializer implements PrimitiveSerializer<RouteEdit> {
  @override
  final Iterable<Type> types = const [RouteEdit, _$RouteEdit];

  @override
  final String wireName = r'RouteEdit';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RouteEdit object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.acceptsDriverRequests != null) {
      yield r'acceptsDriverRequests';
      yield serializers.serialize(
        object.acceptsDriverRequests,
        specifiedType: const FullType(bool),
      );
    }
    if (object.archived != null) {
      yield r'archived';
      yield serializers.serialize(
        object.archived,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    RouteEdit object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RouteEditBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.description = valueDes;
          break;
        case r'acceptsDriverRequests':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.acceptsDriverRequests = valueDes;
          break;
        case r'archived':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.archived = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RouteEdit deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RouteEditBuilder();
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


//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'me_work_routes_get200_response_routes_inner.g.dart';

/// MeWorkRoutesGet200ResponseRoutesInner
///
/// Properties:
/// * [id] 
/// * [name] 
/// * [description] 
@BuiltValue()
abstract class MeWorkRoutesGet200ResponseRoutesInner implements Built<MeWorkRoutesGet200ResponseRoutesInner, MeWorkRoutesGet200ResponseRoutesInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'description')
  String? get description;

  MeWorkRoutesGet200ResponseRoutesInner._();

  factory MeWorkRoutesGet200ResponseRoutesInner([void updates(MeWorkRoutesGet200ResponseRoutesInnerBuilder b)]) = _$MeWorkRoutesGet200ResponseRoutesInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MeWorkRoutesGet200ResponseRoutesInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MeWorkRoutesGet200ResponseRoutesInner> get serializer => _$MeWorkRoutesGet200ResponseRoutesInnerSerializer();
}

class _$MeWorkRoutesGet200ResponseRoutesInnerSerializer implements PrimitiveSerializer<MeWorkRoutesGet200ResponseRoutesInner> {
  @override
  final Iterable<Type> types = const [MeWorkRoutesGet200ResponseRoutesInner, _$MeWorkRoutesGet200ResponseRoutesInner];

  @override
  final String wireName = r'MeWorkRoutesGet200ResponseRoutesInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MeWorkRoutesGet200ResponseRoutesInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'description';
    yield object.description == null ? null : serializers.serialize(
      object.description,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MeWorkRoutesGet200ResponseRoutesInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MeWorkRoutesGet200ResponseRoutesInnerBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MeWorkRoutesGet200ResponseRoutesInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MeWorkRoutesGet200ResponseRoutesInnerBuilder();
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


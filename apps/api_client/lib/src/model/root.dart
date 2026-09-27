//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'root.g.dart';

/// Root
///
/// Properties:
/// * [docs] 
/// * [health] 
@BuiltValue()
abstract class Root implements Built<Root, RootBuilder> {
  @BuiltValueField(wireName: r'docs')
  String get docs;

  @BuiltValueField(wireName: r'health')
  String get health;

  Root._();

  factory Root([void updates(RootBuilder b)]) = _$Root;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RootBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Root> get serializer => _$RootSerializer();
}

class _$RootSerializer implements PrimitiveSerializer<Root> {
  @override
  final Iterable<Type> types = const [Root, _$Root];

  @override
  final String wireName = r'Root';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Root object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'docs';
    yield serializers.serialize(
      object.docs,
      specifiedType: const FullType(String),
    );
    yield r'health';
    yield serializers.serialize(
      object.health,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Root object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RootBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'docs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.docs = valueDes;
          break;
        case r'health':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.health = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Root deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RootBuilder();
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


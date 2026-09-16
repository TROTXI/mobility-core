//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'build.g.dart';

/// Build
///
/// Properties:
/// * [service] 
/// * [version] 
/// * [commit] 
@BuiltValue()
abstract class Build implements Built<Build, BuildBuilder> {
  @BuiltValueField(wireName: r'service')
  String get service;

  @BuiltValueField(wireName: r'version')
  String get version;

  @BuiltValueField(wireName: r'commit')
  String get commit;

  Build._();

  factory Build([void updates(BuildBuilder b)]) = _$Build;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BuildBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Build> get serializer => _$BuildSerializer();
}

class _$BuildSerializer implements PrimitiveSerializer<Build> {
  @override
  final Iterable<Type> types = const [Build, _$Build];

  @override
  final String wireName = r'Build';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Build object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'service';
    yield serializers.serialize(
      object.service,
      specifiedType: const FullType(String),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(String),
    );
    yield r'commit';
    yield serializers.serialize(
      object.commit,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Build object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BuildBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'service':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.service = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.version = valueDes;
          break;
        case r'commit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.commit = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Build deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BuildBuilder();
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


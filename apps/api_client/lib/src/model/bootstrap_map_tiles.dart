//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bootstrap_map_tiles.g.dart';

/// BootstrapMapTiles
///
/// Properties:
<<<<<<< HEAD
/// * [url] 
/// * [styleUrl] 
/// * [darkStyleUrl] 
/// * [attribution] 
@BuiltValue()
abstract class BootstrapMapTiles implements Built<BootstrapMapTiles, BootstrapMapTilesBuilder> {
=======
/// * [url]
/// * [styleUrl]
/// * [darkStyleUrl]
/// * [attribution]
@BuiltValue()
abstract class BootstrapMapTiles
    implements Built<BootstrapMapTiles, BootstrapMapTilesBuilder> {
>>>>>>> origin/main
  @BuiltValueField(wireName: r'url')
  String? get url;

  @BuiltValueField(wireName: r'styleUrl')
  String? get styleUrl;

  @BuiltValueField(wireName: r'darkStyleUrl')
  String? get darkStyleUrl;

  @BuiltValueField(wireName: r'attribution')
  String get attribution;

  BootstrapMapTiles._();

<<<<<<< HEAD
  factory BootstrapMapTiles([void updates(BootstrapMapTilesBuilder b)]) = _$BootstrapMapTiles;
=======
  factory BootstrapMapTiles([void updates(BootstrapMapTilesBuilder b)]) =
      _$BootstrapMapTiles;
>>>>>>> origin/main

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BootstrapMapTilesBuilder b) => b;

  @BuiltValueSerializer(custom: true)
<<<<<<< HEAD
  static Serializer<BootstrapMapTiles> get serializer => _$BootstrapMapTilesSerializer();
}

class _$BootstrapMapTilesSerializer implements PrimitiveSerializer<BootstrapMapTiles> {
=======
  static Serializer<BootstrapMapTiles> get serializer =>
      _$BootstrapMapTilesSerializer();
}

class _$BootstrapMapTilesSerializer
    implements PrimitiveSerializer<BootstrapMapTiles> {
>>>>>>> origin/main
  @override
  final Iterable<Type> types = const [BootstrapMapTiles, _$BootstrapMapTiles];

  @override
  final String wireName = r'BootstrapMapTiles';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BootstrapMapTiles object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'url';
<<<<<<< HEAD
    yield object.url == null ? null : serializers.serialize(
      object.url,
      specifiedType: const FullType.nullable(String),
    );
    yield r'styleUrl';
    yield object.styleUrl == null ? null : serializers.serialize(
      object.styleUrl,
      specifiedType: const FullType.nullable(String),
    );
    yield r'darkStyleUrl';
    yield object.darkStyleUrl == null ? null : serializers.serialize(
      object.darkStyleUrl,
      specifiedType: const FullType.nullable(String),
    );
=======
    yield object.url == null
        ? null
        : serializers.serialize(
            object.url,
            specifiedType: const FullType.nullable(String),
          );
    yield r'styleUrl';
    yield object.styleUrl == null
        ? null
        : serializers.serialize(
            object.styleUrl,
            specifiedType: const FullType.nullable(String),
          );
    yield r'darkStyleUrl';
    yield object.darkStyleUrl == null
        ? null
        : serializers.serialize(
            object.darkStyleUrl,
            specifiedType: const FullType.nullable(String),
          );
>>>>>>> origin/main
    yield r'attribution';
    yield serializers.serialize(
      object.attribution,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BootstrapMapTiles object, {
    FullType specifiedType = FullType.unspecified,
  }) {
<<<<<<< HEAD
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
=======
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
>>>>>>> origin/main
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BootstrapMapTilesBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.url = valueDes;
          break;
        case r'styleUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.styleUrl = valueDes;
          break;
        case r'darkStyleUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.darkStyleUrl = valueDes;
          break;
        case r'attribution':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.attribution = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BootstrapMapTiles deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BootstrapMapTilesBuilder();
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
<<<<<<< HEAD

=======
>>>>>>> origin/main

//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'flags_get200_response_map_tiles.g.dart';

/// FlagsGet200ResponseMapTiles
///
/// Properties:
/// * [url] 
/// * [styleUrl] 
/// * [darkStyleUrl] 
/// * [attribution] 
@BuiltValue()
abstract class FlagsGet200ResponseMapTiles implements Built<FlagsGet200ResponseMapTiles, FlagsGet200ResponseMapTilesBuilder> {
  @BuiltValueField(wireName: r'url')
  String? get url;

  @BuiltValueField(wireName: r'styleUrl')
  String? get styleUrl;

  @BuiltValueField(wireName: r'darkStyleUrl')
  String? get darkStyleUrl;

  @BuiltValueField(wireName: r'attribution')
  String get attribution;

  FlagsGet200ResponseMapTiles._();

  factory FlagsGet200ResponseMapTiles([void updates(FlagsGet200ResponseMapTilesBuilder b)]) = _$FlagsGet200ResponseMapTiles;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FlagsGet200ResponseMapTilesBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FlagsGet200ResponseMapTiles> get serializer => _$FlagsGet200ResponseMapTilesSerializer();
}

class _$FlagsGet200ResponseMapTilesSerializer implements PrimitiveSerializer<FlagsGet200ResponseMapTiles> {
  @override
  final Iterable<Type> types = const [FlagsGet200ResponseMapTiles, _$FlagsGet200ResponseMapTiles];

  @override
  final String wireName = r'FlagsGet200ResponseMapTiles';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FlagsGet200ResponseMapTiles object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'url';
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
    yield r'attribution';
    yield serializers.serialize(
      object.attribution,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FlagsGet200ResponseMapTiles object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FlagsGet200ResponseMapTilesBuilder result,
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
  FlagsGet200ResponseMapTiles deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FlagsGet200ResponseMapTilesBuilder();
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


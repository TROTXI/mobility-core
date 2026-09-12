//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'flags_get200_response_min_supported_version.g.dart';

/// FlagsGet200ResponseMinSupportedVersion
///
/// Properties:
/// * [ios] 
/// * [android] 
@BuiltValue()
abstract class FlagsGet200ResponseMinSupportedVersion implements Built<FlagsGet200ResponseMinSupportedVersion, FlagsGet200ResponseMinSupportedVersionBuilder> {
  @BuiltValueField(wireName: r'ios')
  String? get ios;

  @BuiltValueField(wireName: r'android')
  String? get android;

  FlagsGet200ResponseMinSupportedVersion._();

  factory FlagsGet200ResponseMinSupportedVersion([void updates(FlagsGet200ResponseMinSupportedVersionBuilder b)]) = _$FlagsGet200ResponseMinSupportedVersion;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FlagsGet200ResponseMinSupportedVersionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FlagsGet200ResponseMinSupportedVersion> get serializer => _$FlagsGet200ResponseMinSupportedVersionSerializer();
}

class _$FlagsGet200ResponseMinSupportedVersionSerializer implements PrimitiveSerializer<FlagsGet200ResponseMinSupportedVersion> {
  @override
  final Iterable<Type> types = const [FlagsGet200ResponseMinSupportedVersion, _$FlagsGet200ResponseMinSupportedVersion];

  @override
  final String wireName = r'FlagsGet200ResponseMinSupportedVersion';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FlagsGet200ResponseMinSupportedVersion object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ios';
    yield object.ios == null ? null : serializers.serialize(
      object.ios,
      specifiedType: const FullType.nullable(String),
    );
    yield r'android';
    yield object.android == null ? null : serializers.serialize(
      object.android,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FlagsGet200ResponseMinSupportedVersion object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FlagsGet200ResponseMinSupportedVersionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ios':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.ios = valueDes;
          break;
        case r'android':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.android = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FlagsGet200ResponseMinSupportedVersion deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FlagsGet200ResponseMinSupportedVersionBuilder();
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


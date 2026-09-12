//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'flags_get200_response_flags_inner.g.dart';

/// FlagsGet200ResponseFlagsInner
///
/// Properties:
/// * [key] 
/// * [enabled] 
/// * [rolloutPercentage] 
@BuiltValue()
abstract class FlagsGet200ResponseFlagsInner implements Built<FlagsGet200ResponseFlagsInner, FlagsGet200ResponseFlagsInnerBuilder> {
  @BuiltValueField(wireName: r'key')
  String get key;

  @BuiltValueField(wireName: r'enabled')
  bool get enabled;

  @BuiltValueField(wireName: r'rolloutPercentage')
  int get rolloutPercentage;

  FlagsGet200ResponseFlagsInner._();

  factory FlagsGet200ResponseFlagsInner([void updates(FlagsGet200ResponseFlagsInnerBuilder b)]) = _$FlagsGet200ResponseFlagsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FlagsGet200ResponseFlagsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FlagsGet200ResponseFlagsInner> get serializer => _$FlagsGet200ResponseFlagsInnerSerializer();
}

class _$FlagsGet200ResponseFlagsInnerSerializer implements PrimitiveSerializer<FlagsGet200ResponseFlagsInner> {
  @override
  final Iterable<Type> types = const [FlagsGet200ResponseFlagsInner, _$FlagsGet200ResponseFlagsInner];

  @override
  final String wireName = r'FlagsGet200ResponseFlagsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FlagsGet200ResponseFlagsInner object, {
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
  }

  @override
  Object serialize(
    Serializers serializers,
    FlagsGet200ResponseFlagsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FlagsGet200ResponseFlagsInnerBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FlagsGet200ResponseFlagsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FlagsGet200ResponseFlagsInnerBuilder();
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


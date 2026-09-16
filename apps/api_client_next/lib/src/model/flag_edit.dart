//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'flag_edit.g.dart';

/// FlagEdit
///
/// Properties:
/// * [enabled] 
/// * [rolloutPercentage] 
/// * [description] 
@BuiltValue()
abstract class FlagEdit implements Built<FlagEdit, FlagEditBuilder> {
  @BuiltValueField(wireName: r'enabled')
  bool get enabled;

  @BuiltValueField(wireName: r'rolloutPercentage')
  num get rolloutPercentage;

  @BuiltValueField(wireName: r'description')
  String get description;

  FlagEdit._();

  factory FlagEdit([void updates(FlagEditBuilder b)]) = _$FlagEdit;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FlagEditBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FlagEdit> get serializer => _$FlagEditSerializer();
}

class _$FlagEditSerializer implements PrimitiveSerializer<FlagEdit> {
  @override
  final Iterable<Type> types = const [FlagEdit, _$FlagEdit];

  @override
  final String wireName = r'FlagEdit';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FlagEdit object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'enabled';
    yield serializers.serialize(
      object.enabled,
      specifiedType: const FullType(bool),
    );
    yield r'rolloutPercentage';
    yield serializers.serialize(
      object.rolloutPercentage,
      specifiedType: const FullType(num),
    );
    yield r'description';
    yield serializers.serialize(
      object.description,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FlagEdit object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FlagEditBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
            specifiedType: const FullType(num),
          ) as num;
          result.rolloutPercentage = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
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
  FlagEdit deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FlagEditBuilder();
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


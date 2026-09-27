//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bootstrap_flags_inner.g.dart';

/// BootstrapFlagsInner
///
/// Properties:
<<<<<<< HEAD
/// * [key] 
/// * [enabled] 
/// * [rolloutPercentage] 
@BuiltValue()
abstract class BootstrapFlagsInner implements Built<BootstrapFlagsInner, BootstrapFlagsInnerBuilder> {
=======
/// * [key]
/// * [enabled]
/// * [rolloutPercentage]
@BuiltValue()
abstract class BootstrapFlagsInner
    implements Built<BootstrapFlagsInner, BootstrapFlagsInnerBuilder> {
>>>>>>> origin/main
  @BuiltValueField(wireName: r'key')
  String get key;

  @BuiltValueField(wireName: r'enabled')
  bool get enabled;

  @BuiltValueField(wireName: r'rolloutPercentage')
  num get rolloutPercentage;

  BootstrapFlagsInner._();

<<<<<<< HEAD
  factory BootstrapFlagsInner([void updates(BootstrapFlagsInnerBuilder b)]) = _$BootstrapFlagsInner;
=======
  factory BootstrapFlagsInner([void updates(BootstrapFlagsInnerBuilder b)]) =
      _$BootstrapFlagsInner;
>>>>>>> origin/main

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BootstrapFlagsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
<<<<<<< HEAD
  static Serializer<BootstrapFlagsInner> get serializer => _$BootstrapFlagsInnerSerializer();
}

class _$BootstrapFlagsInnerSerializer implements PrimitiveSerializer<BootstrapFlagsInner> {
  @override
  final Iterable<Type> types = const [BootstrapFlagsInner, _$BootstrapFlagsInner];
=======
  static Serializer<BootstrapFlagsInner> get serializer =>
      _$BootstrapFlagsInnerSerializer();
}

class _$BootstrapFlagsInnerSerializer
    implements PrimitiveSerializer<BootstrapFlagsInner> {
  @override
  final Iterable<Type> types = const [
    BootstrapFlagsInner,
    _$BootstrapFlagsInner
  ];
>>>>>>> origin/main

  @override
  final String wireName = r'BootstrapFlagsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BootstrapFlagsInner object, {
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
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BootstrapFlagsInner object, {
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
    required BootstrapFlagsInnerBuilder result,
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
            specifiedType: const FullType(num),
          ) as num;
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
  BootstrapFlagsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BootstrapFlagsInnerBuilder();
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

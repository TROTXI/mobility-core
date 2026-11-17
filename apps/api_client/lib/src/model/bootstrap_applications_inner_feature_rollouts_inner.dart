//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bootstrap_applications_inner_feature_rollouts_inner.g.dart';

/// BootstrapApplicationsInnerFeatureRolloutsInner
///
/// Properties:
/// * [key]
/// * [minimumBuild]
@BuiltValue()
abstract class BootstrapApplicationsInnerFeatureRolloutsInner
    implements
        Built<BootstrapApplicationsInnerFeatureRolloutsInner,
            BootstrapApplicationsInnerFeatureRolloutsInnerBuilder> {
  @BuiltValueField(wireName: r'key')
  String get key;

  @BuiltValueField(wireName: r'minimumBuild')
  int get minimumBuild;

  BootstrapApplicationsInnerFeatureRolloutsInner._();

  factory BootstrapApplicationsInnerFeatureRolloutsInner(
          [void updates(
              BootstrapApplicationsInnerFeatureRolloutsInnerBuilder b)]) =
      _$BootstrapApplicationsInnerFeatureRolloutsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          BootstrapApplicationsInnerFeatureRolloutsInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BootstrapApplicationsInnerFeatureRolloutsInner>
      get serializer =>
          _$BootstrapApplicationsInnerFeatureRolloutsInnerSerializer();
}

class _$BootstrapApplicationsInnerFeatureRolloutsInnerSerializer
    implements
        PrimitiveSerializer<BootstrapApplicationsInnerFeatureRolloutsInner> {
  @override
  final Iterable<Type> types = const [
    BootstrapApplicationsInnerFeatureRolloutsInner,
    _$BootstrapApplicationsInnerFeatureRolloutsInner
  ];

  @override
  final String wireName = r'BootstrapApplicationsInnerFeatureRolloutsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BootstrapApplicationsInnerFeatureRolloutsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'key';
    yield serializers.serialize(
      object.key,
      specifiedType: const FullType(String),
    );
    yield r'minimumBuild';
    yield serializers.serialize(
      object.minimumBuild,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BootstrapApplicationsInnerFeatureRolloutsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BootstrapApplicationsInnerFeatureRolloutsInnerBuilder result,
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
        case r'minimumBuild':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.minimumBuild = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BootstrapApplicationsInnerFeatureRolloutsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BootstrapApplicationsInnerFeatureRolloutsInnerBuilder();
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

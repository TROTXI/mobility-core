//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auto_renewal_input.g.dart';

/// AutoRenewalInput
///
/// Properties:
/// * [enabled]
@BuiltValue()
abstract class AutoRenewalInput
    implements Built<AutoRenewalInput, AutoRenewalInputBuilder> {
  @BuiltValueField(wireName: r'enabled')
  bool get enabled;

  AutoRenewalInput._();

  factory AutoRenewalInput([void updates(AutoRenewalInputBuilder b)]) =
      _$AutoRenewalInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AutoRenewalInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AutoRenewalInput> get serializer =>
      _$AutoRenewalInputSerializer();
}

class _$AutoRenewalInputSerializer
    implements PrimitiveSerializer<AutoRenewalInput> {
  @override
  final Iterable<Type> types = const [AutoRenewalInput, _$AutoRenewalInput];

  @override
  final String wireName = r'AutoRenewalInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AutoRenewalInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'enabled';
    yield serializers.serialize(
      object.enabled,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AutoRenewalInput object, {
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
    required AutoRenewalInputBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AutoRenewalInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AutoRenewalInputBuilder();
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

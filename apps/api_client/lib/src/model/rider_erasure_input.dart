//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'rider_erasure_input.g.dart';

/// RiderErasureInput
///
/// Properties:
/// * [reason]
/// * [confirmAccountId]
@BuiltValue()
abstract class RiderErasureInput
    implements Built<RiderErasureInput, RiderErasureInputBuilder> {
  @BuiltValueField(wireName: r'reason')
  String get reason;

  @BuiltValueField(wireName: r'confirmAccountId')
  String get confirmAccountId;

  RiderErasureInput._();

  factory RiderErasureInput([void updates(RiderErasureInputBuilder b)]) =
      _$RiderErasureInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RiderErasureInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RiderErasureInput> get serializer =>
      _$RiderErasureInputSerializer();
}

class _$RiderErasureInputSerializer
    implements PrimitiveSerializer<RiderErasureInput> {
  @override
  final Iterable<Type> types = const [RiderErasureInput, _$RiderErasureInput];

  @override
  final String wireName = r'RiderErasureInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RiderErasureInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
    yield r'confirmAccountId';
    yield serializers.serialize(
      object.confirmAccountId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RiderErasureInput object, {
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
    required RiderErasureInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reason = valueDes;
          break;
        case r'confirmAccountId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.confirmAccountId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RiderErasureInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RiderErasureInputBuilder();
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

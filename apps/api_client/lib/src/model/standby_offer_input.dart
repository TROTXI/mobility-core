//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'standby_offer_input.g.dart';

/// StandbyOfferInput
///
/// Properties:
/// * [expiresAt]
@BuiltValue()
abstract class StandbyOfferInput
    implements Built<StandbyOfferInput, StandbyOfferInputBuilder> {
  @BuiltValueField(wireName: r'expiresAt')
  DateTime get expiresAt;

  StandbyOfferInput._();

  factory StandbyOfferInput([void updates(StandbyOfferInputBuilder b)]) =
      _$StandbyOfferInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StandbyOfferInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StandbyOfferInput> get serializer =>
      _$StandbyOfferInputSerializer();
}

class _$StandbyOfferInputSerializer
    implements PrimitiveSerializer<StandbyOfferInput> {
  @override
  final Iterable<Type> types = const [StandbyOfferInput, _$StandbyOfferInput];

  @override
  final String wireName = r'StandbyOfferInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StandbyOfferInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'expiresAt';
    yield serializers.serialize(
      object.expiresAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    StandbyOfferInput object, {
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
    required StandbyOfferInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'expiresAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.expiresAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  StandbyOfferInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StandbyOfferInputBuilder();
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

//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'restriction_input.g.dart';

/// RestrictionInput
///
/// Properties:
/// * [reason] 
/// * [reviewAt] 
@BuiltValue()
abstract class RestrictionInput implements Built<RestrictionInput, RestrictionInputBuilder> {
  @BuiltValueField(wireName: r'reason')
  String get reason;

  @BuiltValueField(wireName: r'reviewAt')
  DateTime get reviewAt;

  RestrictionInput._();

  factory RestrictionInput([void updates(RestrictionInputBuilder b)]) = _$RestrictionInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RestrictionInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RestrictionInput> get serializer => _$RestrictionInputSerializer();
}

class _$RestrictionInputSerializer implements PrimitiveSerializer<RestrictionInput> {
  @override
  final Iterable<Type> types = const [RestrictionInput, _$RestrictionInput];

  @override
  final String wireName = r'RestrictionInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RestrictionInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
    yield r'reviewAt';
    yield serializers.serialize(
      object.reviewAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RestrictionInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RestrictionInputBuilder result,
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
        case r'reviewAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.reviewAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RestrictionInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RestrictionInputBuilder();
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


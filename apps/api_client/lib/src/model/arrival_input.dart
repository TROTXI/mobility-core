//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'arrival_input.g.dart';

/// ArrivalInput
///
/// Properties:
/// * [stopOccurrenceId] 
/// * [correction] 
@BuiltValue()
abstract class ArrivalInput implements Built<ArrivalInput, ArrivalInputBuilder> {
  @BuiltValueField(wireName: r'stopOccurrenceId')
  String get stopOccurrenceId;

  @BuiltValueField(wireName: r'correction')
  bool get correction;

  ArrivalInput._();

  factory ArrivalInput([void updates(ArrivalInputBuilder b)]) = _$ArrivalInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ArrivalInputBuilder b) => b
      ..correction = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<ArrivalInput> get serializer => _$ArrivalInputSerializer();
}

class _$ArrivalInputSerializer implements PrimitiveSerializer<ArrivalInput> {
  @override
  final Iterable<Type> types = const [ArrivalInput, _$ArrivalInput];

  @override
  final String wireName = r'ArrivalInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ArrivalInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'stopOccurrenceId';
    yield serializers.serialize(
      object.stopOccurrenceId,
      specifiedType: const FullType(String),
    );
    yield r'correction';
    yield serializers.serialize(
      object.correction,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ArrivalInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ArrivalInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'stopOccurrenceId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.stopOccurrenceId = valueDes;
          break;
        case r'correction':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.correction = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ArrivalInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ArrivalInputBuilder();
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


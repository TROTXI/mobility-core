//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'publish_version_input.g.dart';

/// PublishVersionInput
///
/// Properties:
/// * [reason] 
/// * [effectiveFrom] 
@BuiltValue()
abstract class PublishVersionInput implements Built<PublishVersionInput, PublishVersionInputBuilder> {
  @BuiltValueField(wireName: r'reason')
  String get reason;

  @BuiltValueField(wireName: r'effectiveFrom')
  DateTime get effectiveFrom;

  PublishVersionInput._();

  factory PublishVersionInput([void updates(PublishVersionInputBuilder b)]) = _$PublishVersionInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PublishVersionInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PublishVersionInput> get serializer => _$PublishVersionInputSerializer();
}

class _$PublishVersionInputSerializer implements PrimitiveSerializer<PublishVersionInput> {
  @override
  final Iterable<Type> types = const [PublishVersionInput, _$PublishVersionInput];

  @override
  final String wireName = r'PublishVersionInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PublishVersionInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
    yield r'effectiveFrom';
    yield serializers.serialize(
      object.effectiveFrom,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PublishVersionInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PublishVersionInputBuilder result,
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
        case r'effectiveFrom':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.effectiveFrom = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PublishVersionInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PublishVersionInputBuilder();
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


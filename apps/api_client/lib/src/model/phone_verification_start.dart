//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'phone_verification_start.g.dart';

/// PhoneVerificationStart
///
/// Properties:
/// * [phone]
@BuiltValue()
abstract class PhoneVerificationStart
    implements Built<PhoneVerificationStart, PhoneVerificationStartBuilder> {
  @BuiltValueField(wireName: r'phone')
  String get phone;

  PhoneVerificationStart._();

  factory PhoneVerificationStart(
          [void updates(PhoneVerificationStartBuilder b)]) =
      _$PhoneVerificationStart;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PhoneVerificationStartBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PhoneVerificationStart> get serializer =>
      _$PhoneVerificationStartSerializer();
}

class _$PhoneVerificationStartSerializer
    implements PrimitiveSerializer<PhoneVerificationStart> {
  @override
  final Iterable<Type> types = const [
    PhoneVerificationStart,
    _$PhoneVerificationStart
  ];

  @override
  final String wireName = r'PhoneVerificationStart';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PhoneVerificationStart object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'phone';
    yield serializers.serialize(
      object.phone,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PhoneVerificationStart object, {
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
    required PhoneVerificationStartBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.phone = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PhoneVerificationStart deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PhoneVerificationStartBuilder();
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

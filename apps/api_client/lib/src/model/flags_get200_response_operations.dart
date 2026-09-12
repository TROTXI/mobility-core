//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'flags_get200_response_operations.g.dart';

/// FlagsGet200ResponseOperations
///
/// Properties:
/// * [phone] 
/// * [whatsapp] 
/// * [email] 
/// * [hours] 
@BuiltValue()
abstract class FlagsGet200ResponseOperations implements Built<FlagsGet200ResponseOperations, FlagsGet200ResponseOperationsBuilder> {
  @BuiltValueField(wireName: r'phone')
  String? get phone;

  @BuiltValueField(wireName: r'whatsapp')
  String? get whatsapp;

  @BuiltValueField(wireName: r'email')
  String? get email;

  @BuiltValueField(wireName: r'hours')
  String? get hours;

  FlagsGet200ResponseOperations._();

  factory FlagsGet200ResponseOperations([void updates(FlagsGet200ResponseOperationsBuilder b)]) = _$FlagsGet200ResponseOperations;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FlagsGet200ResponseOperationsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FlagsGet200ResponseOperations> get serializer => _$FlagsGet200ResponseOperationsSerializer();
}

class _$FlagsGet200ResponseOperationsSerializer implements PrimitiveSerializer<FlagsGet200ResponseOperations> {
  @override
  final Iterable<Type> types = const [FlagsGet200ResponseOperations, _$FlagsGet200ResponseOperations];

  @override
  final String wireName = r'FlagsGet200ResponseOperations';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FlagsGet200ResponseOperations object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'phone';
    yield object.phone == null ? null : serializers.serialize(
      object.phone,
      specifiedType: const FullType.nullable(String),
    );
    yield r'whatsapp';
    yield object.whatsapp == null ? null : serializers.serialize(
      object.whatsapp,
      specifiedType: const FullType.nullable(String),
    );
    yield r'email';
    yield object.email == null ? null : serializers.serialize(
      object.email,
      specifiedType: const FullType.nullable(String),
    );
    yield r'hours';
    yield object.hours == null ? null : serializers.serialize(
      object.hours,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FlagsGet200ResponseOperations object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FlagsGet200ResponseOperationsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.phone = valueDes;
          break;
        case r'whatsapp':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.whatsapp = valueDes;
          break;
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.email = valueDes;
          break;
        case r'hours':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.hours = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FlagsGet200ResponseOperations deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FlagsGet200ResponseOperationsBuilder();
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


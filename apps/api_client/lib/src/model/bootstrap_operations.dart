//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bootstrap_operations.g.dart';

/// BootstrapOperations
///
/// Properties:
<<<<<<< HEAD
/// * [phone] 
/// * [whatsapp] 
/// * [email] 
/// * [hours] 
@BuiltValue()
abstract class BootstrapOperations implements Built<BootstrapOperations, BootstrapOperationsBuilder> {
=======
/// * [phone]
/// * [whatsapp]
/// * [email]
/// * [hours]
@BuiltValue()
abstract class BootstrapOperations
    implements Built<BootstrapOperations, BootstrapOperationsBuilder> {
>>>>>>> origin/main
  @BuiltValueField(wireName: r'phone')
  String? get phone;

  @BuiltValueField(wireName: r'whatsapp')
  String? get whatsapp;

  @BuiltValueField(wireName: r'email')
  String? get email;

  @BuiltValueField(wireName: r'hours')
  String? get hours;

  BootstrapOperations._();

<<<<<<< HEAD
  factory BootstrapOperations([void updates(BootstrapOperationsBuilder b)]) = _$BootstrapOperations;
=======
  factory BootstrapOperations([void updates(BootstrapOperationsBuilder b)]) =
      _$BootstrapOperations;
>>>>>>> origin/main

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BootstrapOperationsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
<<<<<<< HEAD
  static Serializer<BootstrapOperations> get serializer => _$BootstrapOperationsSerializer();
}

class _$BootstrapOperationsSerializer implements PrimitiveSerializer<BootstrapOperations> {
  @override
  final Iterable<Type> types = const [BootstrapOperations, _$BootstrapOperations];
=======
  static Serializer<BootstrapOperations> get serializer =>
      _$BootstrapOperationsSerializer();
}

class _$BootstrapOperationsSerializer
    implements PrimitiveSerializer<BootstrapOperations> {
  @override
  final Iterable<Type> types = const [
    BootstrapOperations,
    _$BootstrapOperations
  ];
>>>>>>> origin/main

  @override
  final String wireName = r'BootstrapOperations';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BootstrapOperations object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'phone';
<<<<<<< HEAD
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
=======
    yield object.phone == null
        ? null
        : serializers.serialize(
            object.phone,
            specifiedType: const FullType.nullable(String),
          );
    yield r'whatsapp';
    yield object.whatsapp == null
        ? null
        : serializers.serialize(
            object.whatsapp,
            specifiedType: const FullType.nullable(String),
          );
    yield r'email';
    yield object.email == null
        ? null
        : serializers.serialize(
            object.email,
            specifiedType: const FullType.nullable(String),
          );
    yield r'hours';
    yield object.hours == null
        ? null
        : serializers.serialize(
            object.hours,
            specifiedType: const FullType.nullable(String),
          );
>>>>>>> origin/main
  }

  @override
  Object serialize(
    Serializers serializers,
    BootstrapOperations object, {
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
    required BootstrapOperationsBuilder result,
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
  BootstrapOperations deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BootstrapOperationsBuilder();
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

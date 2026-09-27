//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'passkey_registration_options_rp.g.dart';

/// PasskeyRegistrationOptionsRp
///
/// Properties:
/// * [id]
/// * [name]
@BuiltValue()
abstract class PasskeyRegistrationOptionsRp
    implements
        Built<PasskeyRegistrationOptionsRp,
            PasskeyRegistrationOptionsRpBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  PasskeyRegistrationOptionsRp._();

  factory PasskeyRegistrationOptionsRp(
          [void updates(PasskeyRegistrationOptionsRpBuilder b)]) =
      _$PasskeyRegistrationOptionsRp;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PasskeyRegistrationOptionsRpBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PasskeyRegistrationOptionsRp> get serializer =>
      _$PasskeyRegistrationOptionsRpSerializer();
}

class _$PasskeyRegistrationOptionsRpSerializer
    implements PrimitiveSerializer<PasskeyRegistrationOptionsRp> {
  @override
  final Iterable<Type> types = const [
    PasskeyRegistrationOptionsRp,
    _$PasskeyRegistrationOptionsRp
  ];

  @override
  final String wireName = r'PasskeyRegistrationOptionsRp';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PasskeyRegistrationOptionsRp object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PasskeyRegistrationOptionsRp object, {
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
    required PasskeyRegistrationOptionsRpBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PasskeyRegistrationOptionsRp deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PasskeyRegistrationOptionsRpBuilder();
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

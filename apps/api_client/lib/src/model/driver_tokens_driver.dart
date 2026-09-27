//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'driver_tokens_driver.g.dart';

/// DriverTokensDriver
///
/// Properties:
<<<<<<< HEAD
/// * [id] 
/// * [name] 
@BuiltValue()
abstract class DriverTokensDriver implements Built<DriverTokensDriver, DriverTokensDriverBuilder> {
=======
/// * [id]
/// * [name]
@BuiltValue()
abstract class DriverTokensDriver
    implements Built<DriverTokensDriver, DriverTokensDriverBuilder> {
>>>>>>> origin/main
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  DriverTokensDriver._();

<<<<<<< HEAD
  factory DriverTokensDriver([void updates(DriverTokensDriverBuilder b)]) = _$DriverTokensDriver;
=======
  factory DriverTokensDriver([void updates(DriverTokensDriverBuilder b)]) =
      _$DriverTokensDriver;
>>>>>>> origin/main

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DriverTokensDriverBuilder b) => b;

  @BuiltValueSerializer(custom: true)
<<<<<<< HEAD
  static Serializer<DriverTokensDriver> get serializer => _$DriverTokensDriverSerializer();
}

class _$DriverTokensDriverSerializer implements PrimitiveSerializer<DriverTokensDriver> {
=======
  static Serializer<DriverTokensDriver> get serializer =>
      _$DriverTokensDriverSerializer();
}

class _$DriverTokensDriverSerializer
    implements PrimitiveSerializer<DriverTokensDriver> {
>>>>>>> origin/main
  @override
  final Iterable<Type> types = const [DriverTokensDriver, _$DriverTokensDriver];

  @override
  final String wireName = r'DriverTokensDriver';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DriverTokensDriver object, {
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
    DriverTokensDriver object, {
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
    required DriverTokensDriverBuilder result,
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
  DriverTokensDriver deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DriverTokensDriverBuilder();
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

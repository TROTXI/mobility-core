//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'driver_sign_in.g.dart';

/// DriverSignIn
///
/// Properties:
/// * [code] 
/// * [pin] 
/// * [ownDevice] 
@BuiltValue()
abstract class DriverSignIn implements Built<DriverSignIn, DriverSignInBuilder> {
  @BuiltValueField(wireName: r'code')
  String get code;

  @BuiltValueField(wireName: r'pin')
  String get pin;

  @BuiltValueField(wireName: r'ownDevice')
  bool get ownDevice;

  DriverSignIn._();

  factory DriverSignIn([void updates(DriverSignInBuilder b)]) = _$DriverSignIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DriverSignInBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DriverSignIn> get serializer => _$DriverSignInSerializer();
}

class _$DriverSignInSerializer implements PrimitiveSerializer<DriverSignIn> {
  @override
  final Iterable<Type> types = const [DriverSignIn, _$DriverSignIn];

  @override
  final String wireName = r'DriverSignIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DriverSignIn object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    yield r'pin';
    yield serializers.serialize(
      object.pin,
      specifiedType: const FullType(String),
    );
    yield r'ownDevice';
    yield serializers.serialize(
      object.ownDevice,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DriverSignIn object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DriverSignInBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        case r'pin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.pin = valueDes;
          break;
        case r'ownDevice':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.ownDevice = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DriverSignIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DriverSignInBuilder();
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


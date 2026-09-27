//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/driver_self_credential.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'driver_self.g.dart';

/// DriverSelf
///
/// Properties:
/// * [id] 
/// * [name] 
/// * [phone] 
/// * [licenseNumber] 
/// * [credential] 
@BuiltValue()
abstract class DriverSelf implements Built<DriverSelf, DriverSelfBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'phone')
  String? get phone;

  @BuiltValueField(wireName: r'licenseNumber')
  String? get licenseNumber;

  @BuiltValueField(wireName: r'credential')
  DriverSelfCredential? get credential;

  DriverSelf._();

  factory DriverSelf([void updates(DriverSelfBuilder b)]) = _$DriverSelf;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DriverSelfBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DriverSelf> get serializer => _$DriverSelfSerializer();
}

class _$DriverSelfSerializer implements PrimitiveSerializer<DriverSelf> {
  @override
  final Iterable<Type> types = const [DriverSelf, _$DriverSelf];

  @override
  final String wireName = r'DriverSelf';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DriverSelf object, {
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
    yield r'phone';
    yield object.phone == null ? null : serializers.serialize(
      object.phone,
      specifiedType: const FullType.nullable(String),
    );
    yield r'licenseNumber';
    yield object.licenseNumber == null ? null : serializers.serialize(
      object.licenseNumber,
      specifiedType: const FullType.nullable(String),
    );
    yield r'credential';
    yield object.credential == null ? null : serializers.serialize(
      object.credential,
      specifiedType: const FullType.nullable(DriverSelfCredential),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DriverSelf object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DriverSelfBuilder result,
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
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.phone = valueDes;
          break;
        case r'licenseNumber':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.licenseNumber = valueDes;
          break;
        case r'credential':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DriverSelfCredential),
          ) as DriverSelfCredential?;
          if (valueDes == null) continue;
          result.credential.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DriverSelf deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DriverSelfBuilder();
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


//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'passkey_registration_options_pub_key_cred_params_inner.g.dart';

/// PasskeyRegistrationOptionsPubKeyCredParamsInner
///
/// Properties:
/// * [type]
/// * [alg]
@BuiltValue()
abstract class PasskeyRegistrationOptionsPubKeyCredParamsInner
    implements
        Built<PasskeyRegistrationOptionsPubKeyCredParamsInner,
            PasskeyRegistrationOptionsPubKeyCredParamsInnerBuilder> {
  @BuiltValueField(wireName: r'type')
  PasskeyRegistrationOptionsPubKeyCredParamsInnerTypeEnum get type;
  // enum typeEnum {  public-key,  };

  @BuiltValueField(wireName: r'alg')
  int get alg;

  PasskeyRegistrationOptionsPubKeyCredParamsInner._();

  factory PasskeyRegistrationOptionsPubKeyCredParamsInner(
          [void updates(
              PasskeyRegistrationOptionsPubKeyCredParamsInnerBuilder b)]) =
      _$PasskeyRegistrationOptionsPubKeyCredParamsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PasskeyRegistrationOptionsPubKeyCredParamsInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PasskeyRegistrationOptionsPubKeyCredParamsInner>
      get serializer =>
          _$PasskeyRegistrationOptionsPubKeyCredParamsInnerSerializer();
}

class _$PasskeyRegistrationOptionsPubKeyCredParamsInnerSerializer
    implements
        PrimitiveSerializer<PasskeyRegistrationOptionsPubKeyCredParamsInner> {
  @override
  final Iterable<Type> types = const [
    PasskeyRegistrationOptionsPubKeyCredParamsInner,
    _$PasskeyRegistrationOptionsPubKeyCredParamsInner
  ];

  @override
  final String wireName = r'PasskeyRegistrationOptionsPubKeyCredParamsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PasskeyRegistrationOptionsPubKeyCredParamsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(
          PasskeyRegistrationOptionsPubKeyCredParamsInnerTypeEnum),
    );
    yield r'alg';
    yield serializers.serialize(
      object.alg,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PasskeyRegistrationOptionsPubKeyCredParamsInner object, {
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
    required PasskeyRegistrationOptionsPubKeyCredParamsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PasskeyRegistrationOptionsPubKeyCredParamsInnerTypeEnum),
          ) as PasskeyRegistrationOptionsPubKeyCredParamsInnerTypeEnum;
          result.type = valueDes;
          break;
        case r'alg':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.alg = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PasskeyRegistrationOptionsPubKeyCredParamsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PasskeyRegistrationOptionsPubKeyCredParamsInnerBuilder();
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

class PasskeyRegistrationOptionsPubKeyCredParamsInnerTypeEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'public-key')
  static const PasskeyRegistrationOptionsPubKeyCredParamsInnerTypeEnum
      publicKey =
      _$passkeyRegistrationOptionsPubKeyCredParamsInnerTypeEnum_publicKey;

  static Serializer<PasskeyRegistrationOptionsPubKeyCredParamsInnerTypeEnum>
      get serializer =>
          _$passkeyRegistrationOptionsPubKeyCredParamsInnerTypeEnumSerializer;

  const PasskeyRegistrationOptionsPubKeyCredParamsInnerTypeEnum._(String name)
      : super(name);

  static BuiltSet<PasskeyRegistrationOptionsPubKeyCredParamsInnerTypeEnum>
      get values =>
          _$passkeyRegistrationOptionsPubKeyCredParamsInnerTypeEnumValues;
  static PasskeyRegistrationOptionsPubKeyCredParamsInnerTypeEnum valueOf(
          String name) =>
      _$passkeyRegistrationOptionsPubKeyCredParamsInnerTypeEnumValueOf(name);
}

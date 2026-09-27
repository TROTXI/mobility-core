//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'passkey_authentication_options_allow_credentials_inner.g.dart';

/// PasskeyAuthenticationOptionsAllowCredentialsInner
///
/// Properties:
/// * [id]
/// * [type]
/// * [transports]
@BuiltValue()
abstract class PasskeyAuthenticationOptionsAllowCredentialsInner
    implements
        Built<PasskeyAuthenticationOptionsAllowCredentialsInner,
            PasskeyAuthenticationOptionsAllowCredentialsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'type')
  PasskeyAuthenticationOptionsAllowCredentialsInnerTypeEnum get type;
  // enum typeEnum {  public-key,  };

  @BuiltValueField(wireName: r'transports')
  BuiltList<String>? get transports;

  PasskeyAuthenticationOptionsAllowCredentialsInner._();

  factory PasskeyAuthenticationOptionsAllowCredentialsInner(
          [void updates(
              PasskeyAuthenticationOptionsAllowCredentialsInnerBuilder b)]) =
      _$PasskeyAuthenticationOptionsAllowCredentialsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PasskeyAuthenticationOptionsAllowCredentialsInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PasskeyAuthenticationOptionsAllowCredentialsInner>
      get serializer =>
          _$PasskeyAuthenticationOptionsAllowCredentialsInnerSerializer();
}

class _$PasskeyAuthenticationOptionsAllowCredentialsInnerSerializer
    implements
        PrimitiveSerializer<PasskeyAuthenticationOptionsAllowCredentialsInner> {
  @override
  final Iterable<Type> types = const [
    PasskeyAuthenticationOptionsAllowCredentialsInner,
    _$PasskeyAuthenticationOptionsAllowCredentialsInner
  ];

  @override
  final String wireName = r'PasskeyAuthenticationOptionsAllowCredentialsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PasskeyAuthenticationOptionsAllowCredentialsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(
          PasskeyAuthenticationOptionsAllowCredentialsInnerTypeEnum),
    );
    if (object.transports != null) {
      yield r'transports';
      yield serializers.serialize(
        object.transports,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PasskeyAuthenticationOptionsAllowCredentialsInner object, {
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
    required PasskeyAuthenticationOptionsAllowCredentialsInnerBuilder result,
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
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PasskeyAuthenticationOptionsAllowCredentialsInnerTypeEnum),
          ) as PasskeyAuthenticationOptionsAllowCredentialsInnerTypeEnum;
          result.type = valueDes;
          break;
        case r'transports':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.transports.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PasskeyAuthenticationOptionsAllowCredentialsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PasskeyAuthenticationOptionsAllowCredentialsInnerBuilder();
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

class PasskeyAuthenticationOptionsAllowCredentialsInnerTypeEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'public-key')
  static const PasskeyAuthenticationOptionsAllowCredentialsInnerTypeEnum
      publicKey =
      _$passkeyAuthenticationOptionsAllowCredentialsInnerTypeEnum_publicKey;

  static Serializer<PasskeyAuthenticationOptionsAllowCredentialsInnerTypeEnum>
      get serializer =>
          _$passkeyAuthenticationOptionsAllowCredentialsInnerTypeEnumSerializer;

  const PasskeyAuthenticationOptionsAllowCredentialsInnerTypeEnum._(String name)
      : super(name);

  static BuiltSet<PasskeyAuthenticationOptionsAllowCredentialsInnerTypeEnum>
      get values =>
          _$passkeyAuthenticationOptionsAllowCredentialsInnerTypeEnumValues;
  static PasskeyAuthenticationOptionsAllowCredentialsInnerTypeEnum valueOf(
          String name) =>
      _$passkeyAuthenticationOptionsAllowCredentialsInnerTypeEnumValueOf(name);
}

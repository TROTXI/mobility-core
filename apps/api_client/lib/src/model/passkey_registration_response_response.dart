//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'passkey_registration_response_response.g.dart';

/// PasskeyRegistrationResponseResponse
///
/// Properties:
/// * [clientDataJSON]
/// * [attestationObject]
/// * [authenticatorData]
/// * [transports]
/// * [publicKeyAlgorithm]
/// * [publicKey]
@BuiltValue()
abstract class PasskeyRegistrationResponseResponse
    implements
        Built<PasskeyRegistrationResponseResponse,
            PasskeyRegistrationResponseResponseBuilder> {
  @BuiltValueField(wireName: r'clientDataJSON')
  String get clientDataJSON;

  @BuiltValueField(wireName: r'attestationObject')
  String get attestationObject;

  @BuiltValueField(wireName: r'authenticatorData')
  String? get authenticatorData;

  @BuiltValueField(wireName: r'transports')
  BuiltList<String>? get transports;

  @BuiltValueField(wireName: r'publicKeyAlgorithm')
  int? get publicKeyAlgorithm;

  @BuiltValueField(wireName: r'publicKey')
  String? get publicKey;

  PasskeyRegistrationResponseResponse._();

  factory PasskeyRegistrationResponseResponse(
          [void updates(PasskeyRegistrationResponseResponseBuilder b)]) =
      _$PasskeyRegistrationResponseResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PasskeyRegistrationResponseResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PasskeyRegistrationResponseResponse> get serializer =>
      _$PasskeyRegistrationResponseResponseSerializer();
}

class _$PasskeyRegistrationResponseResponseSerializer
    implements PrimitiveSerializer<PasskeyRegistrationResponseResponse> {
  @override
  final Iterable<Type> types = const [
    PasskeyRegistrationResponseResponse,
    _$PasskeyRegistrationResponseResponse
  ];

  @override
  final String wireName = r'PasskeyRegistrationResponseResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PasskeyRegistrationResponseResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'clientDataJSON';
    yield serializers.serialize(
      object.clientDataJSON,
      specifiedType: const FullType(String),
    );
    yield r'attestationObject';
    yield serializers.serialize(
      object.attestationObject,
      specifiedType: const FullType(String),
    );
    if (object.authenticatorData != null) {
      yield r'authenticatorData';
      yield serializers.serialize(
        object.authenticatorData,
        specifiedType: const FullType(String),
      );
    }
    if (object.transports != null) {
      yield r'transports';
      yield serializers.serialize(
        object.transports,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.publicKeyAlgorithm != null) {
      yield r'publicKeyAlgorithm';
      yield serializers.serialize(
        object.publicKeyAlgorithm,
        specifiedType: const FullType(int),
      );
    }
    if (object.publicKey != null) {
      yield r'publicKey';
      yield serializers.serialize(
        object.publicKey,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PasskeyRegistrationResponseResponse object, {
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
    required PasskeyRegistrationResponseResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'clientDataJSON':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientDataJSON = valueDes;
          break;
        case r'attestationObject':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.attestationObject = valueDes;
          break;
        case r'authenticatorData':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.authenticatorData = valueDes;
          break;
        case r'transports':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.transports.replace(valueDes);
          break;
        case r'publicKeyAlgorithm':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.publicKeyAlgorithm = valueDes;
          break;
        case r'publicKey':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.publicKey = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PasskeyRegistrationResponseResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PasskeyRegistrationResponseResponseBuilder();
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

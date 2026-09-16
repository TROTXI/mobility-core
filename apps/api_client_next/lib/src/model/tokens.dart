//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/account.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'tokens.g.dart';

/// Tokens
///
/// Properties:
/// * [accessToken] 
/// * [refreshToken] 
/// * [accessExpiresAt] 
/// * [refreshExpiresAt] 
/// * [account] 
@BuiltValue()
abstract class Tokens implements Built<Tokens, TokensBuilder> {
  @BuiltValueField(wireName: r'accessToken')
  String get accessToken;

  @BuiltValueField(wireName: r'refreshToken')
  String get refreshToken;

  @BuiltValueField(wireName: r'accessExpiresAt')
  DateTime get accessExpiresAt;

  @BuiltValueField(wireName: r'refreshExpiresAt')
  DateTime get refreshExpiresAt;

  @BuiltValueField(wireName: r'account')
  Account get account;

  Tokens._();

  factory Tokens([void updates(TokensBuilder b)]) = _$Tokens;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TokensBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Tokens> get serializer => _$TokensSerializer();
}

class _$TokensSerializer implements PrimitiveSerializer<Tokens> {
  @override
  final Iterable<Type> types = const [Tokens, _$Tokens];

  @override
  final String wireName = r'Tokens';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Tokens object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'accessToken';
    yield serializers.serialize(
      object.accessToken,
      specifiedType: const FullType(String),
    );
    yield r'refreshToken';
    yield serializers.serialize(
      object.refreshToken,
      specifiedType: const FullType(String),
    );
    yield r'accessExpiresAt';
    yield serializers.serialize(
      object.accessExpiresAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'refreshExpiresAt';
    yield serializers.serialize(
      object.refreshExpiresAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'account';
    yield serializers.serialize(
      object.account,
      specifiedType: const FullType(Account),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Tokens object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TokensBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'accessToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.accessToken = valueDes;
          break;
        case r'refreshToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.refreshToken = valueDes;
          break;
        case r'accessExpiresAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.accessExpiresAt = valueDes;
          break;
        case r'refreshExpiresAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.refreshExpiresAt = valueDes;
          break;
        case r'account':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Account),
          ) as Account;
          result.account.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Tokens deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TokensBuilder();
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


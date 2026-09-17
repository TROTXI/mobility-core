//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/driver_tokens_driver.dart';
import 'package:trotxi_api_client/src/model/account.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'driver_tokens.g.dart';

/// DriverTokens
///
/// Properties:
/// * [accessToken] 
/// * [refreshToken] 
/// * [accessExpiresAt] 
/// * [refreshExpiresAt] 
/// * [account] 
/// * [driver] 
/// * [mustChangePin] 
@BuiltValue()
abstract class DriverTokens implements Built<DriverTokens, DriverTokensBuilder> {
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

  @BuiltValueField(wireName: r'driver')
  DriverTokensDriver get driver;

  @BuiltValueField(wireName: r'mustChangePin')
  bool get mustChangePin;

  DriverTokens._();

  factory DriverTokens([void updates(DriverTokensBuilder b)]) = _$DriverTokens;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DriverTokensBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DriverTokens> get serializer => _$DriverTokensSerializer();
}

class _$DriverTokensSerializer implements PrimitiveSerializer<DriverTokens> {
  @override
  final Iterable<Type> types = const [DriverTokens, _$DriverTokens];

  @override
  final String wireName = r'DriverTokens';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DriverTokens object, {
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
    yield r'driver';
    yield serializers.serialize(
      object.driver,
      specifiedType: const FullType(DriverTokensDriver),
    );
    yield r'mustChangePin';
    yield serializers.serialize(
      object.mustChangePin,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DriverTokens object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DriverTokensBuilder result,
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
        case r'driver':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DriverTokensDriver),
          ) as DriverTokensDriver;
          result.driver.replace(valueDes);
          break;
        case r'mustChangePin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.mustChangePin = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DriverTokens deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DriverTokensBuilder();
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


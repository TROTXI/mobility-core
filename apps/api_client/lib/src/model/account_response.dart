//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/account.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'account_response.g.dart';

/// AccountResponse
///
/// Properties:
<<<<<<< HEAD
/// * [data] 
@BuiltValue()
abstract class AccountResponse implements Built<AccountResponse, AccountResponseBuilder> {
=======
/// * [data]
@BuiltValue()
abstract class AccountResponse
    implements Built<AccountResponse, AccountResponseBuilder> {
>>>>>>> origin/main
  @BuiltValueField(wireName: r'data')
  Account get data;

  AccountResponse._();

<<<<<<< HEAD
  factory AccountResponse([void updates(AccountResponseBuilder b)]) = _$AccountResponse;
=======
  factory AccountResponse([void updates(AccountResponseBuilder b)]) =
      _$AccountResponse;
>>>>>>> origin/main

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AccountResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
<<<<<<< HEAD
  static Serializer<AccountResponse> get serializer => _$AccountResponseSerializer();
}

class _$AccountResponseSerializer implements PrimitiveSerializer<AccountResponse> {
=======
  static Serializer<AccountResponse> get serializer =>
      _$AccountResponseSerializer();
}

class _$AccountResponseSerializer
    implements PrimitiveSerializer<AccountResponse> {
>>>>>>> origin/main
  @override
  final Iterable<Type> types = const [AccountResponse, _$AccountResponse];

  @override
  final String wireName = r'AccountResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AccountResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(Account),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AccountResponse object, {
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
    required AccountResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Account),
          ) as Account;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AccountResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AccountResponseBuilder();
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

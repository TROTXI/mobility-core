//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_expire_subscriptions_post200_response.g.dart';

/// AdminExpireSubscriptionsPost200Response
///
/// Properties:
/// * [expired] 
/// * [considered] 
@BuiltValue()
abstract class AdminExpireSubscriptionsPost200Response implements Built<AdminExpireSubscriptionsPost200Response, AdminExpireSubscriptionsPost200ResponseBuilder> {
  @BuiltValueField(wireName: r'expired')
  int get expired;

  @BuiltValueField(wireName: r'considered')
  int get considered;

  AdminExpireSubscriptionsPost200Response._();

  factory AdminExpireSubscriptionsPost200Response([void updates(AdminExpireSubscriptionsPost200ResponseBuilder b)]) = _$AdminExpireSubscriptionsPost200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminExpireSubscriptionsPost200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminExpireSubscriptionsPost200Response> get serializer => _$AdminExpireSubscriptionsPost200ResponseSerializer();
}

class _$AdminExpireSubscriptionsPost200ResponseSerializer implements PrimitiveSerializer<AdminExpireSubscriptionsPost200Response> {
  @override
  final Iterable<Type> types = const [AdminExpireSubscriptionsPost200Response, _$AdminExpireSubscriptionsPost200Response];

  @override
  final String wireName = r'AdminExpireSubscriptionsPost200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminExpireSubscriptionsPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'expired';
    yield serializers.serialize(
      object.expired,
      specifiedType: const FullType(int),
    );
    yield r'considered';
    yield serializers.serialize(
      object.considered,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminExpireSubscriptionsPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminExpireSubscriptionsPost200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'expired':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.expired = valueDes;
          break;
        case r'considered':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.considered = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminExpireSubscriptionsPost200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminExpireSubscriptionsPost200ResponseBuilder();
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


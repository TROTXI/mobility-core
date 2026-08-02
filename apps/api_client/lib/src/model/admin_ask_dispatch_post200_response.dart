//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_ask_dispatch_post200_response.g.dart';

/// AdminAskDispatchPost200Response
///
/// Properties:
/// * [trips] 
/// * [asked] 
@BuiltValue()
abstract class AdminAskDispatchPost200Response implements Built<AdminAskDispatchPost200Response, AdminAskDispatchPost200ResponseBuilder> {
  @BuiltValueField(wireName: r'trips')
  int get trips;

  @BuiltValueField(wireName: r'asked')
  int get asked;

  AdminAskDispatchPost200Response._();

  factory AdminAskDispatchPost200Response([void updates(AdminAskDispatchPost200ResponseBuilder b)]) = _$AdminAskDispatchPost200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminAskDispatchPost200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminAskDispatchPost200Response> get serializer => _$AdminAskDispatchPost200ResponseSerializer();
}

class _$AdminAskDispatchPost200ResponseSerializer implements PrimitiveSerializer<AdminAskDispatchPost200Response> {
  @override
  final Iterable<Type> types = const [AdminAskDispatchPost200Response, _$AdminAskDispatchPost200Response];

  @override
  final String wireName = r'AdminAskDispatchPost200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminAskDispatchPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'trips';
    yield serializers.serialize(
      object.trips,
      specifiedType: const FullType(int),
    );
    yield r'asked';
    yield serializers.serialize(
      object.asked,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminAskDispatchPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminAskDispatchPost200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'trips':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.trips = valueDes;
          break;
        case r'asked':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.asked = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminAskDispatchPost200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminAskDispatchPost200ResponseBuilder();
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


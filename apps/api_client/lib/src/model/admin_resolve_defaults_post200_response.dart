//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_resolve_defaults_post200_response.g.dart';

/// AdminResolveDefaultsPost200Response
///
/// Properties:
/// * [defaulted] 
@BuiltValue()
abstract class AdminResolveDefaultsPost200Response implements Built<AdminResolveDefaultsPost200Response, AdminResolveDefaultsPost200ResponseBuilder> {
  @BuiltValueField(wireName: r'defaulted')
  int get defaulted;

  AdminResolveDefaultsPost200Response._();

  factory AdminResolveDefaultsPost200Response([void updates(AdminResolveDefaultsPost200ResponseBuilder b)]) = _$AdminResolveDefaultsPost200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminResolveDefaultsPost200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminResolveDefaultsPost200Response> get serializer => _$AdminResolveDefaultsPost200ResponseSerializer();
}

class _$AdminResolveDefaultsPost200ResponseSerializer implements PrimitiveSerializer<AdminResolveDefaultsPost200Response> {
  @override
  final Iterable<Type> types = const [AdminResolveDefaultsPost200Response, _$AdminResolveDefaultsPost200Response];

  @override
  final String wireName = r'AdminResolveDefaultsPost200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminResolveDefaultsPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'defaulted';
    yield serializers.serialize(
      object.defaulted,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminResolveDefaultsPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminResolveDefaultsPost200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'defaulted':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.defaulted = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminResolveDefaultsPost200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminResolveDefaultsPost200ResponseBuilder();
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


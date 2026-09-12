//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_resolve_no_shows_post200_response.g.dart';

/// AdminResolveNoShowsPost200Response
///
/// Properties:
/// * [noShows] 
@BuiltValue()
abstract class AdminResolveNoShowsPost200Response implements Built<AdminResolveNoShowsPost200Response, AdminResolveNoShowsPost200ResponseBuilder> {
  @BuiltValueField(wireName: r'noShows')
  int get noShows;

  AdminResolveNoShowsPost200Response._();

  factory AdminResolveNoShowsPost200Response([void updates(AdminResolveNoShowsPost200ResponseBuilder b)]) = _$AdminResolveNoShowsPost200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminResolveNoShowsPost200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminResolveNoShowsPost200Response> get serializer => _$AdminResolveNoShowsPost200ResponseSerializer();
}

class _$AdminResolveNoShowsPost200ResponseSerializer implements PrimitiveSerializer<AdminResolveNoShowsPost200Response> {
  @override
  final Iterable<Type> types = const [AdminResolveNoShowsPost200Response, _$AdminResolveNoShowsPost200Response];

  @override
  final String wireName = r'AdminResolveNoShowsPost200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminResolveNoShowsPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'noShows';
    yield serializers.serialize(
      object.noShows,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminResolveNoShowsPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminResolveNoShowsPost200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'noShows':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.noShows = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminResolveNoShowsPost200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminResolveNoShowsPost200ResponseBuilder();
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


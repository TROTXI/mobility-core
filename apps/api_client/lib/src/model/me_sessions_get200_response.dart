//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/me_sessions_get200_response_sessions_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'me_sessions_get200_response.g.dart';

/// MeSessionsGet200Response
///
/// Properties:
/// * [sessions] 
@BuiltValue()
abstract class MeSessionsGet200Response implements Built<MeSessionsGet200Response, MeSessionsGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'sessions')
  BuiltList<MeSessionsGet200ResponseSessionsInner> get sessions;

  MeSessionsGet200Response._();

  factory MeSessionsGet200Response([void updates(MeSessionsGet200ResponseBuilder b)]) = _$MeSessionsGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MeSessionsGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MeSessionsGet200Response> get serializer => _$MeSessionsGet200ResponseSerializer();
}

class _$MeSessionsGet200ResponseSerializer implements PrimitiveSerializer<MeSessionsGet200Response> {
  @override
  final Iterable<Type> types = const [MeSessionsGet200Response, _$MeSessionsGet200Response];

  @override
  final String wireName = r'MeSessionsGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MeSessionsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'sessions';
    yield serializers.serialize(
      object.sessions,
      specifiedType: const FullType(BuiltList, [FullType(MeSessionsGet200ResponseSessionsInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MeSessionsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MeSessionsGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'sessions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(MeSessionsGet200ResponseSessionsInner)]),
          ) as BuiltList<MeSessionsGet200ResponseSessionsInner>;
          result.sessions.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MeSessionsGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MeSessionsGet200ResponseBuilder();
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


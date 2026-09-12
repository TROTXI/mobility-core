//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/me_work_requests_get200_response_requests_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'me_work_requests_get200_response.g.dart';

/// MeWorkRequestsGet200Response
///
/// Properties:
/// * [requests] 
@BuiltValue()
abstract class MeWorkRequestsGet200Response implements Built<MeWorkRequestsGet200Response, MeWorkRequestsGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'requests')
  BuiltList<MeWorkRequestsGet200ResponseRequestsInner> get requests;

  MeWorkRequestsGet200Response._();

  factory MeWorkRequestsGet200Response([void updates(MeWorkRequestsGet200ResponseBuilder b)]) = _$MeWorkRequestsGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MeWorkRequestsGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MeWorkRequestsGet200Response> get serializer => _$MeWorkRequestsGet200ResponseSerializer();
}

class _$MeWorkRequestsGet200ResponseSerializer implements PrimitiveSerializer<MeWorkRequestsGet200Response> {
  @override
  final Iterable<Type> types = const [MeWorkRequestsGet200Response, _$MeWorkRequestsGet200Response];

  @override
  final String wireName = r'MeWorkRequestsGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MeWorkRequestsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'requests';
    yield serializers.serialize(
      object.requests,
      specifiedType: const FullType(BuiltList, [FullType(MeWorkRequestsGet200ResponseRequestsInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MeWorkRequestsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MeWorkRequestsGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'requests':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(MeWorkRequestsGet200ResponseRequestsInner)]),
          ) as BuiltList<MeWorkRequestsGet200ResponseRequestsInner>;
          result.requests.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MeWorkRequestsGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MeWorkRequestsGet200ResponseBuilder();
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


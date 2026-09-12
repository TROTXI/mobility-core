//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/me_incidents_get200_response_incidents_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'me_incidents_get200_response.g.dart';

/// MeIncidentsGet200Response
///
/// Properties:
/// * [incidents] 
@BuiltValue()
abstract class MeIncidentsGet200Response implements Built<MeIncidentsGet200Response, MeIncidentsGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'incidents')
  BuiltList<MeIncidentsGet200ResponseIncidentsInner> get incidents;

  MeIncidentsGet200Response._();

  factory MeIncidentsGet200Response([void updates(MeIncidentsGet200ResponseBuilder b)]) = _$MeIncidentsGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MeIncidentsGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MeIncidentsGet200Response> get serializer => _$MeIncidentsGet200ResponseSerializer();
}

class _$MeIncidentsGet200ResponseSerializer implements PrimitiveSerializer<MeIncidentsGet200Response> {
  @override
  final Iterable<Type> types = const [MeIncidentsGet200Response, _$MeIncidentsGet200Response];

  @override
  final String wireName = r'MeIncidentsGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MeIncidentsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'incidents';
    yield serializers.serialize(
      object.incidents,
      specifiedType: const FullType(BuiltList, [FullType(MeIncidentsGet200ResponseIncidentsInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MeIncidentsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MeIncidentsGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'incidents':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(MeIncidentsGet200ResponseIncidentsInner)]),
          ) as BuiltList<MeIncidentsGet200ResponseIncidentsInner>;
          result.incidents.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MeIncidentsGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MeIncidentsGet200ResponseBuilder();
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


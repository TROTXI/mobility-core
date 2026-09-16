//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/ops_incident.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_incident_response.g.dart';

/// OpsIncidentResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class OpsIncidentResponse implements Built<OpsIncidentResponse, OpsIncidentResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  OpsIncident get data;

  OpsIncidentResponse._();

  factory OpsIncidentResponse([void updates(OpsIncidentResponseBuilder b)]) = _$OpsIncidentResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsIncidentResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsIncidentResponse> get serializer => _$OpsIncidentResponseSerializer();
}

class _$OpsIncidentResponseSerializer implements PrimitiveSerializer<OpsIncidentResponse> {
  @override
  final Iterable<Type> types = const [OpsIncidentResponse, _$OpsIncidentResponse];

  @override
  final String wireName = r'OpsIncidentResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsIncidentResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(OpsIncident),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsIncidentResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OpsIncidentResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OpsIncident),
          ) as OpsIncident;
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
  OpsIncidentResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsIncidentResponseBuilder();
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


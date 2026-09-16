//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/incident.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'incident_response.g.dart';

/// IncidentResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class IncidentResponse implements Built<IncidentResponse, IncidentResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  Incident get data;

  IncidentResponse._();

  factory IncidentResponse([void updates(IncidentResponseBuilder b)]) = _$IncidentResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(IncidentResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<IncidentResponse> get serializer => _$IncidentResponseSerializer();
}

class _$IncidentResponseSerializer implements PrimitiveSerializer<IncidentResponse> {
  @override
  final Iterable<Type> types = const [IncidentResponse, _$IncidentResponse];

  @override
  final String wireName = r'IncidentResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    IncidentResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(Incident),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    IncidentResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required IncidentResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Incident),
          ) as Incident;
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
  IncidentResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = IncidentResponseBuilder();
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


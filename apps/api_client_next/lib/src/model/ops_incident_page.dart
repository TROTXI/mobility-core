//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/commute_request_page_page.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client_next/src/model/ops_incident.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_incident_page.g.dart';

/// OpsIncidentPage
///
/// Properties:
/// * [data] 
/// * [page] 
@BuiltValue()
abstract class OpsIncidentPage implements Built<OpsIncidentPage, OpsIncidentPageBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<OpsIncident> get data;

  @BuiltValueField(wireName: r'page')
  CommuteRequestPagePage get page;

  OpsIncidentPage._();

  factory OpsIncidentPage([void updates(OpsIncidentPageBuilder b)]) = _$OpsIncidentPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsIncidentPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsIncidentPage> get serializer => _$OpsIncidentPageSerializer();
}

class _$OpsIncidentPageSerializer implements PrimitiveSerializer<OpsIncidentPage> {
  @override
  final Iterable<Type> types = const [OpsIncidentPage, _$OpsIncidentPage];

  @override
  final String wireName = r'OpsIncidentPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsIncidentPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(OpsIncident)]),
    );
    yield r'page';
    yield serializers.serialize(
      object.page,
      specifiedType: const FullType(CommuteRequestPagePage),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsIncidentPage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OpsIncidentPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(OpsIncident)]),
          ) as BuiltList<OpsIncident>;
          result.data.replace(valueDes);
          break;
        case r'page':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CommuteRequestPagePage),
          ) as CommuteRequestPagePage;
          result.page.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OpsIncidentPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsIncidentPageBuilder();
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


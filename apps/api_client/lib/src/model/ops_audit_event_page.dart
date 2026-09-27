//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/commute_request_page_page.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/ops_audit_event.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_audit_event_page.g.dart';

/// OpsAuditEventPage
///
/// Properties:
/// * [data]
/// * [page]
@BuiltValue()
abstract class OpsAuditEventPage
    implements Built<OpsAuditEventPage, OpsAuditEventPageBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<OpsAuditEvent> get data;

  @BuiltValueField(wireName: r'page')
  CommuteRequestPagePage get page;

  OpsAuditEventPage._();

  factory OpsAuditEventPage([void updates(OpsAuditEventPageBuilder b)]) =
      _$OpsAuditEventPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsAuditEventPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsAuditEventPage> get serializer =>
      _$OpsAuditEventPageSerializer();
}

class _$OpsAuditEventPageSerializer
    implements PrimitiveSerializer<OpsAuditEventPage> {
  @override
  final Iterable<Type> types = const [OpsAuditEventPage, _$OpsAuditEventPage];

  @override
  final String wireName = r'OpsAuditEventPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsAuditEventPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(OpsAuditEvent)]),
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
    OpsAuditEventPage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OpsAuditEventPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(OpsAuditEvent)]),
          ) as BuiltList<OpsAuditEvent>;
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
  OpsAuditEventPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsAuditEventPageBuilder();
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

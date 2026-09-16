//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/commute_request_page_page.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client_next/src/model/ops_commute_request.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_commute_request_page.g.dart';

/// OpsCommuteRequestPage
///
/// Properties:
/// * [data] 
/// * [page] 
@BuiltValue()
abstract class OpsCommuteRequestPage implements Built<OpsCommuteRequestPage, OpsCommuteRequestPageBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<OpsCommuteRequest> get data;

  @BuiltValueField(wireName: r'page')
  CommuteRequestPagePage get page;

  OpsCommuteRequestPage._();

  factory OpsCommuteRequestPage([void updates(OpsCommuteRequestPageBuilder b)]) = _$OpsCommuteRequestPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsCommuteRequestPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsCommuteRequestPage> get serializer => _$OpsCommuteRequestPageSerializer();
}

class _$OpsCommuteRequestPageSerializer implements PrimitiveSerializer<OpsCommuteRequestPage> {
  @override
  final Iterable<Type> types = const [OpsCommuteRequestPage, _$OpsCommuteRequestPage];

  @override
  final String wireName = r'OpsCommuteRequestPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsCommuteRequestPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(OpsCommuteRequest)]),
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
    OpsCommuteRequestPage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OpsCommuteRequestPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(OpsCommuteRequest)]),
          ) as BuiltList<OpsCommuteRequest>;
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
  OpsCommuteRequestPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsCommuteRequestPageBuilder();
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


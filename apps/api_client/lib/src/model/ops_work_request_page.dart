//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/commute_request_page_page.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/ops_work_request.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_work_request_page.g.dart';

/// OpsWorkRequestPage
///
/// Properties:
/// * [data] 
/// * [page] 
@BuiltValue()
abstract class OpsWorkRequestPage implements Built<OpsWorkRequestPage, OpsWorkRequestPageBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<OpsWorkRequest> get data;

  @BuiltValueField(wireName: r'page')
  CommuteRequestPagePage get page;

  OpsWorkRequestPage._();

  factory OpsWorkRequestPage([void updates(OpsWorkRequestPageBuilder b)]) = _$OpsWorkRequestPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsWorkRequestPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsWorkRequestPage> get serializer => _$OpsWorkRequestPageSerializer();
}

class _$OpsWorkRequestPageSerializer implements PrimitiveSerializer<OpsWorkRequestPage> {
  @override
  final Iterable<Type> types = const [OpsWorkRequestPage, _$OpsWorkRequestPage];

  @override
  final String wireName = r'OpsWorkRequestPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsWorkRequestPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(OpsWorkRequest)]),
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
    OpsWorkRequestPage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OpsWorkRequestPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(OpsWorkRequest)]),
          ) as BuiltList<OpsWorkRequest>;
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
  OpsWorkRequestPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsWorkRequestPageBuilder();
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


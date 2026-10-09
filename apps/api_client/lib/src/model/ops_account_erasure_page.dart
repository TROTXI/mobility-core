//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/commute_request_page_page.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/ops_account_erasure.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_account_erasure_page.g.dart';

/// OpsAccountErasurePage
///
/// Properties:
/// * [data]
/// * [page]
@BuiltValue()
abstract class OpsAccountErasurePage
    implements Built<OpsAccountErasurePage, OpsAccountErasurePageBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<OpsAccountErasure> get data;

  @BuiltValueField(wireName: r'page')
  CommuteRequestPagePage get page;

  OpsAccountErasurePage._();

  factory OpsAccountErasurePage(
      [void updates(OpsAccountErasurePageBuilder b)]) = _$OpsAccountErasurePage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsAccountErasurePageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsAccountErasurePage> get serializer =>
      _$OpsAccountErasurePageSerializer();
}

class _$OpsAccountErasurePageSerializer
    implements PrimitiveSerializer<OpsAccountErasurePage> {
  @override
  final Iterable<Type> types = const [
    OpsAccountErasurePage,
    _$OpsAccountErasurePage
  ];

  @override
  final String wireName = r'OpsAccountErasurePage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsAccountErasurePage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(OpsAccountErasure)]),
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
    OpsAccountErasurePage object, {
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
    required OpsAccountErasurePageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(OpsAccountErasure)]),
          ) as BuiltList<OpsAccountErasure>;
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
  OpsAccountErasurePage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsAccountErasurePageBuilder();
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

//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/commute_request_page_page.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/ops_delivery.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_delivery_page.g.dart';

/// OpsDeliveryPage
///
/// Properties:
/// * [data]
/// * [page]
@BuiltValue()
abstract class OpsDeliveryPage
    implements Built<OpsDeliveryPage, OpsDeliveryPageBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<OpsDelivery> get data;

  @BuiltValueField(wireName: r'page')
  CommuteRequestPagePage get page;

  OpsDeliveryPage._();

  factory OpsDeliveryPage([void updates(OpsDeliveryPageBuilder b)]) =
      _$OpsDeliveryPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsDeliveryPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsDeliveryPage> get serializer =>
      _$OpsDeliveryPageSerializer();
}

class _$OpsDeliveryPageSerializer
    implements PrimitiveSerializer<OpsDeliveryPage> {
  @override
  final Iterable<Type> types = const [OpsDeliveryPage, _$OpsDeliveryPage];

  @override
  final String wireName = r'OpsDeliveryPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsDeliveryPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(OpsDelivery)]),
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
    OpsDeliveryPage object, {
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
    required OpsDeliveryPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(OpsDelivery)]),
          ) as BuiltList<OpsDelivery>;
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
  OpsDeliveryPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsDeliveryPageBuilder();
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

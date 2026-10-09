//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/commute_request_page_page.dart';
import 'package:trotxi_api_client/src/model/ops_auto_renewal.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_auto_renewal_page.g.dart';

/// OpsAutoRenewalPage
///
/// Properties:
/// * [data]
/// * [page]
@BuiltValue()
abstract class OpsAutoRenewalPage
    implements Built<OpsAutoRenewalPage, OpsAutoRenewalPageBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<OpsAutoRenewal> get data;

  @BuiltValueField(wireName: r'page')
  CommuteRequestPagePage get page;

  OpsAutoRenewalPage._();

  factory OpsAutoRenewalPage([void updates(OpsAutoRenewalPageBuilder b)]) =
      _$OpsAutoRenewalPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsAutoRenewalPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsAutoRenewalPage> get serializer =>
      _$OpsAutoRenewalPageSerializer();
}

class _$OpsAutoRenewalPageSerializer
    implements PrimitiveSerializer<OpsAutoRenewalPage> {
  @override
  final Iterable<Type> types = const [OpsAutoRenewalPage, _$OpsAutoRenewalPage];

  @override
  final String wireName = r'OpsAutoRenewalPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsAutoRenewalPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(OpsAutoRenewal)]),
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
    OpsAutoRenewalPage object, {
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
    required OpsAutoRenewalPageBuilder result,
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
                const FullType(BuiltList, [FullType(OpsAutoRenewal)]),
          ) as BuiltList<OpsAutoRenewal>;
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
  OpsAutoRenewalPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsAutoRenewalPageBuilder();
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

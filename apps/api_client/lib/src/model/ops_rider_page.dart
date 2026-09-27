//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/commute_request_page_page.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/ops_rider.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_rider_page.g.dart';

/// OpsRiderPage
///
/// Properties:
/// * [data] 
/// * [page] 
@BuiltValue()
abstract class OpsRiderPage implements Built<OpsRiderPage, OpsRiderPageBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<OpsRider> get data;

  @BuiltValueField(wireName: r'page')
  CommuteRequestPagePage get page;

  OpsRiderPage._();

  factory OpsRiderPage([void updates(OpsRiderPageBuilder b)]) = _$OpsRiderPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsRiderPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsRiderPage> get serializer => _$OpsRiderPageSerializer();
}

class _$OpsRiderPageSerializer implements PrimitiveSerializer<OpsRiderPage> {
  @override
  final Iterable<Type> types = const [OpsRiderPage, _$OpsRiderPage];

  @override
  final String wireName = r'OpsRiderPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsRiderPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(OpsRider)]),
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
    OpsRiderPage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OpsRiderPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(OpsRider)]),
          ) as BuiltList<OpsRider>;
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
  OpsRiderPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsRiderPageBuilder();
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


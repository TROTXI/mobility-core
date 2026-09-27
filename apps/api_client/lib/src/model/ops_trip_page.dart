//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/commute_request_page_page.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/ops_trip.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_trip_page.g.dart';

/// OpsTripPage
///
/// Properties:
/// * [data] 
/// * [page] 
@BuiltValue()
abstract class OpsTripPage implements Built<OpsTripPage, OpsTripPageBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<OpsTrip> get data;

  @BuiltValueField(wireName: r'page')
  CommuteRequestPagePage get page;

  OpsTripPage._();

  factory OpsTripPage([void updates(OpsTripPageBuilder b)]) = _$OpsTripPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsTripPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsTripPage> get serializer => _$OpsTripPageSerializer();
}

class _$OpsTripPageSerializer implements PrimitiveSerializer<OpsTripPage> {
  @override
  final Iterable<Type> types = const [OpsTripPage, _$OpsTripPage];

  @override
  final String wireName = r'OpsTripPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsTripPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(OpsTrip)]),
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
    OpsTripPage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OpsTripPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(OpsTrip)]),
          ) as BuiltList<OpsTrip>;
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
  OpsTripPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsTripPageBuilder();
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


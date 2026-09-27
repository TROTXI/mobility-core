//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/commute_request_page_page.dart';
import 'package:trotxi_api_client/src/model/ops_operator.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_operator_page.g.dart';

/// OpsOperatorPage
///
/// Properties:
/// * [data] 
/// * [page] 
@BuiltValue()
abstract class OpsOperatorPage implements Built<OpsOperatorPage, OpsOperatorPageBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<OpsOperator> get data;

  @BuiltValueField(wireName: r'page')
  CommuteRequestPagePage get page;

  OpsOperatorPage._();

  factory OpsOperatorPage([void updates(OpsOperatorPageBuilder b)]) = _$OpsOperatorPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsOperatorPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsOperatorPage> get serializer => _$OpsOperatorPageSerializer();
}

class _$OpsOperatorPageSerializer implements PrimitiveSerializer<OpsOperatorPage> {
  @override
  final Iterable<Type> types = const [OpsOperatorPage, _$OpsOperatorPage];

  @override
  final String wireName = r'OpsOperatorPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsOperatorPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(OpsOperator)]),
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
    OpsOperatorPage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OpsOperatorPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(OpsOperator)]),
          ) as BuiltList<OpsOperator>;
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
  OpsOperatorPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsOperatorPageBuilder();
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


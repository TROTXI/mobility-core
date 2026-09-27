//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/commute_request_page_page.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/commute_request.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commute_request_page.g.dart';

/// CommuteRequestPage
///
/// Properties:
/// * [data] 
/// * [page] 
@BuiltValue()
abstract class CommuteRequestPage implements Built<CommuteRequestPage, CommuteRequestPageBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<CommuteRequest> get data;

  @BuiltValueField(wireName: r'page')
  CommuteRequestPagePage get page;

  CommuteRequestPage._();

  factory CommuteRequestPage([void updates(CommuteRequestPageBuilder b)]) = _$CommuteRequestPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommuteRequestPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommuteRequestPage> get serializer => _$CommuteRequestPageSerializer();
}

class _$CommuteRequestPageSerializer implements PrimitiveSerializer<CommuteRequestPage> {
  @override
  final Iterable<Type> types = const [CommuteRequestPage, _$CommuteRequestPage];

  @override
  final String wireName = r'CommuteRequestPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommuteRequestPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(CommuteRequest)]),
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
    CommuteRequestPage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CommuteRequestPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(CommuteRequest)]),
          ) as BuiltList<CommuteRequest>;
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
  CommuteRequestPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommuteRequestPageBuilder();
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


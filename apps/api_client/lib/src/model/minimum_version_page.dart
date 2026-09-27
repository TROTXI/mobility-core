//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/minimum_version.dart';
import 'package:trotxi_api_client/src/model/commute_request_page_page.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'minimum_version_page.g.dart';

/// MinimumVersionPage
///
/// Properties:
/// * [data] 
/// * [page] 
@BuiltValue()
abstract class MinimumVersionPage implements Built<MinimumVersionPage, MinimumVersionPageBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<MinimumVersion> get data;

  @BuiltValueField(wireName: r'page')
  CommuteRequestPagePage get page;

  MinimumVersionPage._();

  factory MinimumVersionPage([void updates(MinimumVersionPageBuilder b)]) = _$MinimumVersionPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MinimumVersionPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MinimumVersionPage> get serializer => _$MinimumVersionPageSerializer();
}

class _$MinimumVersionPageSerializer implements PrimitiveSerializer<MinimumVersionPage> {
  @override
  final Iterable<Type> types = const [MinimumVersionPage, _$MinimumVersionPage];

  @override
  final String wireName = r'MinimumVersionPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MinimumVersionPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(MinimumVersion)]),
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
    MinimumVersionPage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MinimumVersionPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(MinimumVersion)]),
          ) as BuiltList<MinimumVersion>;
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
  MinimumVersionPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MinimumVersionPageBuilder();
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


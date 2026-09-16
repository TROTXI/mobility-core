//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/commute_request_page_page.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/flag.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'flag_page.g.dart';

/// FlagPage
///
/// Properties:
/// * [data] 
/// * [page] 
@BuiltValue()
abstract class FlagPage implements Built<FlagPage, FlagPageBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<Flag> get data;

  @BuiltValueField(wireName: r'page')
  CommuteRequestPagePage get page;

  FlagPage._();

  factory FlagPage([void updates(FlagPageBuilder b)]) = _$FlagPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FlagPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FlagPage> get serializer => _$FlagPageSerializer();
}

class _$FlagPageSerializer implements PrimitiveSerializer<FlagPage> {
  @override
  final Iterable<Type> types = const [FlagPage, _$FlagPage];

  @override
  final String wireName = r'FlagPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FlagPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(Flag)]),
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
    FlagPage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FlagPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Flag)]),
          ) as BuiltList<Flag>;
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
  FlagPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FlagPageBuilder();
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


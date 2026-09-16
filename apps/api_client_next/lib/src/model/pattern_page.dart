//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/commute_request_page_page.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client_next/src/model/pattern.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pattern_page.g.dart';

/// PatternPage
///
/// Properties:
/// * [data] 
/// * [page] 
@BuiltValue()
abstract class PatternPage implements Built<PatternPage, PatternPageBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<Pattern> get data;

  @BuiltValueField(wireName: r'page')
  CommuteRequestPagePage get page;

  PatternPage._();

  factory PatternPage([void updates(PatternPageBuilder b)]) = _$PatternPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PatternPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PatternPage> get serializer => _$PatternPageSerializer();
}

class _$PatternPageSerializer implements PrimitiveSerializer<PatternPage> {
  @override
  final Iterable<Type> types = const [PatternPage, _$PatternPage];

  @override
  final String wireName = r'PatternPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PatternPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(Pattern)]),
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
    PatternPage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PatternPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Pattern)]),
          ) as BuiltList<Pattern>;
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
  PatternPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PatternPageBuilder();
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


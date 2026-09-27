//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/commute_request_page_page.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/pattern_version.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pattern_version_page.g.dart';

/// PatternVersionPage
///
/// Properties:
<<<<<<< HEAD
/// * [data] 
/// * [page] 
@BuiltValue()
abstract class PatternVersionPage implements Built<PatternVersionPage, PatternVersionPageBuilder> {
=======
/// * [data]
/// * [page]
@BuiltValue()
abstract class PatternVersionPage
    implements Built<PatternVersionPage, PatternVersionPageBuilder> {
>>>>>>> origin/main
  @BuiltValueField(wireName: r'data')
  BuiltList<PatternVersion> get data;

  @BuiltValueField(wireName: r'page')
  CommuteRequestPagePage get page;

  PatternVersionPage._();

<<<<<<< HEAD
  factory PatternVersionPage([void updates(PatternVersionPageBuilder b)]) = _$PatternVersionPage;
=======
  factory PatternVersionPage([void updates(PatternVersionPageBuilder b)]) =
      _$PatternVersionPage;
>>>>>>> origin/main

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PatternVersionPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
<<<<<<< HEAD
  static Serializer<PatternVersionPage> get serializer => _$PatternVersionPageSerializer();
}

class _$PatternVersionPageSerializer implements PrimitiveSerializer<PatternVersionPage> {
=======
  static Serializer<PatternVersionPage> get serializer =>
      _$PatternVersionPageSerializer();
}

class _$PatternVersionPageSerializer
    implements PrimitiveSerializer<PatternVersionPage> {
>>>>>>> origin/main
  @override
  final Iterable<Type> types = const [PatternVersionPage, _$PatternVersionPage];

  @override
  final String wireName = r'PatternVersionPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PatternVersionPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(PatternVersion)]),
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
    PatternVersionPage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
<<<<<<< HEAD
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
=======
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
>>>>>>> origin/main
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PatternVersionPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
<<<<<<< HEAD
            specifiedType: const FullType(BuiltList, [FullType(PatternVersion)]),
=======
            specifiedType:
                const FullType(BuiltList, [FullType(PatternVersion)]),
>>>>>>> origin/main
          ) as BuiltList<PatternVersion>;
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
  PatternVersionPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PatternVersionPageBuilder();
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
<<<<<<< HEAD

=======
>>>>>>> origin/main

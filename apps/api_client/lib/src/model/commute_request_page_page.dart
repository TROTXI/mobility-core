//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commute_request_page_page.g.dart';

/// CommuteRequestPagePage
///
/// Properties:
/// * [nextCursor] 
@BuiltValue()
abstract class CommuteRequestPagePage implements Built<CommuteRequestPagePage, CommuteRequestPagePageBuilder> {
  @BuiltValueField(wireName: r'nextCursor')
  String? get nextCursor;

  CommuteRequestPagePage._();

  factory CommuteRequestPagePage([void updates(CommuteRequestPagePageBuilder b)]) = _$CommuteRequestPagePage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommuteRequestPagePageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommuteRequestPagePage> get serializer => _$CommuteRequestPagePageSerializer();
}

class _$CommuteRequestPagePageSerializer implements PrimitiveSerializer<CommuteRequestPagePage> {
  @override
  final Iterable<Type> types = const [CommuteRequestPagePage, _$CommuteRequestPagePage];

  @override
  final String wireName = r'CommuteRequestPagePage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommuteRequestPagePage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'nextCursor';
    yield object.nextCursor == null ? null : serializers.serialize(
      object.nextCursor,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CommuteRequestPagePage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CommuteRequestPagePageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'nextCursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.nextCursor = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CommuteRequestPagePage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommuteRequestPagePageBuilder();
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


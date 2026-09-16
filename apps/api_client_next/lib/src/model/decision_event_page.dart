//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/commute_request_page_page.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client_next/src/model/decision_event.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'decision_event_page.g.dart';

/// DecisionEventPage
///
/// Properties:
/// * [data] 
/// * [page] 
@BuiltValue()
abstract class DecisionEventPage implements Built<DecisionEventPage, DecisionEventPageBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<DecisionEvent> get data;

  @BuiltValueField(wireName: r'page')
  CommuteRequestPagePage get page;

  DecisionEventPage._();

  factory DecisionEventPage([void updates(DecisionEventPageBuilder b)]) = _$DecisionEventPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DecisionEventPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DecisionEventPage> get serializer => _$DecisionEventPageSerializer();
}

class _$DecisionEventPageSerializer implements PrimitiveSerializer<DecisionEventPage> {
  @override
  final Iterable<Type> types = const [DecisionEventPage, _$DecisionEventPage];

  @override
  final String wireName = r'DecisionEventPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DecisionEventPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(DecisionEvent)]),
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
    DecisionEventPage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DecisionEventPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(DecisionEvent)]),
          ) as BuiltList<DecisionEvent>;
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
  DecisionEventPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DecisionEventPageBuilder();
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


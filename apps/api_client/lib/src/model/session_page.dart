//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/commute_request_page_page.dart';
import 'package:trotxi_api_client/src/model/session.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'session_page.g.dart';

/// SessionPage
///
/// Properties:
/// * [data] 
/// * [page] 
@BuiltValue()
abstract class SessionPage implements Built<SessionPage, SessionPageBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<Session> get data;

  @BuiltValueField(wireName: r'page')
  CommuteRequestPagePage get page;

  SessionPage._();

  factory SessionPage([void updates(SessionPageBuilder b)]) = _$SessionPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SessionPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SessionPage> get serializer => _$SessionPageSerializer();
}

class _$SessionPageSerializer implements PrimitiveSerializer<SessionPage> {
  @override
  final Iterable<Type> types = const [SessionPage, _$SessionPage];

  @override
  final String wireName = r'SessionPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SessionPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(Session)]),
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
    SessionPage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SessionPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Session)]),
          ) as BuiltList<Session>;
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
  SessionPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SessionPageBuilder();
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


//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/trip.dart';
import 'package:trotxi_api_client/src/model/commute_request_page_page.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'trip_page.g.dart';

/// TripPage
///
/// Properties:
/// * [data] 
/// * [page] 
@BuiltValue()
abstract class TripPage implements Built<TripPage, TripPageBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<Trip> get data;

  @BuiltValueField(wireName: r'page')
  CommuteRequestPagePage get page;

  TripPage._();

  factory TripPage([void updates(TripPageBuilder b)]) = _$TripPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TripPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TripPage> get serializer => _$TripPageSerializer();
}

class _$TripPageSerializer implements PrimitiveSerializer<TripPage> {
  @override
  final Iterable<Type> types = const [TripPage, _$TripPage];

  @override
  final String wireName = r'TripPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TripPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(Trip)]),
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
    TripPage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TripPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Trip)]),
          ) as BuiltList<Trip>;
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
  TripPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TripPageBuilder();
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


//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/commute_request_page_page.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/reservation.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reservation_page.g.dart';

/// ReservationPage
///
/// Properties:
/// * [data] 
/// * [page] 
@BuiltValue()
abstract class ReservationPage implements Built<ReservationPage, ReservationPageBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<Reservation> get data;

  @BuiltValueField(wireName: r'page')
  CommuteRequestPagePage get page;

  ReservationPage._();

  factory ReservationPage([void updates(ReservationPageBuilder b)]) = _$ReservationPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReservationPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReservationPage> get serializer => _$ReservationPageSerializer();
}

class _$ReservationPageSerializer implements PrimitiveSerializer<ReservationPage> {
  @override
  final Iterable<Type> types = const [ReservationPage, _$ReservationPage];

  @override
  final String wireName = r'ReservationPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReservationPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(Reservation)]),
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
    ReservationPage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReservationPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Reservation)]),
          ) as BuiltList<Reservation>;
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
  ReservationPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReservationPageBuilder();
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


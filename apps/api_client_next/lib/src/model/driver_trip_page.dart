//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/commute_request_page_page.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client_next/src/model/driver_trip.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'driver_trip_page.g.dart';

/// DriverTripPage
///
/// Properties:
/// * [data] 
/// * [page] 
@BuiltValue()
abstract class DriverTripPage implements Built<DriverTripPage, DriverTripPageBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<DriverTrip> get data;

  @BuiltValueField(wireName: r'page')
  CommuteRequestPagePage get page;

  DriverTripPage._();

  factory DriverTripPage([void updates(DriverTripPageBuilder b)]) = _$DriverTripPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DriverTripPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DriverTripPage> get serializer => _$DriverTripPageSerializer();
}

class _$DriverTripPageSerializer implements PrimitiveSerializer<DriverTripPage> {
  @override
  final Iterable<Type> types = const [DriverTripPage, _$DriverTripPage];

  @override
  final String wireName = r'DriverTripPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DriverTripPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(DriverTrip)]),
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
    DriverTripPage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DriverTripPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(DriverTrip)]),
          ) as BuiltList<DriverTrip>;
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
  DriverTripPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DriverTripPageBuilder();
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


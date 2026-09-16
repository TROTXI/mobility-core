//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/commute_request_page_page.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client_next/src/model/driver.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'driver_page.g.dart';

/// DriverPage
///
/// Properties:
/// * [data] 
/// * [page] 
@BuiltValue()
abstract class DriverPage implements Built<DriverPage, DriverPageBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<Driver> get data;

  @BuiltValueField(wireName: r'page')
  CommuteRequestPagePage get page;

  DriverPage._();

  factory DriverPage([void updates(DriverPageBuilder b)]) = _$DriverPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DriverPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DriverPage> get serializer => _$DriverPageSerializer();
}

class _$DriverPageSerializer implements PrimitiveSerializer<DriverPage> {
  @override
  final Iterable<Type> types = const [DriverPage, _$DriverPage];

  @override
  final String wireName = r'DriverPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DriverPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(Driver)]),
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
    DriverPage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DriverPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Driver)]),
          ) as BuiltList<Driver>;
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
  DriverPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DriverPageBuilder();
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


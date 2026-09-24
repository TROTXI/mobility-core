//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/commute_request_page_page.dart';
import 'package:trotxi_api_client/src/model/vehicle.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'vehicle_page.g.dart';

/// VehiclePage
///
/// Properties:
/// * [data] 
/// * [page] 
@BuiltValue()
abstract class VehiclePage implements Built<VehiclePage, VehiclePageBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<Vehicle> get data;

  @BuiltValueField(wireName: r'page')
  CommuteRequestPagePage get page;

  VehiclePage._();

  factory VehiclePage([void updates(VehiclePageBuilder b)]) = _$VehiclePage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(VehiclePageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<VehiclePage> get serializer => _$VehiclePageSerializer();
}

class _$VehiclePageSerializer implements PrimitiveSerializer<VehiclePage> {
  @override
  final Iterable<Type> types = const [VehiclePage, _$VehiclePage];

  @override
  final String wireName = r'VehiclePage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    VehiclePage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(Vehicle)]),
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
    VehiclePage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required VehiclePageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Vehicle)]),
          ) as BuiltList<Vehicle>;
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
  VehiclePage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = VehiclePageBuilder();
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


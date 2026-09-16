//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/commute_request_page_page.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client_next/src/model/fare.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'fare_page.g.dart';

/// FarePage
///
/// Properties:
/// * [data] 
/// * [page] 
@BuiltValue()
abstract class FarePage implements Built<FarePage, FarePageBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<Fare> get data;

  @BuiltValueField(wireName: r'page')
  CommuteRequestPagePage get page;

  FarePage._();

  factory FarePage([void updates(FarePageBuilder b)]) = _$FarePage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FarePageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FarePage> get serializer => _$FarePageSerializer();
}

class _$FarePageSerializer implements PrimitiveSerializer<FarePage> {
  @override
  final Iterable<Type> types = const [FarePage, _$FarePage];

  @override
  final String wireName = r'FarePage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FarePage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(Fare)]),
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
    FarePage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FarePageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Fare)]),
          ) as BuiltList<Fare>;
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
  FarePage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FarePageBuilder();
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


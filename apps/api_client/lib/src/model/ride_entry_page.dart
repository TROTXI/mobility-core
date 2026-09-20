//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/commute_request_page_page.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/ride_entry.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ride_entry_page.g.dart';

/// RideEntryPage
///
/// Properties:
/// * [data] 
/// * [page] 
@BuiltValue()
abstract class RideEntryPage implements Built<RideEntryPage, RideEntryPageBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<RideEntry> get data;

  @BuiltValueField(wireName: r'page')
  CommuteRequestPagePage get page;

  RideEntryPage._();

  factory RideEntryPage([void updates(RideEntryPageBuilder b)]) = _$RideEntryPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RideEntryPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RideEntryPage> get serializer => _$RideEntryPageSerializer();
}

class _$RideEntryPageSerializer implements PrimitiveSerializer<RideEntryPage> {
  @override
  final Iterable<Type> types = const [RideEntryPage, _$RideEntryPage];

  @override
  final String wireName = r'RideEntryPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RideEntryPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(RideEntry)]),
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
    RideEntryPage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RideEntryPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(RideEntry)]),
          ) as BuiltList<RideEntry>;
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
  RideEntryPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RideEntryPageBuilder();
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


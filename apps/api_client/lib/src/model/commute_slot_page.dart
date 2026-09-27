//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/commute_request_page_page.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/commute_slot.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commute_slot_page.g.dart';

/// CommuteSlotPage
///
/// Properties:
<<<<<<< HEAD
/// * [data] 
/// * [page] 
@BuiltValue()
abstract class CommuteSlotPage implements Built<CommuteSlotPage, CommuteSlotPageBuilder> {
=======
/// * [data]
/// * [page]
@BuiltValue()
abstract class CommuteSlotPage
    implements Built<CommuteSlotPage, CommuteSlotPageBuilder> {
>>>>>>> origin/main
  @BuiltValueField(wireName: r'data')
  BuiltList<CommuteSlot> get data;

  @BuiltValueField(wireName: r'page')
  CommuteRequestPagePage get page;

  CommuteSlotPage._();

<<<<<<< HEAD
  factory CommuteSlotPage([void updates(CommuteSlotPageBuilder b)]) = _$CommuteSlotPage;
=======
  factory CommuteSlotPage([void updates(CommuteSlotPageBuilder b)]) =
      _$CommuteSlotPage;
>>>>>>> origin/main

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommuteSlotPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
<<<<<<< HEAD
  static Serializer<CommuteSlotPage> get serializer => _$CommuteSlotPageSerializer();
}

class _$CommuteSlotPageSerializer implements PrimitiveSerializer<CommuteSlotPage> {
=======
  static Serializer<CommuteSlotPage> get serializer =>
      _$CommuteSlotPageSerializer();
}

class _$CommuteSlotPageSerializer
    implements PrimitiveSerializer<CommuteSlotPage> {
>>>>>>> origin/main
  @override
  final Iterable<Type> types = const [CommuteSlotPage, _$CommuteSlotPage];

  @override
  final String wireName = r'CommuteSlotPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommuteSlotPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(CommuteSlot)]),
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
    CommuteSlotPage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
<<<<<<< HEAD
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
=======
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
>>>>>>> origin/main
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CommuteSlotPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(CommuteSlot)]),
          ) as BuiltList<CommuteSlot>;
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
  CommuteSlotPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommuteSlotPageBuilder();
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
<<<<<<< HEAD

=======
>>>>>>> origin/main

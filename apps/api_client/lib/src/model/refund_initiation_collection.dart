//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/refund_initiation.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'refund_initiation_collection.g.dart';

/// RefundInitiationCollection
///
/// Properties:
<<<<<<< HEAD
/// * [items] 
@BuiltValue()
abstract class RefundInitiationCollection implements Built<RefundInitiationCollection, RefundInitiationCollectionBuilder> {
=======
/// * [items]
@BuiltValue()
abstract class RefundInitiationCollection
    implements
        Built<RefundInitiationCollection, RefundInitiationCollectionBuilder> {
>>>>>>> origin/main
  @BuiltValueField(wireName: r'items')
  BuiltList<RefundInitiation> get items;

  RefundInitiationCollection._();

<<<<<<< HEAD
  factory RefundInitiationCollection([void updates(RefundInitiationCollectionBuilder b)]) = _$RefundInitiationCollection;
=======
  factory RefundInitiationCollection(
          [void updates(RefundInitiationCollectionBuilder b)]) =
      _$RefundInitiationCollection;
>>>>>>> origin/main

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RefundInitiationCollectionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
<<<<<<< HEAD
  static Serializer<RefundInitiationCollection> get serializer => _$RefundInitiationCollectionSerializer();
}

class _$RefundInitiationCollectionSerializer implements PrimitiveSerializer<RefundInitiationCollection> {
  @override
  final Iterable<Type> types = const [RefundInitiationCollection, _$RefundInitiationCollection];
=======
  static Serializer<RefundInitiationCollection> get serializer =>
      _$RefundInitiationCollectionSerializer();
}

class _$RefundInitiationCollectionSerializer
    implements PrimitiveSerializer<RefundInitiationCollection> {
  @override
  final Iterable<Type> types = const [
    RefundInitiationCollection,
    _$RefundInitiationCollection
  ];
>>>>>>> origin/main

  @override
  final String wireName = r'RefundInitiationCollection';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RefundInitiationCollection object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(RefundInitiation)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RefundInitiationCollection object, {
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
    required RefundInitiationCollectionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
<<<<<<< HEAD
            specifiedType: const FullType(BuiltList, [FullType(RefundInitiation)]),
=======
            specifiedType:
                const FullType(BuiltList, [FullType(RefundInitiation)]),
>>>>>>> origin/main
          ) as BuiltList<RefundInitiation>;
          result.items.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RefundInitiationCollection deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RefundInitiationCollectionBuilder();
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

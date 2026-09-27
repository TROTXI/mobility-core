//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/commute_request_page_page.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/credit_entry.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'credit_entry_page.g.dart';

/// CreditEntryPage
///
/// Properties:
<<<<<<< HEAD
/// * [data] 
/// * [page] 
@BuiltValue()
abstract class CreditEntryPage implements Built<CreditEntryPage, CreditEntryPageBuilder> {
=======
/// * [data]
/// * [page]
@BuiltValue()
abstract class CreditEntryPage
    implements Built<CreditEntryPage, CreditEntryPageBuilder> {
>>>>>>> origin/main
  @BuiltValueField(wireName: r'data')
  BuiltList<CreditEntry> get data;

  @BuiltValueField(wireName: r'page')
  CommuteRequestPagePage get page;

  CreditEntryPage._();

<<<<<<< HEAD
  factory CreditEntryPage([void updates(CreditEntryPageBuilder b)]) = _$CreditEntryPage;
=======
  factory CreditEntryPage([void updates(CreditEntryPageBuilder b)]) =
      _$CreditEntryPage;
>>>>>>> origin/main

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreditEntryPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
<<<<<<< HEAD
  static Serializer<CreditEntryPage> get serializer => _$CreditEntryPageSerializer();
}

class _$CreditEntryPageSerializer implements PrimitiveSerializer<CreditEntryPage> {
=======
  static Serializer<CreditEntryPage> get serializer =>
      _$CreditEntryPageSerializer();
}

class _$CreditEntryPageSerializer
    implements PrimitiveSerializer<CreditEntryPage> {
>>>>>>> origin/main
  @override
  final Iterable<Type> types = const [CreditEntryPage, _$CreditEntryPage];

  @override
  final String wireName = r'CreditEntryPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreditEntryPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(CreditEntry)]),
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
    CreditEntryPage object, {
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
    required CreditEntryPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(CreditEntry)]),
          ) as BuiltList<CreditEntry>;
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
  CreditEntryPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreditEntryPageBuilder();
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

//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'boarding_input_one_of2.g.dart';

/// BoardingInputOneOf2
///
/// Properties:
/// * [kind] 
/// * [reservationId] 
@BuiltValue()
abstract class BoardingInputOneOf2 implements Built<BoardingInputOneOf2, BoardingInputOneOf2Builder> {
  @BuiltValueField(wireName: r'kind')
  BoardingInputOneOf2KindEnum get kind;
  // enum kindEnum {  photo,  };

  @BuiltValueField(wireName: r'reservationId')
  String get reservationId;

  BoardingInputOneOf2._();

  factory BoardingInputOneOf2([void updates(BoardingInputOneOf2Builder b)]) = _$BoardingInputOneOf2;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BoardingInputOneOf2Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BoardingInputOneOf2> get serializer => _$BoardingInputOneOf2Serializer();
}

class _$BoardingInputOneOf2Serializer implements PrimitiveSerializer<BoardingInputOneOf2> {
  @override
  final Iterable<Type> types = const [BoardingInputOneOf2, _$BoardingInputOneOf2];

  @override
  final String wireName = r'BoardingInputOneOf2';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BoardingInputOneOf2 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(BoardingInputOneOf2KindEnum),
    );
    yield r'reservationId';
    yield serializers.serialize(
      object.reservationId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BoardingInputOneOf2 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BoardingInputOneOf2Builder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BoardingInputOneOf2KindEnum),
          ) as BoardingInputOneOf2KindEnum;
          result.kind = valueDes;
          break;
        case r'reservationId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reservationId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BoardingInputOneOf2 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BoardingInputOneOf2Builder();
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

class BoardingInputOneOf2KindEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'photo')
  static const BoardingInputOneOf2KindEnum photo = _$boardingInputOneOf2KindEnum_photo;

  static Serializer<BoardingInputOneOf2KindEnum> get serializer => _$boardingInputOneOf2KindEnumSerializer;

  const BoardingInputOneOf2KindEnum._(String name): super(name);

  static BuiltSet<BoardingInputOneOf2KindEnum> get values => _$boardingInputOneOf2KindEnumValues;
  static BoardingInputOneOf2KindEnum valueOf(String name) => _$boardingInputOneOf2KindEnumValueOf(name);
}


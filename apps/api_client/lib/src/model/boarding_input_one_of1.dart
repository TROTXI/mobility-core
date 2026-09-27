//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'boarding_input_one_of1.g.dart';

/// BoardingInputOneOf1
///
/// Properties:
/// * [kind] 
/// * [code] 
@BuiltValue()
abstract class BoardingInputOneOf1 implements Built<BoardingInputOneOf1, BoardingInputOneOf1Builder> {
  @BuiltValueField(wireName: r'kind')
  BoardingInputOneOf1KindEnum get kind;
  // enum kindEnum {  code,  };

  @BuiltValueField(wireName: r'code')
  String get code;

  BoardingInputOneOf1._();

  factory BoardingInputOneOf1([void updates(BoardingInputOneOf1Builder b)]) = _$BoardingInputOneOf1;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BoardingInputOneOf1Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BoardingInputOneOf1> get serializer => _$BoardingInputOneOf1Serializer();
}

class _$BoardingInputOneOf1Serializer implements PrimitiveSerializer<BoardingInputOneOf1> {
  @override
  final Iterable<Type> types = const [BoardingInputOneOf1, _$BoardingInputOneOf1];

  @override
  final String wireName = r'BoardingInputOneOf1';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BoardingInputOneOf1 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(BoardingInputOneOf1KindEnum),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BoardingInputOneOf1 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BoardingInputOneOf1Builder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BoardingInputOneOf1KindEnum),
          ) as BoardingInputOneOf1KindEnum;
          result.kind = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BoardingInputOneOf1 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BoardingInputOneOf1Builder();
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

class BoardingInputOneOf1KindEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'code')
  static const BoardingInputOneOf1KindEnum code = _$boardingInputOneOf1KindEnum_code;

  static Serializer<BoardingInputOneOf1KindEnum> get serializer => _$boardingInputOneOf1KindEnumSerializer;

  const BoardingInputOneOf1KindEnum._(String name): super(name);

  static BuiltSet<BoardingInputOneOf1KindEnum> get values => _$boardingInputOneOf1KindEnumValues;
  static BoardingInputOneOf1KindEnum valueOf(String name) => _$boardingInputOneOf1KindEnumValueOf(name);
}


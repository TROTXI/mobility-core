//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'boarding_input_one_of.g.dart';

/// BoardingInputOneOf
///
/// Properties:
<<<<<<< HEAD
/// * [kind] 
/// * [token] 
@BuiltValue()
abstract class BoardingInputOneOf implements Built<BoardingInputOneOf, BoardingInputOneOfBuilder> {
=======
/// * [kind]
/// * [token]
@BuiltValue()
abstract class BoardingInputOneOf
    implements Built<BoardingInputOneOf, BoardingInputOneOfBuilder> {
>>>>>>> origin/main
  @BuiltValueField(wireName: r'kind')
  BoardingInputOneOfKindEnum get kind;
  // enum kindEnum {  qr,  };

  @BuiltValueField(wireName: r'token')
  String get token;

  BoardingInputOneOf._();

<<<<<<< HEAD
  factory BoardingInputOneOf([void updates(BoardingInputOneOfBuilder b)]) = _$BoardingInputOneOf;
=======
  factory BoardingInputOneOf([void updates(BoardingInputOneOfBuilder b)]) =
      _$BoardingInputOneOf;
>>>>>>> origin/main

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BoardingInputOneOfBuilder b) => b;

  @BuiltValueSerializer(custom: true)
<<<<<<< HEAD
  static Serializer<BoardingInputOneOf> get serializer => _$BoardingInputOneOfSerializer();
}

class _$BoardingInputOneOfSerializer implements PrimitiveSerializer<BoardingInputOneOf> {
=======
  static Serializer<BoardingInputOneOf> get serializer =>
      _$BoardingInputOneOfSerializer();
}

class _$BoardingInputOneOfSerializer
    implements PrimitiveSerializer<BoardingInputOneOf> {
>>>>>>> origin/main
  @override
  final Iterable<Type> types = const [BoardingInputOneOf, _$BoardingInputOneOf];

  @override
  final String wireName = r'BoardingInputOneOf';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BoardingInputOneOf object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(BoardingInputOneOfKindEnum),
    );
    yield r'token';
    yield serializers.serialize(
      object.token,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BoardingInputOneOf object, {
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
    required BoardingInputOneOfBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BoardingInputOneOfKindEnum),
          ) as BoardingInputOneOfKindEnum;
          result.kind = valueDes;
          break;
        case r'token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.token = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BoardingInputOneOf deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BoardingInputOneOfBuilder();
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

class BoardingInputOneOfKindEnum extends EnumClass {
<<<<<<< HEAD

  @BuiltValueEnumConst(wireName: r'qr')
  static const BoardingInputOneOfKindEnum qr = _$boardingInputOneOfKindEnum_qr;

  static Serializer<BoardingInputOneOfKindEnum> get serializer => _$boardingInputOneOfKindEnumSerializer;

  const BoardingInputOneOfKindEnum._(String name): super(name);

  static BuiltSet<BoardingInputOneOfKindEnum> get values => _$boardingInputOneOfKindEnumValues;
  static BoardingInputOneOfKindEnum valueOf(String name) => _$boardingInputOneOfKindEnumValueOf(name);
}

=======
  @BuiltValueEnumConst(wireName: r'qr')
  static const BoardingInputOneOfKindEnum qr = _$boardingInputOneOfKindEnum_qr;

  static Serializer<BoardingInputOneOfKindEnum> get serializer =>
      _$boardingInputOneOfKindEnumSerializer;

  const BoardingInputOneOfKindEnum._(String name) : super(name);

  static BuiltSet<BoardingInputOneOfKindEnum> get values =>
      _$boardingInputOneOfKindEnumValues;
  static BoardingInputOneOfKindEnum valueOf(String name) =>
      _$boardingInputOneOfKindEnumValueOf(name);
}
>>>>>>> origin/main

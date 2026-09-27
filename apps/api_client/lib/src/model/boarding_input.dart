//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/boarding_input_one_of1.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/boarding_input_one_of2.dart';
import 'package:trotxi_api_client/src/model/boarding_input_one_of.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/one_of.dart';

part 'boarding_input.g.dart';

/// BoardingInput
///
/// Properties:
<<<<<<< HEAD
/// * [kind] 
/// * [token] 
/// * [code] 
/// * [reservationId] 
@BuiltValue()
abstract class BoardingInput implements Built<BoardingInput, BoardingInputBuilder> {
=======
/// * [kind]
/// * [token]
/// * [code]
/// * [reservationId]
@BuiltValue()
abstract class BoardingInput
    implements Built<BoardingInput, BoardingInputBuilder> {
>>>>>>> origin/main
  /// One Of [BoardingInputOneOf], [BoardingInputOneOf1], [BoardingInputOneOf2]
  OneOf get oneOf;

  BoardingInput._();

<<<<<<< HEAD
  factory BoardingInput([void updates(BoardingInputBuilder b)]) = _$BoardingInput;
=======
  factory BoardingInput([void updates(BoardingInputBuilder b)]) =
      _$BoardingInput;
>>>>>>> origin/main

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BoardingInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
<<<<<<< HEAD
  static Serializer<BoardingInput> get serializer => _$BoardingInputSerializer();
=======
  static Serializer<BoardingInput> get serializer =>
      _$BoardingInputSerializer();
>>>>>>> origin/main
}

class _$BoardingInputSerializer implements PrimitiveSerializer<BoardingInput> {
  @override
  final Iterable<Type> types = const [BoardingInput, _$BoardingInput];

  @override
  final String wireName = r'BoardingInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BoardingInput object, {
    FullType specifiedType = FullType.unspecified,
<<<<<<< HEAD
  }) sync* {
  }
=======
  }) sync* {}
>>>>>>> origin/main

  @override
  Object serialize(
    Serializers serializers,
    BoardingInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final oneOf = object.oneOf;
<<<<<<< HEAD
    return serializers.serialize(oneOf.value, specifiedType: FullType(oneOf.valueType))!;
=======
    return serializers.serialize(oneOf.value,
        specifiedType: FullType(oneOf.valueType))!;
>>>>>>> origin/main
  }

  @override
  BoardingInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BoardingInputBuilder();
    Object? oneOfDataSrc;
<<<<<<< HEAD
    final targetType = const FullType(OneOf, [FullType(BoardingInputOneOf), FullType(BoardingInputOneOf1), FullType(BoardingInputOneOf2), ]);
    oneOfDataSrc = serialized;
    result.oneOf = serializers.deserialize(oneOfDataSrc, specifiedType: targetType) as OneOf;
=======
    final targetType = const FullType(OneOf, [
      FullType(BoardingInputOneOf),
      FullType(BoardingInputOneOf1),
      FullType(BoardingInputOneOf2),
    ]);
    oneOfDataSrc = serialized;
    result.oneOf = serializers.deserialize(oneOfDataSrc,
        specifiedType: targetType) as OneOf;
>>>>>>> origin/main
    return result.build();
  }
}

class BoardingInputKindEnum extends EnumClass {
<<<<<<< HEAD

  @BuiltValueEnumConst(wireName: r'photo')
  static const BoardingInputKindEnum photo = _$boardingInputKindEnum_photo;

  static Serializer<BoardingInputKindEnum> get serializer => _$boardingInputKindEnumSerializer;

  const BoardingInputKindEnum._(String name): super(name);

  static BuiltSet<BoardingInputKindEnum> get values => _$boardingInputKindEnumValues;
  static BoardingInputKindEnum valueOf(String name) => _$boardingInputKindEnumValueOf(name);
}

=======
  @BuiltValueEnumConst(wireName: r'photo')
  static const BoardingInputKindEnum photo = _$boardingInputKindEnum_photo;

  static Serializer<BoardingInputKindEnum> get serializer =>
      _$boardingInputKindEnumSerializer;

  const BoardingInputKindEnum._(String name) : super(name);

  static BuiltSet<BoardingInputKindEnum> get values =>
      _$boardingInputKindEnumValues;
  static BoardingInputKindEnum valueOf(String name) =>
      _$boardingInputKindEnumValueOf(name);
}
>>>>>>> origin/main

//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/boarding_input_one_of2.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client_next/src/model/boarding_input_one_of1.dart';
import 'package:trotxi_api_client_next/src/model/boarding_input_one_of.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/one_of.dart';

part 'boarding_input.g.dart';

/// BoardingInput
///
/// Properties:
/// * [kind] 
/// * [token] 
/// * [code] 
/// * [reservationId] 
@BuiltValue()
abstract class BoardingInput implements Built<BoardingInput, BoardingInputBuilder> {
  /// One Of [BoardingInputOneOf], [BoardingInputOneOf1], [BoardingInputOneOf2]
  OneOf get oneOf;

  BoardingInput._();

  factory BoardingInput([void updates(BoardingInputBuilder b)]) = _$BoardingInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BoardingInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BoardingInput> get serializer => _$BoardingInputSerializer();
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
  }) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    BoardingInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final oneOf = object.oneOf;
    return serializers.serialize(oneOf.value, specifiedType: FullType(oneOf.valueType))!;
  }

  @override
  BoardingInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BoardingInputBuilder();
    Object? oneOfDataSrc;
    final targetType = const FullType(OneOf, [FullType(BoardingInputOneOf), FullType(BoardingInputOneOf1), FullType(BoardingInputOneOf2), ]);
    oneOfDataSrc = serialized;
    result.oneOf = serializers.deserialize(oneOfDataSrc, specifiedType: targetType) as OneOf;
    return result.build();
  }
}

class BoardingInputKindEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'photo')
  static const BoardingInputKindEnum photo = _$boardingInputKindEnum_photo;

  static Serializer<BoardingInputKindEnum> get serializer => _$boardingInputKindEnumSerializer;

  const BoardingInputKindEnum._(String name): super(name);

  static BuiltSet<BoardingInputKindEnum> get values => _$boardingInputKindEnumValues;
  static BoardingInputKindEnum valueOf(String name) => _$boardingInputKindEnumValueOf(name);
}


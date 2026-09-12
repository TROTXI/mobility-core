//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'boarding_board_post200_response.g.dart';

/// BoardingBoardPost200Response
///
/// Properties:
/// * [riderId] 
/// * [reason] 
/// * [deducted] 
@BuiltValue()
abstract class BoardingBoardPost200Response implements Built<BoardingBoardPost200Response, BoardingBoardPost200ResponseBuilder> {
  @BuiltValueField(wireName: r'riderId')
  String? get riderId;

  @BuiltValueField(wireName: r'reason')
  BoardingBoardPost200ResponseReasonEnum get reason;
  // enum reasonEnum {  ok,  not_found,  already_boarded,  not_boardable,  forbidden,  };

  @BuiltValueField(wireName: r'deducted')
  bool get deducted;

  BoardingBoardPost200Response._();

  factory BoardingBoardPost200Response([void updates(BoardingBoardPost200ResponseBuilder b)]) = _$BoardingBoardPost200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BoardingBoardPost200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BoardingBoardPost200Response> get serializer => _$BoardingBoardPost200ResponseSerializer();
}

class _$BoardingBoardPost200ResponseSerializer implements PrimitiveSerializer<BoardingBoardPost200Response> {
  @override
  final Iterable<Type> types = const [BoardingBoardPost200Response, _$BoardingBoardPost200Response];

  @override
  final String wireName = r'BoardingBoardPost200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BoardingBoardPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'riderId';
    yield object.riderId == null ? null : serializers.serialize(
      object.riderId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(BoardingBoardPost200ResponseReasonEnum),
    );
    yield r'deducted';
    yield serializers.serialize(
      object.deducted,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BoardingBoardPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BoardingBoardPost200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'riderId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.riderId = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BoardingBoardPost200ResponseReasonEnum),
          ) as BoardingBoardPost200ResponseReasonEnum;
          result.reason = valueDes;
          break;
        case r'deducted':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.deducted = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BoardingBoardPost200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BoardingBoardPost200ResponseBuilder();
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

class BoardingBoardPost200ResponseReasonEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ok')
  static const BoardingBoardPost200ResponseReasonEnum ok = _$boardingBoardPost200ResponseReasonEnum_ok;
  @BuiltValueEnumConst(wireName: r'not_found')
  static const BoardingBoardPost200ResponseReasonEnum notFound = _$boardingBoardPost200ResponseReasonEnum_notFound;
  @BuiltValueEnumConst(wireName: r'already_boarded')
  static const BoardingBoardPost200ResponseReasonEnum alreadyBoarded = _$boardingBoardPost200ResponseReasonEnum_alreadyBoarded;
  @BuiltValueEnumConst(wireName: r'not_boardable')
  static const BoardingBoardPost200ResponseReasonEnum notBoardable = _$boardingBoardPost200ResponseReasonEnum_notBoardable;
  @BuiltValueEnumConst(wireName: r'forbidden')
  static const BoardingBoardPost200ResponseReasonEnum forbidden = _$boardingBoardPost200ResponseReasonEnum_forbidden;

  static Serializer<BoardingBoardPost200ResponseReasonEnum> get serializer => _$boardingBoardPost200ResponseReasonEnumSerializer;

  const BoardingBoardPost200ResponseReasonEnum._(String name): super(name);

  static BuiltSet<BoardingBoardPost200ResponseReasonEnum> get values => _$boardingBoardPost200ResponseReasonEnumValues;
  static BoardingBoardPost200ResponseReasonEnum valueOf(String name) => _$boardingBoardPost200ResponseReasonEnumValueOf(name);
}


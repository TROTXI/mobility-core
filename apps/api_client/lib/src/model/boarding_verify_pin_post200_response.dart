//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'boarding_verify_pin_post200_response.g.dart';

/// BoardingVerifyPinPost200Response
///
/// Properties:
/// * [valid] 
/// * [riderId] 
/// * [reason] 
/// * [deducted] 
@BuiltValue()
abstract class BoardingVerifyPinPost200Response implements Built<BoardingVerifyPinPost200Response, BoardingVerifyPinPost200ResponseBuilder> {
  @BuiltValueField(wireName: r'valid')
  bool get valid;

  @BuiltValueField(wireName: r'riderId')
  String? get riderId;

  @BuiltValueField(wireName: r'reason')
  BoardingVerifyPinPost200ResponseReasonEnum get reason;
  // enum reasonEnum {  ok,  invalid,  not_found,  already_boarded,  };

  @BuiltValueField(wireName: r'deducted')
  bool get deducted;

  BoardingVerifyPinPost200Response._();

  factory BoardingVerifyPinPost200Response([void updates(BoardingVerifyPinPost200ResponseBuilder b)]) = _$BoardingVerifyPinPost200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BoardingVerifyPinPost200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BoardingVerifyPinPost200Response> get serializer => _$BoardingVerifyPinPost200ResponseSerializer();
}

class _$BoardingVerifyPinPost200ResponseSerializer implements PrimitiveSerializer<BoardingVerifyPinPost200Response> {
  @override
  final Iterable<Type> types = const [BoardingVerifyPinPost200Response, _$BoardingVerifyPinPost200Response];

  @override
  final String wireName = r'BoardingVerifyPinPost200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BoardingVerifyPinPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'valid';
    yield serializers.serialize(
      object.valid,
      specifiedType: const FullType(bool),
    );
    yield r'riderId';
    yield object.riderId == null ? null : serializers.serialize(
      object.riderId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(BoardingVerifyPinPost200ResponseReasonEnum),
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
    BoardingVerifyPinPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BoardingVerifyPinPost200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'valid':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.valid = valueDes;
          break;
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
            specifiedType: const FullType(BoardingVerifyPinPost200ResponseReasonEnum),
          ) as BoardingVerifyPinPost200ResponseReasonEnum;
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
  BoardingVerifyPinPost200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BoardingVerifyPinPost200ResponseBuilder();
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

class BoardingVerifyPinPost200ResponseReasonEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ok')
  static const BoardingVerifyPinPost200ResponseReasonEnum ok = _$boardingVerifyPinPost200ResponseReasonEnum_ok;
  @BuiltValueEnumConst(wireName: r'invalid')
  static const BoardingVerifyPinPost200ResponseReasonEnum invalid = _$boardingVerifyPinPost200ResponseReasonEnum_invalid;
  @BuiltValueEnumConst(wireName: r'not_found')
  static const BoardingVerifyPinPost200ResponseReasonEnum notFound = _$boardingVerifyPinPost200ResponseReasonEnum_notFound;
  @BuiltValueEnumConst(wireName: r'already_boarded')
  static const BoardingVerifyPinPost200ResponseReasonEnum alreadyBoarded = _$boardingVerifyPinPost200ResponseReasonEnum_alreadyBoarded;

  static Serializer<BoardingVerifyPinPost200ResponseReasonEnum> get serializer => _$boardingVerifyPinPost200ResponseReasonEnumSerializer;

  const BoardingVerifyPinPost200ResponseReasonEnum._(String name): super(name);

  static BuiltSet<BoardingVerifyPinPost200ResponseReasonEnum> get values => _$boardingVerifyPinPost200ResponseReasonEnumValues;
  static BoardingVerifyPinPost200ResponseReasonEnum valueOf(String name) => _$boardingVerifyPinPost200ResponseReasonEnumValueOf(name);
}


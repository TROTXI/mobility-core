//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'boarding_verify_code_post200_response.g.dart';

/// BoardingVerifyCodePost200Response
///
/// Properties:
/// * [riderId] 
/// * [reason] 
/// * [deducted] 
@BuiltValue()
abstract class BoardingVerifyCodePost200Response implements Built<BoardingVerifyCodePost200Response, BoardingVerifyCodePost200ResponseBuilder> {
  @BuiltValueField(wireName: r'riderId')
  String? get riderId;

  @BuiltValueField(wireName: r'reason')
  BoardingVerifyCodePost200ResponseReasonEnum get reason;
  // enum reasonEnum {  ok,  invalid,  already_boarded,  ambiguous,  forbidden,  not_found,  };

  @BuiltValueField(wireName: r'deducted')
  bool get deducted;

  BoardingVerifyCodePost200Response._();

  factory BoardingVerifyCodePost200Response([void updates(BoardingVerifyCodePost200ResponseBuilder b)]) = _$BoardingVerifyCodePost200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BoardingVerifyCodePost200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BoardingVerifyCodePost200Response> get serializer => _$BoardingVerifyCodePost200ResponseSerializer();
}

class _$BoardingVerifyCodePost200ResponseSerializer implements PrimitiveSerializer<BoardingVerifyCodePost200Response> {
  @override
  final Iterable<Type> types = const [BoardingVerifyCodePost200Response, _$BoardingVerifyCodePost200Response];

  @override
  final String wireName = r'BoardingVerifyCodePost200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BoardingVerifyCodePost200Response object, {
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
      specifiedType: const FullType(BoardingVerifyCodePost200ResponseReasonEnum),
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
    BoardingVerifyCodePost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BoardingVerifyCodePost200ResponseBuilder result,
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
            specifiedType: const FullType(BoardingVerifyCodePost200ResponseReasonEnum),
          ) as BoardingVerifyCodePost200ResponseReasonEnum;
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
  BoardingVerifyCodePost200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BoardingVerifyCodePost200ResponseBuilder();
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

class BoardingVerifyCodePost200ResponseReasonEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ok')
  static const BoardingVerifyCodePost200ResponseReasonEnum ok = _$boardingVerifyCodePost200ResponseReasonEnum_ok;
  @BuiltValueEnumConst(wireName: r'invalid')
  static const BoardingVerifyCodePost200ResponseReasonEnum invalid = _$boardingVerifyCodePost200ResponseReasonEnum_invalid;
  @BuiltValueEnumConst(wireName: r'already_boarded')
  static const BoardingVerifyCodePost200ResponseReasonEnum alreadyBoarded = _$boardingVerifyCodePost200ResponseReasonEnum_alreadyBoarded;
  @BuiltValueEnumConst(wireName: r'ambiguous')
  static const BoardingVerifyCodePost200ResponseReasonEnum ambiguous = _$boardingVerifyCodePost200ResponseReasonEnum_ambiguous;
  @BuiltValueEnumConst(wireName: r'forbidden')
  static const BoardingVerifyCodePost200ResponseReasonEnum forbidden = _$boardingVerifyCodePost200ResponseReasonEnum_forbidden;
  @BuiltValueEnumConst(wireName: r'not_found')
  static const BoardingVerifyCodePost200ResponseReasonEnum notFound = _$boardingVerifyCodePost200ResponseReasonEnum_notFound;

  static Serializer<BoardingVerifyCodePost200ResponseReasonEnum> get serializer => _$boardingVerifyCodePost200ResponseReasonEnumSerializer;

  const BoardingVerifyCodePost200ResponseReasonEnum._(String name): super(name);

  static BuiltSet<BoardingVerifyCodePost200ResponseReasonEnum> get values => _$boardingVerifyCodePost200ResponseReasonEnumValues;
  static BoardingVerifyCodePost200ResponseReasonEnum valueOf(String name) => _$boardingVerifyCodePost200ResponseReasonEnumValueOf(name);
}


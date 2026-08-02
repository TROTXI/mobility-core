//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'boarding_scan_post200_response.g.dart';

/// BoardingScanPost200Response
///
/// Properties:
/// * [valid] 
/// * [riderId] 
/// * [reason] 
/// * [deducted] 
@BuiltValue()
abstract class BoardingScanPost200Response implements Built<BoardingScanPost200Response, BoardingScanPost200ResponseBuilder> {
  @BuiltValueField(wireName: r'valid')
  bool get valid;

  @BuiltValueField(wireName: r'riderId')
  String? get riderId;

  @BuiltValueField(wireName: r'reason')
  BoardingScanPost200ResponseReasonEnum get reason;
  // enum reasonEnum {  ok,  invalid,  expired,  reused,  };

  @BuiltValueField(wireName: r'deducted')
  bool get deducted;

  BoardingScanPost200Response._();

  factory BoardingScanPost200Response([void updates(BoardingScanPost200ResponseBuilder b)]) = _$BoardingScanPost200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BoardingScanPost200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BoardingScanPost200Response> get serializer => _$BoardingScanPost200ResponseSerializer();
}

class _$BoardingScanPost200ResponseSerializer implements PrimitiveSerializer<BoardingScanPost200Response> {
  @override
  final Iterable<Type> types = const [BoardingScanPost200Response, _$BoardingScanPost200Response];

  @override
  final String wireName = r'BoardingScanPost200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BoardingScanPost200Response object, {
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
      specifiedType: const FullType(BoardingScanPost200ResponseReasonEnum),
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
    BoardingScanPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BoardingScanPost200ResponseBuilder result,
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
            specifiedType: const FullType(BoardingScanPost200ResponseReasonEnum),
          ) as BoardingScanPost200ResponseReasonEnum;
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
  BoardingScanPost200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BoardingScanPost200ResponseBuilder();
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

class BoardingScanPost200ResponseReasonEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ok')
  static const BoardingScanPost200ResponseReasonEnum ok = _$boardingScanPost200ResponseReasonEnum_ok;
  @BuiltValueEnumConst(wireName: r'invalid')
  static const BoardingScanPost200ResponseReasonEnum invalid = _$boardingScanPost200ResponseReasonEnum_invalid;
  @BuiltValueEnumConst(wireName: r'expired')
  static const BoardingScanPost200ResponseReasonEnum expired = _$boardingScanPost200ResponseReasonEnum_expired;
  @BuiltValueEnumConst(wireName: r'reused')
  static const BoardingScanPost200ResponseReasonEnum reused = _$boardingScanPost200ResponseReasonEnum_reused;

  static Serializer<BoardingScanPost200ResponseReasonEnum> get serializer => _$boardingScanPost200ResponseReasonEnumSerializer;

  const BoardingScanPost200ResponseReasonEnum._(String name): super(name);

  static BuiltSet<BoardingScanPost200ResponseReasonEnum> get values => _$boardingScanPost200ResponseReasonEnumValues;
  static BoardingScanPost200ResponseReasonEnum valueOf(String name) => _$boardingScanPost200ResponseReasonEnumValueOf(name);
}


//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'boarding_no_show_post200_response.g.dart';

/// BoardingNoShowPost200Response
///
/// Properties:
/// * [riderId] 
/// * [reason] 
/// * [deducted] 
@BuiltValue()
abstract class BoardingNoShowPost200Response implements Built<BoardingNoShowPost200Response, BoardingNoShowPost200ResponseBuilder> {
  @BuiltValueField(wireName: r'riderId')
  String? get riderId;

  @BuiltValueField(wireName: r'reason')
  BoardingNoShowPost200ResponseReasonEnum get reason;
  // enum reasonEnum {  ok,  not_found,  already_boarded,  already_no_show,  not_boardable,  forbidden,  };

  @BuiltValueField(wireName: r'deducted')
  bool get deducted;

  BoardingNoShowPost200Response._();

  factory BoardingNoShowPost200Response([void updates(BoardingNoShowPost200ResponseBuilder b)]) = _$BoardingNoShowPost200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BoardingNoShowPost200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BoardingNoShowPost200Response> get serializer => _$BoardingNoShowPost200ResponseSerializer();
}

class _$BoardingNoShowPost200ResponseSerializer implements PrimitiveSerializer<BoardingNoShowPost200Response> {
  @override
  final Iterable<Type> types = const [BoardingNoShowPost200Response, _$BoardingNoShowPost200Response];

  @override
  final String wireName = r'BoardingNoShowPost200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BoardingNoShowPost200Response object, {
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
      specifiedType: const FullType(BoardingNoShowPost200ResponseReasonEnum),
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
    BoardingNoShowPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BoardingNoShowPost200ResponseBuilder result,
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
            specifiedType: const FullType(BoardingNoShowPost200ResponseReasonEnum),
          ) as BoardingNoShowPost200ResponseReasonEnum;
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
  BoardingNoShowPost200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BoardingNoShowPost200ResponseBuilder();
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

class BoardingNoShowPost200ResponseReasonEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ok')
  static const BoardingNoShowPost200ResponseReasonEnum ok = _$boardingNoShowPost200ResponseReasonEnum_ok;
  @BuiltValueEnumConst(wireName: r'not_found')
  static const BoardingNoShowPost200ResponseReasonEnum notFound = _$boardingNoShowPost200ResponseReasonEnum_notFound;
  @BuiltValueEnumConst(wireName: r'already_boarded')
  static const BoardingNoShowPost200ResponseReasonEnum alreadyBoarded = _$boardingNoShowPost200ResponseReasonEnum_alreadyBoarded;
  @BuiltValueEnumConst(wireName: r'already_no_show')
  static const BoardingNoShowPost200ResponseReasonEnum alreadyNoShow = _$boardingNoShowPost200ResponseReasonEnum_alreadyNoShow;
  @BuiltValueEnumConst(wireName: r'not_boardable')
  static const BoardingNoShowPost200ResponseReasonEnum notBoardable = _$boardingNoShowPost200ResponseReasonEnum_notBoardable;
  @BuiltValueEnumConst(wireName: r'forbidden')
  static const BoardingNoShowPost200ResponseReasonEnum forbidden = _$boardingNoShowPost200ResponseReasonEnum_forbidden;

  static Serializer<BoardingNoShowPost200ResponseReasonEnum> get serializer => _$boardingNoShowPost200ResponseReasonEnumSerializer;

  const BoardingNoShowPost200ResponseReasonEnum._(String name): super(name);

  static BuiltSet<BoardingNoShowPost200ResponseReasonEnum> get values => _$boardingNoShowPost200ResponseReasonEnumValues;
  static BoardingNoShowPost200ResponseReasonEnum valueOf(String name) => _$boardingNoShowPost200ResponseReasonEnumValueOf(name);
}


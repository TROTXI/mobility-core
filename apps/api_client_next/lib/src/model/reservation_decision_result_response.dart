//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/reservation_decision_result.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reservation_decision_result_response.g.dart';

/// ReservationDecisionResultResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class ReservationDecisionResultResponse implements Built<ReservationDecisionResultResponse, ReservationDecisionResultResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  ReservationDecisionResult get data;

  ReservationDecisionResultResponse._();

  factory ReservationDecisionResultResponse([void updates(ReservationDecisionResultResponseBuilder b)]) = _$ReservationDecisionResultResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReservationDecisionResultResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReservationDecisionResultResponse> get serializer => _$ReservationDecisionResultResponseSerializer();
}

class _$ReservationDecisionResultResponseSerializer implements PrimitiveSerializer<ReservationDecisionResultResponse> {
  @override
  final Iterable<Type> types = const [ReservationDecisionResultResponse, _$ReservationDecisionResultResponse];

  @override
  final String wireName = r'ReservationDecisionResultResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReservationDecisionResultResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(ReservationDecisionResult),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReservationDecisionResultResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReservationDecisionResultResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ReservationDecisionResult),
          ) as ReservationDecisionResult;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReservationDecisionResultResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReservationDecisionResultResponseBuilder();
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


//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/reservation_detail.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reservation_detail_response.g.dart';

/// ReservationDetailResponse
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class ReservationDetailResponse
    implements
        Built<ReservationDetailResponse, ReservationDetailResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  ReservationDetail get data;

  ReservationDetailResponse._();

  factory ReservationDetailResponse(
          [void updates(ReservationDetailResponseBuilder b)]) =
      _$ReservationDetailResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReservationDetailResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReservationDetailResponse> get serializer =>
      _$ReservationDetailResponseSerializer();
}

class _$ReservationDetailResponseSerializer
    implements PrimitiveSerializer<ReservationDetailResponse> {
  @override
  final Iterable<Type> types = const [
    ReservationDetailResponse,
    _$ReservationDetailResponse
  ];

  @override
  final String wireName = r'ReservationDetailResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReservationDetailResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(ReservationDetail),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReservationDetailResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReservationDetailResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ReservationDetail),
          ) as ReservationDetail;
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
  ReservationDetailResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReservationDetailResponseBuilder();
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

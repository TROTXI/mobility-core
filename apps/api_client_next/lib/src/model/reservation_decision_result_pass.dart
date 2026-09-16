//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reservation_decision_result_pass.g.dart';

/// ReservationDecisionResultPass
///
/// Properties:
/// * [reservationId] 
/// * [tripId] 
/// * [qrToken] 
/// * [expiresAt] 
/// * [boardingCode] 
@BuiltValue()
abstract class ReservationDecisionResultPass implements Built<ReservationDecisionResultPass, ReservationDecisionResultPassBuilder> {
  @BuiltValueField(wireName: r'reservationId')
  String get reservationId;

  @BuiltValueField(wireName: r'tripId')
  String get tripId;

  @BuiltValueField(wireName: r'qrToken')
  String get qrToken;

  @BuiltValueField(wireName: r'expiresAt')
  DateTime get expiresAt;

  @BuiltValueField(wireName: r'boardingCode')
  String get boardingCode;

  ReservationDecisionResultPass._();

  factory ReservationDecisionResultPass([void updates(ReservationDecisionResultPassBuilder b)]) = _$ReservationDecisionResultPass;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReservationDecisionResultPassBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReservationDecisionResultPass> get serializer => _$ReservationDecisionResultPassSerializer();
}

class _$ReservationDecisionResultPassSerializer implements PrimitiveSerializer<ReservationDecisionResultPass> {
  @override
  final Iterable<Type> types = const [ReservationDecisionResultPass, _$ReservationDecisionResultPass];

  @override
  final String wireName = r'ReservationDecisionResultPass';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReservationDecisionResultPass object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'reservationId';
    yield serializers.serialize(
      object.reservationId,
      specifiedType: const FullType(String),
    );
    yield r'tripId';
    yield serializers.serialize(
      object.tripId,
      specifiedType: const FullType(String),
    );
    yield r'qrToken';
    yield serializers.serialize(
      object.qrToken,
      specifiedType: const FullType(String),
    );
    yield r'expiresAt';
    yield serializers.serialize(
      object.expiresAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'boardingCode';
    yield serializers.serialize(
      object.boardingCode,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReservationDecisionResultPass object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReservationDecisionResultPassBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'reservationId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reservationId = valueDes;
          break;
        case r'tripId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.tripId = valueDes;
          break;
        case r'qrToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.qrToken = valueDes;
          break;
        case r'expiresAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.expiresAt = valueDes;
          break;
        case r'boardingCode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.boardingCode = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReservationDecisionResultPass deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReservationDecisionResultPassBuilder();
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


//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/reservation_decision_result_pass.dart';
import 'package:trotxi_api_client/src/model/reservation.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reservation_decision_result.g.dart';

/// ReservationDecisionResult
///
/// Properties:
<<<<<<< HEAD
/// * [reservation] 
/// * [pass] 
@BuiltValue()
abstract class ReservationDecisionResult implements Built<ReservationDecisionResult, ReservationDecisionResultBuilder> {
=======
/// * [reservation]
/// * [pass]
@BuiltValue()
abstract class ReservationDecisionResult
    implements
        Built<ReservationDecisionResult, ReservationDecisionResultBuilder> {
>>>>>>> origin/main
  @BuiltValueField(wireName: r'reservation')
  Reservation get reservation;

  @BuiltValueField(wireName: r'pass')
  ReservationDecisionResultPass? get pass;

  ReservationDecisionResult._();

<<<<<<< HEAD
  factory ReservationDecisionResult([void updates(ReservationDecisionResultBuilder b)]) = _$ReservationDecisionResult;
=======
  factory ReservationDecisionResult(
          [void updates(ReservationDecisionResultBuilder b)]) =
      _$ReservationDecisionResult;
>>>>>>> origin/main

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReservationDecisionResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
<<<<<<< HEAD
  static Serializer<ReservationDecisionResult> get serializer => _$ReservationDecisionResultSerializer();
}

class _$ReservationDecisionResultSerializer implements PrimitiveSerializer<ReservationDecisionResult> {
  @override
  final Iterable<Type> types = const [ReservationDecisionResult, _$ReservationDecisionResult];
=======
  static Serializer<ReservationDecisionResult> get serializer =>
      _$ReservationDecisionResultSerializer();
}

class _$ReservationDecisionResultSerializer
    implements PrimitiveSerializer<ReservationDecisionResult> {
  @override
  final Iterable<Type> types = const [
    ReservationDecisionResult,
    _$ReservationDecisionResult
  ];
>>>>>>> origin/main

  @override
  final String wireName = r'ReservationDecisionResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReservationDecisionResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'reservation';
    yield serializers.serialize(
      object.reservation,
      specifiedType: const FullType(Reservation),
    );
    yield r'pass';
<<<<<<< HEAD
    yield object.pass == null ? null : serializers.serialize(
      object.pass,
      specifiedType: const FullType.nullable(ReservationDecisionResultPass),
    );
=======
    yield object.pass == null
        ? null
        : serializers.serialize(
            object.pass,
            specifiedType:
                const FullType.nullable(ReservationDecisionResultPass),
          );
>>>>>>> origin/main
  }

  @override
  Object serialize(
    Serializers serializers,
    ReservationDecisionResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
<<<<<<< HEAD
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
=======
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
>>>>>>> origin/main
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReservationDecisionResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'reservation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Reservation),
          ) as Reservation;
          result.reservation.replace(valueDes);
          break;
        case r'pass':
          final valueDes = serializers.deserialize(
            value,
<<<<<<< HEAD
            specifiedType: const FullType.nullable(ReservationDecisionResultPass),
=======
            specifiedType:
                const FullType.nullable(ReservationDecisionResultPass),
>>>>>>> origin/main
          ) as ReservationDecisionResultPass?;
          if (valueDes == null) continue;
          result.pass.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReservationDecisionResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReservationDecisionResultBuilder();
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
<<<<<<< HEAD

=======
>>>>>>> origin/main

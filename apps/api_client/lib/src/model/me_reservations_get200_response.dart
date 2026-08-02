//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/me_reservations_get200_response_reservations_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'me_reservations_get200_response.g.dart';

/// MeReservationsGet200Response
///
/// Properties:
/// * [reservations] 
@BuiltValue()
abstract class MeReservationsGet200Response implements Built<MeReservationsGet200Response, MeReservationsGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'reservations')
  BuiltList<MeReservationsGet200ResponseReservationsInner> get reservations;

  MeReservationsGet200Response._();

  factory MeReservationsGet200Response([void updates(MeReservationsGet200ResponseBuilder b)]) = _$MeReservationsGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MeReservationsGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MeReservationsGet200Response> get serializer => _$MeReservationsGet200ResponseSerializer();
}

class _$MeReservationsGet200ResponseSerializer implements PrimitiveSerializer<MeReservationsGet200Response> {
  @override
  final Iterable<Type> types = const [MeReservationsGet200Response, _$MeReservationsGet200Response];

  @override
  final String wireName = r'MeReservationsGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MeReservationsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'reservations';
    yield serializers.serialize(
      object.reservations,
      specifiedType: const FullType(BuiltList, [FullType(MeReservationsGet200ResponseReservationsInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MeReservationsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MeReservationsGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'reservations':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(MeReservationsGet200ResponseReservationsInner)]),
          ) as BuiltList<MeReservationsGet200ResponseReservationsInner>;
          result.reservations.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MeReservationsGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MeReservationsGet200ResponseBuilder();
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


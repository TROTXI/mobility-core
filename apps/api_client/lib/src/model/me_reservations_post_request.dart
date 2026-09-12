//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'me_reservations_post_request.g.dart';

/// MeReservationsPostRequest
///
/// Properties:
/// * [tripId] 
/// * [travelDate] 
/// * [direction] 
/// * [travelling] 
@BuiltValue()
abstract class MeReservationsPostRequest implements Built<MeReservationsPostRequest, MeReservationsPostRequestBuilder> {
  @BuiltValueField(wireName: r'tripId')
  String? get tripId;

  @BuiltValueField(wireName: r'travelDate')
  String get travelDate;

  @BuiltValueField(wireName: r'direction')
  MeReservationsPostRequestDirectionEnum get direction;
  // enum directionEnum {  morning,  evening,  };

  @BuiltValueField(wireName: r'travelling')
  bool get travelling;

  MeReservationsPostRequest._();

  factory MeReservationsPostRequest([void updates(MeReservationsPostRequestBuilder b)]) = _$MeReservationsPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MeReservationsPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MeReservationsPostRequest> get serializer => _$MeReservationsPostRequestSerializer();
}

class _$MeReservationsPostRequestSerializer implements PrimitiveSerializer<MeReservationsPostRequest> {
  @override
  final Iterable<Type> types = const [MeReservationsPostRequest, _$MeReservationsPostRequest];

  @override
  final String wireName = r'MeReservationsPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MeReservationsPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.tripId != null) {
      yield r'tripId';
      yield serializers.serialize(
        object.tripId,
        specifiedType: const FullType(String),
      );
    }
    yield r'travelDate';
    yield serializers.serialize(
      object.travelDate,
      specifiedType: const FullType(String),
    );
    yield r'direction';
    yield serializers.serialize(
      object.direction,
      specifiedType: const FullType(MeReservationsPostRequestDirectionEnum),
    );
    yield r'travelling';
    yield serializers.serialize(
      object.travelling,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MeReservationsPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MeReservationsPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'tripId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.tripId = valueDes;
          break;
        case r'travelDate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.travelDate = valueDes;
          break;
        case r'direction':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MeReservationsPostRequestDirectionEnum),
          ) as MeReservationsPostRequestDirectionEnum;
          result.direction = valueDes;
          break;
        case r'travelling':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.travelling = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MeReservationsPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MeReservationsPostRequestBuilder();
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

class MeReservationsPostRequestDirectionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'morning')
  static const MeReservationsPostRequestDirectionEnum morning = _$meReservationsPostRequestDirectionEnum_morning;
  @BuiltValueEnumConst(wireName: r'evening')
  static const MeReservationsPostRequestDirectionEnum evening = _$meReservationsPostRequestDirectionEnum_evening;

  static Serializer<MeReservationsPostRequestDirectionEnum> get serializer => _$meReservationsPostRequestDirectionEnumSerializer;

  const MeReservationsPostRequestDirectionEnum._(String name): super(name);

  static BuiltSet<MeReservationsPostRequestDirectionEnum> get values => _$meReservationsPostRequestDirectionEnumValues;
  static MeReservationsPostRequestDirectionEnum valueOf(String name) => _$meReservationsPostRequestDirectionEnumValueOf(name);
}


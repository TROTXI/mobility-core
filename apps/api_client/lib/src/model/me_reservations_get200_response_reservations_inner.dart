//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'me_reservations_get200_response_reservations_inner.g.dart';

/// MeReservationsGet200ResponseReservationsInner
///
/// Properties:
/// * [id] 
/// * [tripId] 
/// * [travelDate] 
/// * [direction] 
/// * [status] 
/// * [source_] 
/// * [pin] 
@BuiltValue()
abstract class MeReservationsGet200ResponseReservationsInner implements Built<MeReservationsGet200ResponseReservationsInner, MeReservationsGet200ResponseReservationsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'tripId')
  String? get tripId;

  @BuiltValueField(wireName: r'travelDate')
  String get travelDate;

  @BuiltValueField(wireName: r'direction')
  MeReservationsGet200ResponseReservationsInnerDirectionEnum get direction;
  // enum directionEnum {  morning,  evening,  };

  @BuiltValueField(wireName: r'status')
  MeReservationsGet200ResponseReservationsInnerStatusEnum get status;
  // enum statusEnum {  pending,  reserved,  declined,  boarded,  no_show,  released,  operator_cancelled,  };

  @BuiltValueField(wireName: r'source')
  MeReservationsGet200ResponseReservationsInnerSource_Enum get source_;
  // enum source_Enum {  confirmation,  default,  standby,  };

  @BuiltValueField(wireName: r'pin')
  String? get pin;

  MeReservationsGet200ResponseReservationsInner._();

  factory MeReservationsGet200ResponseReservationsInner([void updates(MeReservationsGet200ResponseReservationsInnerBuilder b)]) = _$MeReservationsGet200ResponseReservationsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MeReservationsGet200ResponseReservationsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MeReservationsGet200ResponseReservationsInner> get serializer => _$MeReservationsGet200ResponseReservationsInnerSerializer();
}

class _$MeReservationsGet200ResponseReservationsInnerSerializer implements PrimitiveSerializer<MeReservationsGet200ResponseReservationsInner> {
  @override
  final Iterable<Type> types = const [MeReservationsGet200ResponseReservationsInner, _$MeReservationsGet200ResponseReservationsInner];

  @override
  final String wireName = r'MeReservationsGet200ResponseReservationsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MeReservationsGet200ResponseReservationsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'tripId';
    yield object.tripId == null ? null : serializers.serialize(
      object.tripId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'travelDate';
    yield serializers.serialize(
      object.travelDate,
      specifiedType: const FullType(String),
    );
    yield r'direction';
    yield serializers.serialize(
      object.direction,
      specifiedType: const FullType(MeReservationsGet200ResponseReservationsInnerDirectionEnum),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(MeReservationsGet200ResponseReservationsInnerStatusEnum),
    );
    yield r'source';
    yield serializers.serialize(
      object.source_,
      specifiedType: const FullType(MeReservationsGet200ResponseReservationsInnerSource_Enum),
    );
    if (object.pin != null) {
      yield r'pin';
      yield serializers.serialize(
        object.pin,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    MeReservationsGet200ResponseReservationsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MeReservationsGet200ResponseReservationsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'tripId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
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
            specifiedType: const FullType(MeReservationsGet200ResponseReservationsInnerDirectionEnum),
          ) as MeReservationsGet200ResponseReservationsInnerDirectionEnum;
          result.direction = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MeReservationsGet200ResponseReservationsInnerStatusEnum),
          ) as MeReservationsGet200ResponseReservationsInnerStatusEnum;
          result.status = valueDes;
          break;
        case r'source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MeReservationsGet200ResponseReservationsInnerSource_Enum),
          ) as MeReservationsGet200ResponseReservationsInnerSource_Enum;
          result.source_ = valueDes;
          break;
        case r'pin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.pin = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MeReservationsGet200ResponseReservationsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MeReservationsGet200ResponseReservationsInnerBuilder();
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

class MeReservationsGet200ResponseReservationsInnerDirectionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'morning')
  static const MeReservationsGet200ResponseReservationsInnerDirectionEnum morning = _$meReservationsGet200ResponseReservationsInnerDirectionEnum_morning;
  @BuiltValueEnumConst(wireName: r'evening')
  static const MeReservationsGet200ResponseReservationsInnerDirectionEnum evening = _$meReservationsGet200ResponseReservationsInnerDirectionEnum_evening;

  static Serializer<MeReservationsGet200ResponseReservationsInnerDirectionEnum> get serializer => _$meReservationsGet200ResponseReservationsInnerDirectionEnumSerializer;

  const MeReservationsGet200ResponseReservationsInnerDirectionEnum._(String name): super(name);

  static BuiltSet<MeReservationsGet200ResponseReservationsInnerDirectionEnum> get values => _$meReservationsGet200ResponseReservationsInnerDirectionEnumValues;
  static MeReservationsGet200ResponseReservationsInnerDirectionEnum valueOf(String name) => _$meReservationsGet200ResponseReservationsInnerDirectionEnumValueOf(name);
}

class MeReservationsGet200ResponseReservationsInnerStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'pending')
  static const MeReservationsGet200ResponseReservationsInnerStatusEnum pending = _$meReservationsGet200ResponseReservationsInnerStatusEnum_pending;
  @BuiltValueEnumConst(wireName: r'reserved')
  static const MeReservationsGet200ResponseReservationsInnerStatusEnum reserved = _$meReservationsGet200ResponseReservationsInnerStatusEnum_reserved;
  @BuiltValueEnumConst(wireName: r'declined')
  static const MeReservationsGet200ResponseReservationsInnerStatusEnum declined = _$meReservationsGet200ResponseReservationsInnerStatusEnum_declined;
  @BuiltValueEnumConst(wireName: r'boarded')
  static const MeReservationsGet200ResponseReservationsInnerStatusEnum boarded = _$meReservationsGet200ResponseReservationsInnerStatusEnum_boarded;
  @BuiltValueEnumConst(wireName: r'no_show')
  static const MeReservationsGet200ResponseReservationsInnerStatusEnum noShow = _$meReservationsGet200ResponseReservationsInnerStatusEnum_noShow;
  @BuiltValueEnumConst(wireName: r'released')
  static const MeReservationsGet200ResponseReservationsInnerStatusEnum released = _$meReservationsGet200ResponseReservationsInnerStatusEnum_released;
  @BuiltValueEnumConst(wireName: r'operator_cancelled')
  static const MeReservationsGet200ResponseReservationsInnerStatusEnum operatorCancelled = _$meReservationsGet200ResponseReservationsInnerStatusEnum_operatorCancelled;

  static Serializer<MeReservationsGet200ResponseReservationsInnerStatusEnum> get serializer => _$meReservationsGet200ResponseReservationsInnerStatusEnumSerializer;

  const MeReservationsGet200ResponseReservationsInnerStatusEnum._(String name): super(name);

  static BuiltSet<MeReservationsGet200ResponseReservationsInnerStatusEnum> get values => _$meReservationsGet200ResponseReservationsInnerStatusEnumValues;
  static MeReservationsGet200ResponseReservationsInnerStatusEnum valueOf(String name) => _$meReservationsGet200ResponseReservationsInnerStatusEnumValueOf(name);
}

class MeReservationsGet200ResponseReservationsInnerSource_Enum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'confirmation')
  static const MeReservationsGet200ResponseReservationsInnerSource_Enum confirmation = _$meReservationsGet200ResponseReservationsInnerSourceEnum_confirmation;
  @BuiltValueEnumConst(wireName: r'default')
  static const MeReservationsGet200ResponseReservationsInnerSource_Enum default_ = _$meReservationsGet200ResponseReservationsInnerSourceEnum_default_;
  @BuiltValueEnumConst(wireName: r'standby')
  static const MeReservationsGet200ResponseReservationsInnerSource_Enum standby = _$meReservationsGet200ResponseReservationsInnerSourceEnum_standby;

  static Serializer<MeReservationsGet200ResponseReservationsInnerSource_Enum> get serializer => _$meReservationsGet200ResponseReservationsInnerSourceEnumSerializer;

  const MeReservationsGet200ResponseReservationsInnerSource_Enum._(String name): super(name);

  static BuiltSet<MeReservationsGet200ResponseReservationsInnerSource_Enum> get values => _$meReservationsGet200ResponseReservationsInnerSourceEnumValues;
  static MeReservationsGet200ResponseReservationsInnerSource_Enum valueOf(String name) => _$meReservationsGet200ResponseReservationsInnerSourceEnumValueOf(name);
}


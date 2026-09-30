//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/rider_notification_target.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'rider_notification.g.dart';

/// RiderNotification
///
/// Properties:
/// * [id]
/// * [kind]
/// * [target]
/// * [createdAt]
/// * [readAt]
@BuiltValue()
abstract class RiderNotification
    implements Built<RiderNotification, RiderNotificationBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'kind')
  RiderNotificationKindEnum get kind;
  // enum kindEnum {  seat_ask,  seat_held,  seat_unseated,  ride_used,  credit_converted,  trip_changed,  trip_cancelled,  };

  @BuiltValueField(wireName: r'target')
  RiderNotificationTarget get target;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'readAt')
  DateTime? get readAt;

  RiderNotification._();

  factory RiderNotification([void updates(RiderNotificationBuilder b)]) =
      _$RiderNotification;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RiderNotificationBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RiderNotification> get serializer =>
      _$RiderNotificationSerializer();
}

class _$RiderNotificationSerializer
    implements PrimitiveSerializer<RiderNotification> {
  @override
  final Iterable<Type> types = const [RiderNotification, _$RiderNotification];

  @override
  final String wireName = r'RiderNotification';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RiderNotification object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(RiderNotificationKindEnum),
    );
    yield r'target';
    yield serializers.serialize(
      object.target,
      specifiedType: const FullType(RiderNotificationTarget),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'readAt';
    yield object.readAt == null
        ? null
        : serializers.serialize(
            object.readAt,
            specifiedType: const FullType.nullable(DateTime),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    RiderNotification object, {
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
    required RiderNotificationBuilder result,
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
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RiderNotificationKindEnum),
          ) as RiderNotificationKindEnum;
          result.kind = valueDes;
          break;
        case r'target':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RiderNotificationTarget),
          ) as RiderNotificationTarget;
          result.target.replace(valueDes);
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'readAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.readAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RiderNotification deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RiderNotificationBuilder();
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

class RiderNotificationKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'seat_ask')
  static const RiderNotificationKindEnum seatAsk =
      _$riderNotificationKindEnum_seatAsk;
  @BuiltValueEnumConst(wireName: r'seat_held')
  static const RiderNotificationKindEnum seatHeld =
      _$riderNotificationKindEnum_seatHeld;
  @BuiltValueEnumConst(wireName: r'seat_unseated')
  static const RiderNotificationKindEnum seatUnseated =
      _$riderNotificationKindEnum_seatUnseated;
  @BuiltValueEnumConst(wireName: r'ride_used')
  static const RiderNotificationKindEnum rideUsed =
      _$riderNotificationKindEnum_rideUsed;
  @BuiltValueEnumConst(wireName: r'credit_converted')
  static const RiderNotificationKindEnum creditConverted =
      _$riderNotificationKindEnum_creditConverted;
  @BuiltValueEnumConst(wireName: r'trip_changed')
  static const RiderNotificationKindEnum tripChanged =
      _$riderNotificationKindEnum_tripChanged;
  @BuiltValueEnumConst(wireName: r'trip_cancelled')
  static const RiderNotificationKindEnum tripCancelled =
      _$riderNotificationKindEnum_tripCancelled;

  static Serializer<RiderNotificationKindEnum> get serializer =>
      _$riderNotificationKindEnumSerializer;

  const RiderNotificationKindEnum._(String name) : super(name);

  static BuiltSet<RiderNotificationKindEnum> get values =>
      _$riderNotificationKindEnumValues;
  static RiderNotificationKindEnum valueOf(String name) =>
      _$riderNotificationKindEnumValueOf(name);
}

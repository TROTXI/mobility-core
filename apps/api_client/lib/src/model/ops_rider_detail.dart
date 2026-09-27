//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/ops_rider_detail_membership.dart';
import 'package:trotxi_api_client/src/model/ops_rider_detail_reservations_inner.dart';
import 'package:trotxi_api_client/src/model/ops_rider_detail_purchases_inner.dart';
import 'package:trotxi_api_client/src/model/ops_rider.dart';
import 'package:trotxi_api_client/src/model/restriction.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_rider_detail.g.dart';

/// OpsRiderDetail
///
/// Properties:
/// * [rider]
/// * [membership]
/// * [restrictions]
/// * [reservations]
/// * [purchases]
@BuiltValue()
abstract class OpsRiderDetail
    implements Built<OpsRiderDetail, OpsRiderDetailBuilder> {
  @BuiltValueField(wireName: r'rider')
  OpsRider get rider;

  @BuiltValueField(wireName: r'membership')
  OpsRiderDetailMembership? get membership;

  @BuiltValueField(wireName: r'restrictions')
  BuiltList<Restriction> get restrictions;

  @BuiltValueField(wireName: r'reservations')
  BuiltList<OpsRiderDetailReservationsInner> get reservations;

  @BuiltValueField(wireName: r'purchases')
  BuiltList<OpsRiderDetailPurchasesInner> get purchases;

  OpsRiderDetail._();

  factory OpsRiderDetail([void updates(OpsRiderDetailBuilder b)]) =
      _$OpsRiderDetail;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsRiderDetailBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsRiderDetail> get serializer =>
      _$OpsRiderDetailSerializer();
}

class _$OpsRiderDetailSerializer
    implements PrimitiveSerializer<OpsRiderDetail> {
  @override
  final Iterable<Type> types = const [OpsRiderDetail, _$OpsRiderDetail];

  @override
  final String wireName = r'OpsRiderDetail';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsRiderDetail object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'rider';
    yield serializers.serialize(
      object.rider,
      specifiedType: const FullType(OpsRider),
    );
    yield r'membership';
    yield object.membership == null
        ? null
        : serializers.serialize(
            object.membership,
            specifiedType: const FullType.nullable(OpsRiderDetailMembership),
          );
    yield r'restrictions';
    yield serializers.serialize(
      object.restrictions,
      specifiedType: const FullType(BuiltList, [FullType(Restriction)]),
    );
    yield r'reservations';
    yield serializers.serialize(
      object.reservations,
      specifiedType: const FullType(
          BuiltList, [FullType(OpsRiderDetailReservationsInner)]),
    );
    yield r'purchases';
    yield serializers.serialize(
      object.purchases,
      specifiedType:
          const FullType(BuiltList, [FullType(OpsRiderDetailPurchasesInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsRiderDetail object, {
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
    required OpsRiderDetailBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'rider':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OpsRider),
          ) as OpsRider;
          result.rider.replace(valueDes);
          break;
        case r'membership':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(OpsRiderDetailMembership),
          ) as OpsRiderDetailMembership?;
          if (valueDes == null) continue;
          result.membership.replace(valueDes);
          break;
        case r'restrictions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Restriction)]),
          ) as BuiltList<Restriction>;
          result.restrictions.replace(valueDes);
          break;
        case r'reservations':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltList, [FullType(OpsRiderDetailReservationsInner)]),
          ) as BuiltList<OpsRiderDetailReservationsInner>;
          result.reservations.replace(valueDes);
          break;
        case r'purchases':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltList, [FullType(OpsRiderDetailPurchasesInner)]),
          ) as BuiltList<OpsRiderDetailPurchasesInner>;
          result.purchases.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OpsRiderDetail deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsRiderDetailBuilder();
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

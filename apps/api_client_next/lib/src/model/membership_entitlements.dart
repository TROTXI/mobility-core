//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/money.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'membership_entitlements.g.dart';

/// MembershipEntitlements
///
/// Properties:
/// * [remainingRides] 
/// * [credit] 
/// * [heldCredit] 
/// * [availableCredit] 
@BuiltValue()
abstract class MembershipEntitlements implements Built<MembershipEntitlements, MembershipEntitlementsBuilder> {
  @BuiltValueField(wireName: r'remainingRides')
  int get remainingRides;

  @BuiltValueField(wireName: r'credit')
  Money get credit;

  @BuiltValueField(wireName: r'heldCredit')
  Money get heldCredit;

  @BuiltValueField(wireName: r'availableCredit')
  Money get availableCredit;

  MembershipEntitlements._();

  factory MembershipEntitlements([void updates(MembershipEntitlementsBuilder b)]) = _$MembershipEntitlements;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MembershipEntitlementsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MembershipEntitlements> get serializer => _$MembershipEntitlementsSerializer();
}

class _$MembershipEntitlementsSerializer implements PrimitiveSerializer<MembershipEntitlements> {
  @override
  final Iterable<Type> types = const [MembershipEntitlements, _$MembershipEntitlements];

  @override
  final String wireName = r'MembershipEntitlements';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MembershipEntitlements object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'remainingRides';
    yield serializers.serialize(
      object.remainingRides,
      specifiedType: const FullType(int),
    );
    yield r'credit';
    yield serializers.serialize(
      object.credit,
      specifiedType: const FullType(Money),
    );
    yield r'heldCredit';
    yield serializers.serialize(
      object.heldCredit,
      specifiedType: const FullType(Money),
    );
    yield r'availableCredit';
    yield serializers.serialize(
      object.availableCredit,
      specifiedType: const FullType(Money),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MembershipEntitlements object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MembershipEntitlementsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'remainingRides':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.remainingRides = valueDes;
          break;
        case r'credit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Money),
          ) as Money;
          result.credit.replace(valueDes);
          break;
        case r'heldCredit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Money),
          ) as Money;
          result.heldCredit.replace(valueDes);
          break;
        case r'availableCredit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Money),
          ) as Money;
          result.availableCredit.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MembershipEntitlements deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MembershipEntitlementsBuilder();
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


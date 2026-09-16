//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/membership_coverage.dart';
import 'package:trotxi_api_client_next/src/model/membership_entitlements.dart';
import 'package:trotxi_api_client_next/src/model/membership_membership.dart';
import 'package:trotxi_api_client_next/src/model/membership_commute.dart';
import 'package:trotxi_api_client_next/src/model/membership_access.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'membership.g.dart';

/// Membership
///
/// Properties:
/// * [membership] 
/// * [coverage] 
/// * [lastCoverageEndedAt] 
/// * [access] 
/// * [commute] 
/// * [entitlements] 
@BuiltValue()
abstract class Membership implements Built<Membership, MembershipBuilder> {
  @BuiltValueField(wireName: r'membership')
  MembershipMembership? get membership;

  @BuiltValueField(wireName: r'coverage')
  MembershipCoverage? get coverage;

  @BuiltValueField(wireName: r'lastCoverageEndedAt')
  DateTime? get lastCoverageEndedAt;

  @BuiltValueField(wireName: r'access')
  MembershipAccess get access;

  @BuiltValueField(wireName: r'commute')
  MembershipCommute? get commute;

  @BuiltValueField(wireName: r'entitlements')
  MembershipEntitlements get entitlements;

  Membership._();

  factory Membership([void updates(MembershipBuilder b)]) = _$Membership;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MembershipBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Membership> get serializer => _$MembershipSerializer();
}

class _$MembershipSerializer implements PrimitiveSerializer<Membership> {
  @override
  final Iterable<Type> types = const [Membership, _$Membership];

  @override
  final String wireName = r'Membership';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Membership object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'membership';
    yield object.membership == null ? null : serializers.serialize(
      object.membership,
      specifiedType: const FullType.nullable(MembershipMembership),
    );
    yield r'coverage';
    yield object.coverage == null ? null : serializers.serialize(
      object.coverage,
      specifiedType: const FullType.nullable(MembershipCoverage),
    );
    yield r'lastCoverageEndedAt';
    yield object.lastCoverageEndedAt == null ? null : serializers.serialize(
      object.lastCoverageEndedAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'access';
    yield serializers.serialize(
      object.access,
      specifiedType: const FullType(MembershipAccess),
    );
    yield r'commute';
    yield object.commute == null ? null : serializers.serialize(
      object.commute,
      specifiedType: const FullType.nullable(MembershipCommute),
    );
    yield r'entitlements';
    yield serializers.serialize(
      object.entitlements,
      specifiedType: const FullType(MembershipEntitlements),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Membership object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MembershipBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'membership':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(MembershipMembership),
          ) as MembershipMembership?;
          if (valueDes == null) continue;
          result.membership.replace(valueDes);
          break;
        case r'coverage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(MembershipCoverage),
          ) as MembershipCoverage?;
          if (valueDes == null) continue;
          result.coverage.replace(valueDes);
          break;
        case r'lastCoverageEndedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.lastCoverageEndedAt = valueDes;
          break;
        case r'access':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MembershipAccess),
          ) as MembershipAccess;
          result.access.replace(valueDes);
          break;
        case r'commute':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(MembershipCommute),
          ) as MembershipCommute?;
          if (valueDes == null) continue;
          result.commute.replace(valueDes);
          break;
        case r'entitlements':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MembershipEntitlements),
          ) as MembershipEntitlements;
          result.entitlements.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Membership deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MembershipBuilder();
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


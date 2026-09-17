//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'membership_coverage.g.dart';

/// MembershipCoverage
///
/// Properties:
/// * [id] 
/// * [startsAt] 
/// * [endsAt] 
/// * [state] 
/// * [paused] 
/// * [renewalMode] 
@BuiltValue()
abstract class MembershipCoverage implements Built<MembershipCoverage, MembershipCoverageBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'startsAt')
  DateTime get startsAt;

  @BuiltValueField(wireName: r'endsAt')
  DateTime? get endsAt;

  @BuiltValueField(wireName: r'state')
  MembershipCoverageStateEnum get state;
  // enum stateEnum {  open,  closed,  reversed,  };

  @BuiltValueField(wireName: r'paused')
  bool get paused;

  @BuiltValueField(wireName: r'renewalMode')
  MembershipCoverageRenewalModeEnum get renewalMode;
  // enum renewalModeEnum {  manual,  };

  MembershipCoverage._();

  factory MembershipCoverage([void updates(MembershipCoverageBuilder b)]) = _$MembershipCoverage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MembershipCoverageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MembershipCoverage> get serializer => _$MembershipCoverageSerializer();
}

class _$MembershipCoverageSerializer implements PrimitiveSerializer<MembershipCoverage> {
  @override
  final Iterable<Type> types = const [MembershipCoverage, _$MembershipCoverage];

  @override
  final String wireName = r'MembershipCoverage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MembershipCoverage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'startsAt';
    yield serializers.serialize(
      object.startsAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'endsAt';
    yield object.endsAt == null ? null : serializers.serialize(
      object.endsAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'state';
    yield serializers.serialize(
      object.state,
      specifiedType: const FullType(MembershipCoverageStateEnum),
    );
    yield r'paused';
    yield serializers.serialize(
      object.paused,
      specifiedType: const FullType(bool),
    );
    yield r'renewalMode';
    yield serializers.serialize(
      object.renewalMode,
      specifiedType: const FullType(MembershipCoverageRenewalModeEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MembershipCoverage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MembershipCoverageBuilder result,
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
        case r'startsAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.startsAt = valueDes;
          break;
        case r'endsAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.endsAt = valueDes;
          break;
        case r'state':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MembershipCoverageStateEnum),
          ) as MembershipCoverageStateEnum;
          result.state = valueDes;
          break;
        case r'paused':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.paused = valueDes;
          break;
        case r'renewalMode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MembershipCoverageRenewalModeEnum),
          ) as MembershipCoverageRenewalModeEnum;
          result.renewalMode = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MembershipCoverage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MembershipCoverageBuilder();
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

class MembershipCoverageStateEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'open')
  static const MembershipCoverageStateEnum open = _$membershipCoverageStateEnum_open;
  @BuiltValueEnumConst(wireName: r'closed')
  static const MembershipCoverageStateEnum closed = _$membershipCoverageStateEnum_closed;
  @BuiltValueEnumConst(wireName: r'reversed')
  static const MembershipCoverageStateEnum reversed = _$membershipCoverageStateEnum_reversed;

  static Serializer<MembershipCoverageStateEnum> get serializer => _$membershipCoverageStateEnumSerializer;

  const MembershipCoverageStateEnum._(String name): super(name);

  static BuiltSet<MembershipCoverageStateEnum> get values => _$membershipCoverageStateEnumValues;
  static MembershipCoverageStateEnum valueOf(String name) => _$membershipCoverageStateEnumValueOf(name);
}

class MembershipCoverageRenewalModeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'manual')
  static const MembershipCoverageRenewalModeEnum manual = _$membershipCoverageRenewalModeEnum_manual;

  static Serializer<MembershipCoverageRenewalModeEnum> get serializer => _$membershipCoverageRenewalModeEnumSerializer;

  const MembershipCoverageRenewalModeEnum._(String name): super(name);

  static BuiltSet<MembershipCoverageRenewalModeEnum> get values => _$membershipCoverageRenewalModeEnumValues;
  static MembershipCoverageRenewalModeEnum valueOf(String name) => _$membershipCoverageRenewalModeEnumValueOf(name);
}


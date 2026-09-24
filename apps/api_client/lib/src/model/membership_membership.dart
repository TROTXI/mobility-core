//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'membership_membership.g.dart';

/// MembershipMembership
///
/// Properties:
/// * [id] 
/// * [lifecycle] 
@BuiltValue()
abstract class MembershipMembership implements Built<MembershipMembership, MembershipMembershipBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'lifecycle')
  MembershipMembershipLifecycleEnum get lifecycle;
  // enum lifecycleEnum {  open,  ended,  };

  MembershipMembership._();

  factory MembershipMembership([void updates(MembershipMembershipBuilder b)]) = _$MembershipMembership;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MembershipMembershipBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MembershipMembership> get serializer => _$MembershipMembershipSerializer();
}

class _$MembershipMembershipSerializer implements PrimitiveSerializer<MembershipMembership> {
  @override
  final Iterable<Type> types = const [MembershipMembership, _$MembershipMembership];

  @override
  final String wireName = r'MembershipMembership';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MembershipMembership object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'lifecycle';
    yield serializers.serialize(
      object.lifecycle,
      specifiedType: const FullType(MembershipMembershipLifecycleEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MembershipMembership object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MembershipMembershipBuilder result,
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
        case r'lifecycle':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MembershipMembershipLifecycleEnum),
          ) as MembershipMembershipLifecycleEnum;
          result.lifecycle = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MembershipMembership deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MembershipMembershipBuilder();
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

class MembershipMembershipLifecycleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'open')
  static const MembershipMembershipLifecycleEnum open = _$membershipMembershipLifecycleEnum_open;
  @BuiltValueEnumConst(wireName: r'ended')
  static const MembershipMembershipLifecycleEnum ended = _$membershipMembershipLifecycleEnum_ended;

  static Serializer<MembershipMembershipLifecycleEnum> get serializer => _$membershipMembershipLifecycleEnumSerializer;

  const MembershipMembershipLifecycleEnum._(String name): super(name);

  static BuiltSet<MembershipMembershipLifecycleEnum> get values => _$membershipMembershipLifecycleEnumValues;
  static MembershipMembershipLifecycleEnum valueOf(String name) => _$membershipMembershipLifecycleEnumValueOf(name);
}


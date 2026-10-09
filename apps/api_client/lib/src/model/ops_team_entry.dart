//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_team_entry.g.dart';

/// OpsTeamEntry
///
/// Properties:
/// * [id]
/// * [name]
/// * [email]
/// * [kind]
/// * [state]
/// * [isSuperadmin]
/// * [expiresAt]
/// * [emailState]
@BuiltValue()
abstract class OpsTeamEntry
    implements Built<OpsTeamEntry, OpsTeamEntryBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'email')
  String? get email;

  @BuiltValueField(wireName: r'kind')
  OpsTeamEntryKindEnum get kind;
  // enum kindEnum {  member,  invitation,  };

  @BuiltValueField(wireName: r'state')
  OpsTeamEntryStateEnum get state;
  // enum stateEnum {  active,  pending,  claimed,  expired,  cancelled,  };

  @BuiltValueField(wireName: r'isSuperadmin')
  bool get isSuperadmin;

  @BuiltValueField(wireName: r'expiresAt')
  DateTime? get expiresAt;

  @BuiltValueField(wireName: r'emailState')
  OpsTeamEntryEmailStateEnum? get emailState;
  // enum emailStateEnum {  pending,  accepted,  cancelled,  failed,  unknown,  };

  OpsTeamEntry._();

  factory OpsTeamEntry([void updates(OpsTeamEntryBuilder b)]) = _$OpsTeamEntry;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsTeamEntryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsTeamEntry> get serializer => _$OpsTeamEntrySerializer();
}

class _$OpsTeamEntrySerializer implements PrimitiveSerializer<OpsTeamEntry> {
  @override
  final Iterable<Type> types = const [OpsTeamEntry, _$OpsTeamEntry];

  @override
  final String wireName = r'OpsTeamEntry';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsTeamEntry object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'email';
    yield object.email == null
        ? null
        : serializers.serialize(
            object.email,
            specifiedType: const FullType.nullable(String),
          );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(OpsTeamEntryKindEnum),
    );
    yield r'state';
    yield serializers.serialize(
      object.state,
      specifiedType: const FullType(OpsTeamEntryStateEnum),
    );
    yield r'isSuperadmin';
    yield serializers.serialize(
      object.isSuperadmin,
      specifiedType: const FullType(bool),
    );
    yield r'expiresAt';
    yield object.expiresAt == null
        ? null
        : serializers.serialize(
            object.expiresAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'emailState';
    yield object.emailState == null
        ? null
        : serializers.serialize(
            object.emailState,
            specifiedType: const FullType.nullable(OpsTeamEntryEmailStateEnum),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsTeamEntry object, {
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
    required OpsTeamEntryBuilder result,
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
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.email = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OpsTeamEntryKindEnum),
          ) as OpsTeamEntryKindEnum;
          result.kind = valueDes;
          break;
        case r'state':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OpsTeamEntryStateEnum),
          ) as OpsTeamEntryStateEnum;
          result.state = valueDes;
          break;
        case r'isSuperadmin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isSuperadmin = valueDes;
          break;
        case r'expiresAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.expiresAt = valueDes;
          break;
        case r'emailState':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(OpsTeamEntryEmailStateEnum),
          ) as OpsTeamEntryEmailStateEnum?;
          if (valueDes == null) continue;
          result.emailState = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OpsTeamEntry deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsTeamEntryBuilder();
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

class OpsTeamEntryKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'member')
  static const OpsTeamEntryKindEnum member = _$opsTeamEntryKindEnum_member;
  @BuiltValueEnumConst(wireName: r'invitation')
  static const OpsTeamEntryKindEnum invitation =
      _$opsTeamEntryKindEnum_invitation;

  static Serializer<OpsTeamEntryKindEnum> get serializer =>
      _$opsTeamEntryKindEnumSerializer;

  const OpsTeamEntryKindEnum._(String name) : super(name);

  static BuiltSet<OpsTeamEntryKindEnum> get values =>
      _$opsTeamEntryKindEnumValues;
  static OpsTeamEntryKindEnum valueOf(String name) =>
      _$opsTeamEntryKindEnumValueOf(name);
}

class OpsTeamEntryStateEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'active')
  static const OpsTeamEntryStateEnum active = _$opsTeamEntryStateEnum_active;
  @BuiltValueEnumConst(wireName: r'pending')
  static const OpsTeamEntryStateEnum pending = _$opsTeamEntryStateEnum_pending;
  @BuiltValueEnumConst(wireName: r'claimed')
  static const OpsTeamEntryStateEnum claimed = _$opsTeamEntryStateEnum_claimed;
  @BuiltValueEnumConst(wireName: r'expired')
  static const OpsTeamEntryStateEnum expired = _$opsTeamEntryStateEnum_expired;
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const OpsTeamEntryStateEnum cancelled =
      _$opsTeamEntryStateEnum_cancelled;

  static Serializer<OpsTeamEntryStateEnum> get serializer =>
      _$opsTeamEntryStateEnumSerializer;

  const OpsTeamEntryStateEnum._(String name) : super(name);

  static BuiltSet<OpsTeamEntryStateEnum> get values =>
      _$opsTeamEntryStateEnumValues;
  static OpsTeamEntryStateEnum valueOf(String name) =>
      _$opsTeamEntryStateEnumValueOf(name);
}

class OpsTeamEntryEmailStateEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'pending')
  static const OpsTeamEntryEmailStateEnum pending =
      _$opsTeamEntryEmailStateEnum_pending;
  @BuiltValueEnumConst(wireName: r'accepted')
  static const OpsTeamEntryEmailStateEnum accepted =
      _$opsTeamEntryEmailStateEnum_accepted;
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const OpsTeamEntryEmailStateEnum cancelled =
      _$opsTeamEntryEmailStateEnum_cancelled;
  @BuiltValueEnumConst(wireName: r'failed')
  static const OpsTeamEntryEmailStateEnum failed =
      _$opsTeamEntryEmailStateEnum_failed;
  @BuiltValueEnumConst(wireName: r'unknown')
  static const OpsTeamEntryEmailStateEnum unknown =
      _$opsTeamEntryEmailStateEnum_unknown;

  static Serializer<OpsTeamEntryEmailStateEnum> get serializer =>
      _$opsTeamEntryEmailStateEnumSerializer;

  const OpsTeamEntryEmailStateEnum._(String name) : super(name);

  static BuiltSet<OpsTeamEntryEmailStateEnum> get values =>
      _$opsTeamEntryEmailStateEnumValues;
  static OpsTeamEntryEmailStateEnum valueOf(String name) =>
      _$opsTeamEntryEmailStateEnumValueOf(name);
}

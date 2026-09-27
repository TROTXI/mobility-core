//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/money.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_rider.g.dart';

/// OpsRider
///
/// Properties:
/// * [id] 
/// * [displayName] 
/// * [phone] 
/// * [email] 
/// * [role] 
/// * [status] 
/// * [plan] 
/// * [routeName] 
/// * [ridesLeft] 
/// * [availableCredit] 
/// * [joinedAt] 
/// * [editToken] 
@BuiltValue()
abstract class OpsRider implements Built<OpsRider, OpsRiderBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'displayName')
  String get displayName;

  @BuiltValueField(wireName: r'phone')
  String? get phone;

  @BuiltValueField(wireName: r'email')
  String? get email;

  @BuiltValueField(wireName: r'role')
  OpsRiderRoleEnum get role;
  // enum roleEnum {  commuter,  driver,  admin,  };

  @BuiltValueField(wireName: r'status')
  OpsRiderStatusEnum get status;
  // enum statusEnum {  active,  paused,  lapsed,  none,  };

  @BuiltValueField(wireName: r'plan')
  OpsRiderPlanEnum? get plan;
  // enum planEnum {  monthly,  annual,  };

  @BuiltValueField(wireName: r'routeName')
  String? get routeName;

  @BuiltValueField(wireName: r'ridesLeft')
  int? get ridesLeft;

  @BuiltValueField(wireName: r'availableCredit')
  Money get availableCredit;

  @BuiltValueField(wireName: r'joinedAt')
  DateTime get joinedAt;

  @BuiltValueField(wireName: r'editToken')
  String get editToken;

  OpsRider._();

  factory OpsRider([void updates(OpsRiderBuilder b)]) = _$OpsRider;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsRiderBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsRider> get serializer => _$OpsRiderSerializer();
}

class _$OpsRiderSerializer implements PrimitiveSerializer<OpsRider> {
  @override
  final Iterable<Type> types = const [OpsRider, _$OpsRider];

  @override
  final String wireName = r'OpsRider';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsRider object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'displayName';
    yield serializers.serialize(
      object.displayName,
      specifiedType: const FullType(String),
    );
    yield r'phone';
    yield object.phone == null ? null : serializers.serialize(
      object.phone,
      specifiedType: const FullType.nullable(String),
    );
    yield r'email';
    yield object.email == null ? null : serializers.serialize(
      object.email,
      specifiedType: const FullType.nullable(String),
    );
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(OpsRiderRoleEnum),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(OpsRiderStatusEnum),
    );
    yield r'plan';
    yield object.plan == null ? null : serializers.serialize(
      object.plan,
      specifiedType: const FullType.nullable(OpsRiderPlanEnum),
    );
    yield r'routeName';
    yield object.routeName == null ? null : serializers.serialize(
      object.routeName,
      specifiedType: const FullType.nullable(String),
    );
    yield r'ridesLeft';
    yield object.ridesLeft == null ? null : serializers.serialize(
      object.ridesLeft,
      specifiedType: const FullType.nullable(int),
    );
    yield r'availableCredit';
    yield serializers.serialize(
      object.availableCredit,
      specifiedType: const FullType(Money),
    );
    yield r'joinedAt';
    yield serializers.serialize(
      object.joinedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'editToken';
    yield serializers.serialize(
      object.editToken,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsRider object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OpsRiderBuilder result,
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
        case r'displayName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.displayName = valueDes;
          break;
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.phone = valueDes;
          break;
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.email = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OpsRiderRoleEnum),
          ) as OpsRiderRoleEnum;
          result.role = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OpsRiderStatusEnum),
          ) as OpsRiderStatusEnum;
          result.status = valueDes;
          break;
        case r'plan':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(OpsRiderPlanEnum),
          ) as OpsRiderPlanEnum?;
          if (valueDes == null) continue;
          result.plan = valueDes;
          break;
        case r'routeName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.routeName = valueDes;
          break;
        case r'ridesLeft':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.ridesLeft = valueDes;
          break;
        case r'availableCredit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Money),
          ) as Money;
          result.availableCredit.replace(valueDes);
          break;
        case r'joinedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.joinedAt = valueDes;
          break;
        case r'editToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.editToken = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OpsRider deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsRiderBuilder();
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

class OpsRiderRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'commuter')
  static const OpsRiderRoleEnum commuter = _$opsRiderRoleEnum_commuter;
  @BuiltValueEnumConst(wireName: r'driver')
  static const OpsRiderRoleEnum driver = _$opsRiderRoleEnum_driver;
  @BuiltValueEnumConst(wireName: r'admin')
  static const OpsRiderRoleEnum admin = _$opsRiderRoleEnum_admin;

  static Serializer<OpsRiderRoleEnum> get serializer => _$opsRiderRoleEnumSerializer;

  const OpsRiderRoleEnum._(String name): super(name);

  static BuiltSet<OpsRiderRoleEnum> get values => _$opsRiderRoleEnumValues;
  static OpsRiderRoleEnum valueOf(String name) => _$opsRiderRoleEnumValueOf(name);
}

class OpsRiderStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'active')
  static const OpsRiderStatusEnum active = _$opsRiderStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'paused')
  static const OpsRiderStatusEnum paused = _$opsRiderStatusEnum_paused;
  @BuiltValueEnumConst(wireName: r'lapsed')
  static const OpsRiderStatusEnum lapsed = _$opsRiderStatusEnum_lapsed;
  @BuiltValueEnumConst(wireName: r'none')
  static const OpsRiderStatusEnum none = _$opsRiderStatusEnum_none;

  static Serializer<OpsRiderStatusEnum> get serializer => _$opsRiderStatusEnumSerializer;

  const OpsRiderStatusEnum._(String name): super(name);

  static BuiltSet<OpsRiderStatusEnum> get values => _$opsRiderStatusEnumValues;
  static OpsRiderStatusEnum valueOf(String name) => _$opsRiderStatusEnumValueOf(name);
}

class OpsRiderPlanEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'monthly')
  static const OpsRiderPlanEnum monthly = _$opsRiderPlanEnum_monthly;
  @BuiltValueEnumConst(wireName: r'annual')
  static const OpsRiderPlanEnum annual = _$opsRiderPlanEnum_annual;

  static Serializer<OpsRiderPlanEnum> get serializer => _$opsRiderPlanEnumSerializer;

  const OpsRiderPlanEnum._(String name): super(name);

  static BuiltSet<OpsRiderPlanEnum> get values => _$opsRiderPlanEnumValues;
  static OpsRiderPlanEnum valueOf(String name) => _$opsRiderPlanEnumValueOf(name);
}


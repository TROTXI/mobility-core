//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/commute_request_input.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_commute_request.g.dart';

/// OpsCommuteRequest
///
/// Properties:
/// * [id] 
/// * [status] 
/// * [requested] 
/// * [effectiveDate] 
/// * [paused] 
/// * [decisionNote] 
/// * [createdAt] 
/// * [updatedAt] 
/// * [version] 
/// * [riderId] 
/// * [slotId] 
/// * [decidedBy] 
/// * [editToken] 
@BuiltValue()
abstract class OpsCommuteRequest implements Built<OpsCommuteRequest, OpsCommuteRequestBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'status')
  OpsCommuteRequestStatusEnum get status;
  // enum statusEnum {  submitted,  waitlisted,  approved,  applied,  rejected,  cancelled,  };

  @BuiltValueField(wireName: r'requested')
  CommuteRequestInput get requested;

  @BuiltValueField(wireName: r'effectiveDate')
  Date? get effectiveDate;

  @BuiltValueField(wireName: r'paused')
  bool get paused;

  @BuiltValueField(wireName: r'decisionNote')
  String? get decisionNote;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'version')
  int get version;

  @BuiltValueField(wireName: r'riderId')
  String get riderId;

  @BuiltValueField(wireName: r'slotId')
  String? get slotId;

  @BuiltValueField(wireName: r'decidedBy')
  String? get decidedBy;

  @BuiltValueField(wireName: r'editToken')
  String get editToken;

  OpsCommuteRequest._();

  factory OpsCommuteRequest([void updates(OpsCommuteRequestBuilder b)]) = _$OpsCommuteRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsCommuteRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsCommuteRequest> get serializer => _$OpsCommuteRequestSerializer();
}

class _$OpsCommuteRequestSerializer implements PrimitiveSerializer<OpsCommuteRequest> {
  @override
  final Iterable<Type> types = const [OpsCommuteRequest, _$OpsCommuteRequest];

  @override
  final String wireName = r'OpsCommuteRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsCommuteRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(OpsCommuteRequestStatusEnum),
    );
    yield r'requested';
    yield serializers.serialize(
      object.requested,
      specifiedType: const FullType(CommuteRequestInput),
    );
    yield r'effectiveDate';
    yield object.effectiveDate == null ? null : serializers.serialize(
      object.effectiveDate,
      specifiedType: const FullType.nullable(Date),
    );
    yield r'paused';
    yield serializers.serialize(
      object.paused,
      specifiedType: const FullType(bool),
    );
    yield r'decisionNote';
    yield object.decisionNote == null ? null : serializers.serialize(
      object.decisionNote,
      specifiedType: const FullType.nullable(String),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'updatedAt';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
    );
    yield r'riderId';
    yield serializers.serialize(
      object.riderId,
      specifiedType: const FullType(String),
    );
    yield r'slotId';
    yield object.slotId == null ? null : serializers.serialize(
      object.slotId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'decidedBy';
    yield object.decidedBy == null ? null : serializers.serialize(
      object.decidedBy,
      specifiedType: const FullType.nullable(String),
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
    OpsCommuteRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OpsCommuteRequestBuilder result,
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
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OpsCommuteRequestStatusEnum),
          ) as OpsCommuteRequestStatusEnum;
          result.status = valueDes;
          break;
        case r'requested':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CommuteRequestInput),
          ) as CommuteRequestInput;
          result.requested.replace(valueDes);
          break;
        case r'effectiveDate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.effectiveDate = valueDes;
          break;
        case r'paused':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.paused = valueDes;
          break;
        case r'decisionNote':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.decisionNote = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'updatedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.version = valueDes;
          break;
        case r'riderId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.riderId = valueDes;
          break;
        case r'slotId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.slotId = valueDes;
          break;
        case r'decidedBy':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.decidedBy = valueDes;
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
  OpsCommuteRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsCommuteRequestBuilder();
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

class OpsCommuteRequestStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'submitted')
  static const OpsCommuteRequestStatusEnum submitted = _$opsCommuteRequestStatusEnum_submitted;
  @BuiltValueEnumConst(wireName: r'waitlisted')
  static const OpsCommuteRequestStatusEnum waitlisted = _$opsCommuteRequestStatusEnum_waitlisted;
  @BuiltValueEnumConst(wireName: r'approved')
  static const OpsCommuteRequestStatusEnum approved = _$opsCommuteRequestStatusEnum_approved;
  @BuiltValueEnumConst(wireName: r'applied')
  static const OpsCommuteRequestStatusEnum applied = _$opsCommuteRequestStatusEnum_applied;
  @BuiltValueEnumConst(wireName: r'rejected')
  static const OpsCommuteRequestStatusEnum rejected = _$opsCommuteRequestStatusEnum_rejected;
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const OpsCommuteRequestStatusEnum cancelled = _$opsCommuteRequestStatusEnum_cancelled;

  static Serializer<OpsCommuteRequestStatusEnum> get serializer => _$opsCommuteRequestStatusEnumSerializer;

  const OpsCommuteRequestStatusEnum._(String name): super(name);

  static BuiltSet<OpsCommuteRequestStatusEnum> get values => _$opsCommuteRequestStatusEnumValues;
  static OpsCommuteRequestStatusEnum valueOf(String name) => _$opsCommuteRequestStatusEnumValueOf(name);
}


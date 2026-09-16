//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client_next/src/model/work_request_input.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_work_request.g.dart';

/// OpsWorkRequest
///
/// Properties:
/// * [id] 
/// * [request] 
/// * [status] 
/// * [decisionNote] 
/// * [createdAt] 
/// * [updatedAt] 
/// * [version] 
/// * [driverId] 
/// * [decidedBy] 
/// * [editToken] 
@BuiltValue()
abstract class OpsWorkRequest implements Built<OpsWorkRequest, OpsWorkRequestBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'request')
  WorkRequestInput get request;

  @BuiltValueField(wireName: r'status')
  OpsWorkRequestStatusEnum get status;
  // enum statusEnum {  pending,  approved,  declined,  withdrawn,  };

  @BuiltValueField(wireName: r'decisionNote')
  String? get decisionNote;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'version')
  int get version;

  @BuiltValueField(wireName: r'driverId')
  String get driverId;

  @BuiltValueField(wireName: r'decidedBy')
  String? get decidedBy;

  @BuiltValueField(wireName: r'editToken')
  String get editToken;

  OpsWorkRequest._();

  factory OpsWorkRequest([void updates(OpsWorkRequestBuilder b)]) = _$OpsWorkRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsWorkRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsWorkRequest> get serializer => _$OpsWorkRequestSerializer();
}

class _$OpsWorkRequestSerializer implements PrimitiveSerializer<OpsWorkRequest> {
  @override
  final Iterable<Type> types = const [OpsWorkRequest, _$OpsWorkRequest];

  @override
  final String wireName = r'OpsWorkRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsWorkRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'request';
    yield serializers.serialize(
      object.request,
      specifiedType: const FullType(WorkRequestInput),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(OpsWorkRequestStatusEnum),
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
    yield r'driverId';
    yield serializers.serialize(
      object.driverId,
      specifiedType: const FullType(String),
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
    OpsWorkRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OpsWorkRequestBuilder result,
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
        case r'request':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(WorkRequestInput),
          ) as WorkRequestInput;
          result.request.replace(valueDes);
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OpsWorkRequestStatusEnum),
          ) as OpsWorkRequestStatusEnum;
          result.status = valueDes;
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
        case r'driverId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.driverId = valueDes;
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
  OpsWorkRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsWorkRequestBuilder();
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

class OpsWorkRequestStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'pending')
  static const OpsWorkRequestStatusEnum pending = _$opsWorkRequestStatusEnum_pending;
  @BuiltValueEnumConst(wireName: r'approved')
  static const OpsWorkRequestStatusEnum approved = _$opsWorkRequestStatusEnum_approved;
  @BuiltValueEnumConst(wireName: r'declined')
  static const OpsWorkRequestStatusEnum declined = _$opsWorkRequestStatusEnum_declined;
  @BuiltValueEnumConst(wireName: r'withdrawn')
  static const OpsWorkRequestStatusEnum withdrawn = _$opsWorkRequestStatusEnum_withdrawn;

  static Serializer<OpsWorkRequestStatusEnum> get serializer => _$opsWorkRequestStatusEnumSerializer;

  const OpsWorkRequestStatusEnum._(String name): super(name);

  static BuiltSet<OpsWorkRequestStatusEnum> get values => _$opsWorkRequestStatusEnumValues;
  static OpsWorkRequestStatusEnum valueOf(String name) => _$opsWorkRequestStatusEnumValueOf(name);
}


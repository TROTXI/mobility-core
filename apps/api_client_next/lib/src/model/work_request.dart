//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client_next/src/model/work_request_input.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'work_request.g.dart';

/// WorkRequest
///
/// Properties:
/// * [id] 
/// * [request] 
/// * [status] 
/// * [decisionNote] 
/// * [createdAt] 
/// * [updatedAt] 
/// * [version] 
@BuiltValue()
abstract class WorkRequest implements Built<WorkRequest, WorkRequestBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'request')
  WorkRequestInput get request;

  @BuiltValueField(wireName: r'status')
  WorkRequestStatusEnum get status;
  // enum statusEnum {  pending,  approved,  declined,  withdrawn,  };

  @BuiltValueField(wireName: r'decisionNote')
  String? get decisionNote;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'version')
  int get version;

  WorkRequest._();

  factory WorkRequest([void updates(WorkRequestBuilder b)]) = _$WorkRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WorkRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WorkRequest> get serializer => _$WorkRequestSerializer();
}

class _$WorkRequestSerializer implements PrimitiveSerializer<WorkRequest> {
  @override
  final Iterable<Type> types = const [WorkRequest, _$WorkRequest];

  @override
  final String wireName = r'WorkRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WorkRequest object, {
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
      specifiedType: const FullType(WorkRequestStatusEnum),
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
  }

  @override
  Object serialize(
    Serializers serializers,
    WorkRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WorkRequestBuilder result,
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
            specifiedType: const FullType(WorkRequestStatusEnum),
          ) as WorkRequestStatusEnum;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WorkRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WorkRequestBuilder();
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

class WorkRequestStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'pending')
  static const WorkRequestStatusEnum pending = _$workRequestStatusEnum_pending;
  @BuiltValueEnumConst(wireName: r'approved')
  static const WorkRequestStatusEnum approved = _$workRequestStatusEnum_approved;
  @BuiltValueEnumConst(wireName: r'declined')
  static const WorkRequestStatusEnum declined = _$workRequestStatusEnum_declined;
  @BuiltValueEnumConst(wireName: r'withdrawn')
  static const WorkRequestStatusEnum withdrawn = _$workRequestStatusEnum_withdrawn;

  static Serializer<WorkRequestStatusEnum> get serializer => _$workRequestStatusEnumSerializer;

  const WorkRequestStatusEnum._(String name): super(name);

  static BuiltSet<WorkRequestStatusEnum> get values => _$workRequestStatusEnumValues;
  static WorkRequestStatusEnum valueOf(String name) => _$workRequestStatusEnumValueOf(name);
}


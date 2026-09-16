//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/commute_request_input.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commute_request.g.dart';

/// CommuteRequest
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
@BuiltValue()
abstract class CommuteRequest implements Built<CommuteRequest, CommuteRequestBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'status')
  CommuteRequestStatusEnum get status;
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

  CommuteRequest._();

  factory CommuteRequest([void updates(CommuteRequestBuilder b)]) = _$CommuteRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommuteRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommuteRequest> get serializer => _$CommuteRequestSerializer();
}

class _$CommuteRequestSerializer implements PrimitiveSerializer<CommuteRequest> {
  @override
  final Iterable<Type> types = const [CommuteRequest, _$CommuteRequest];

  @override
  final String wireName = r'CommuteRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommuteRequest object, {
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
      specifiedType: const FullType(CommuteRequestStatusEnum),
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
  }

  @override
  Object serialize(
    Serializers serializers,
    CommuteRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CommuteRequestBuilder result,
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
            specifiedType: const FullType(CommuteRequestStatusEnum),
          ) as CommuteRequestStatusEnum;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CommuteRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommuteRequestBuilder();
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

class CommuteRequestStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'submitted')
  static const CommuteRequestStatusEnum submitted = _$commuteRequestStatusEnum_submitted;
  @BuiltValueEnumConst(wireName: r'waitlisted')
  static const CommuteRequestStatusEnum waitlisted = _$commuteRequestStatusEnum_waitlisted;
  @BuiltValueEnumConst(wireName: r'approved')
  static const CommuteRequestStatusEnum approved = _$commuteRequestStatusEnum_approved;
  @BuiltValueEnumConst(wireName: r'applied')
  static const CommuteRequestStatusEnum applied = _$commuteRequestStatusEnum_applied;
  @BuiltValueEnumConst(wireName: r'rejected')
  static const CommuteRequestStatusEnum rejected = _$commuteRequestStatusEnum_rejected;
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const CommuteRequestStatusEnum cancelled = _$commuteRequestStatusEnum_cancelled;

  static Serializer<CommuteRequestStatusEnum> get serializer => _$commuteRequestStatusEnumSerializer;

  const CommuteRequestStatusEnum._(String name): super(name);

  static BuiltSet<CommuteRequestStatusEnum> get values => _$commuteRequestStatusEnumValues;
  static CommuteRequestStatusEnum valueOf(String name) => _$commuteRequestStatusEnumValueOf(name);
}


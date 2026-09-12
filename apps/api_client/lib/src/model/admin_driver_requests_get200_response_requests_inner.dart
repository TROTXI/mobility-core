//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_driver_requests_get200_response_requests_inner.g.dart';

/// AdminDriverRequestsGet200ResponseRequestsInner
///
/// Properties:
/// * [id] 
/// * [kind] 
/// * [status] 
/// * [routeId] 
/// * [fromDate] 
/// * [toDate] 
/// * [note] 
/// * [decisionNote] 
/// * [decidedAt] 
/// * [createdAt] 
/// * [driverId] 
/// * [decidedBy] 
@BuiltValue()
abstract class AdminDriverRequestsGet200ResponseRequestsInner implements Built<AdminDriverRequestsGet200ResponseRequestsInner, AdminDriverRequestsGet200ResponseRequestsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'kind')
  AdminDriverRequestsGet200ResponseRequestsInnerKindEnum get kind;
  // enum kindEnum {  route_change,  leave,  };

  @BuiltValueField(wireName: r'status')
  AdminDriverRequestsGet200ResponseRequestsInnerStatusEnum get status;
  // enum statusEnum {  pending,  approved,  declined,  withdrawn,  };

  @BuiltValueField(wireName: r'routeId')
  String? get routeId;

  @BuiltValueField(wireName: r'fromDate')
  String? get fromDate;

  @BuiltValueField(wireName: r'toDate')
  String? get toDate;

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'decisionNote')
  String? get decisionNote;

  @BuiltValueField(wireName: r'decidedAt')
  DateTime? get decidedAt;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'driverId')
  String get driverId;

  @BuiltValueField(wireName: r'decidedBy')
  String? get decidedBy;

  AdminDriverRequestsGet200ResponseRequestsInner._();

  factory AdminDriverRequestsGet200ResponseRequestsInner([void updates(AdminDriverRequestsGet200ResponseRequestsInnerBuilder b)]) = _$AdminDriverRequestsGet200ResponseRequestsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminDriverRequestsGet200ResponseRequestsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminDriverRequestsGet200ResponseRequestsInner> get serializer => _$AdminDriverRequestsGet200ResponseRequestsInnerSerializer();
}

class _$AdminDriverRequestsGet200ResponseRequestsInnerSerializer implements PrimitiveSerializer<AdminDriverRequestsGet200ResponseRequestsInner> {
  @override
  final Iterable<Type> types = const [AdminDriverRequestsGet200ResponseRequestsInner, _$AdminDriverRequestsGet200ResponseRequestsInner];

  @override
  final String wireName = r'AdminDriverRequestsGet200ResponseRequestsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminDriverRequestsGet200ResponseRequestsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(AdminDriverRequestsGet200ResponseRequestsInnerKindEnum),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(AdminDriverRequestsGet200ResponseRequestsInnerStatusEnum),
    );
    yield r'routeId';
    yield object.routeId == null ? null : serializers.serialize(
      object.routeId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'fromDate';
    yield object.fromDate == null ? null : serializers.serialize(
      object.fromDate,
      specifiedType: const FullType.nullable(String),
    );
    yield r'toDate';
    yield object.toDate == null ? null : serializers.serialize(
      object.toDate,
      specifiedType: const FullType.nullable(String),
    );
    yield r'note';
    yield object.note == null ? null : serializers.serialize(
      object.note,
      specifiedType: const FullType.nullable(String),
    );
    yield r'decisionNote';
    yield object.decisionNote == null ? null : serializers.serialize(
      object.decisionNote,
      specifiedType: const FullType.nullable(String),
    );
    yield r'decidedAt';
    yield object.decidedAt == null ? null : serializers.serialize(
      object.decidedAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
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
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminDriverRequestsGet200ResponseRequestsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminDriverRequestsGet200ResponseRequestsInnerBuilder result,
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
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminDriverRequestsGet200ResponseRequestsInnerKindEnum),
          ) as AdminDriverRequestsGet200ResponseRequestsInnerKindEnum;
          result.kind = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminDriverRequestsGet200ResponseRequestsInnerStatusEnum),
          ) as AdminDriverRequestsGet200ResponseRequestsInnerStatusEnum;
          result.status = valueDes;
          break;
        case r'routeId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.routeId = valueDes;
          break;
        case r'fromDate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.fromDate = valueDes;
          break;
        case r'toDate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.toDate = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        case r'decisionNote':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.decisionNote = valueDes;
          break;
        case r'decidedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.decidedAt = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminDriverRequestsGet200ResponseRequestsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminDriverRequestsGet200ResponseRequestsInnerBuilder();
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

class AdminDriverRequestsGet200ResponseRequestsInnerKindEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'route_change')
  static const AdminDriverRequestsGet200ResponseRequestsInnerKindEnum routeChange = _$adminDriverRequestsGet200ResponseRequestsInnerKindEnum_routeChange;
  @BuiltValueEnumConst(wireName: r'leave')
  static const AdminDriverRequestsGet200ResponseRequestsInnerKindEnum leave = _$adminDriverRequestsGet200ResponseRequestsInnerKindEnum_leave;

  static Serializer<AdminDriverRequestsGet200ResponseRequestsInnerKindEnum> get serializer => _$adminDriverRequestsGet200ResponseRequestsInnerKindEnumSerializer;

  const AdminDriverRequestsGet200ResponseRequestsInnerKindEnum._(String name): super(name);

  static BuiltSet<AdminDriverRequestsGet200ResponseRequestsInnerKindEnum> get values => _$adminDriverRequestsGet200ResponseRequestsInnerKindEnumValues;
  static AdminDriverRequestsGet200ResponseRequestsInnerKindEnum valueOf(String name) => _$adminDriverRequestsGet200ResponseRequestsInnerKindEnumValueOf(name);
}

class AdminDriverRequestsGet200ResponseRequestsInnerStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'pending')
  static const AdminDriverRequestsGet200ResponseRequestsInnerStatusEnum pending = _$adminDriverRequestsGet200ResponseRequestsInnerStatusEnum_pending;
  @BuiltValueEnumConst(wireName: r'approved')
  static const AdminDriverRequestsGet200ResponseRequestsInnerStatusEnum approved = _$adminDriverRequestsGet200ResponseRequestsInnerStatusEnum_approved;
  @BuiltValueEnumConst(wireName: r'declined')
  static const AdminDriverRequestsGet200ResponseRequestsInnerStatusEnum declined = _$adminDriverRequestsGet200ResponseRequestsInnerStatusEnum_declined;
  @BuiltValueEnumConst(wireName: r'withdrawn')
  static const AdminDriverRequestsGet200ResponseRequestsInnerStatusEnum withdrawn = _$adminDriverRequestsGet200ResponseRequestsInnerStatusEnum_withdrawn;

  static Serializer<AdminDriverRequestsGet200ResponseRequestsInnerStatusEnum> get serializer => _$adminDriverRequestsGet200ResponseRequestsInnerStatusEnumSerializer;

  const AdminDriverRequestsGet200ResponseRequestsInnerStatusEnum._(String name): super(name);

  static BuiltSet<AdminDriverRequestsGet200ResponseRequestsInnerStatusEnum> get values => _$adminDriverRequestsGet200ResponseRequestsInnerStatusEnumValues;
  static AdminDriverRequestsGet200ResponseRequestsInnerStatusEnum valueOf(String name) => _$adminDriverRequestsGet200ResponseRequestsInnerStatusEnumValueOf(name);
}


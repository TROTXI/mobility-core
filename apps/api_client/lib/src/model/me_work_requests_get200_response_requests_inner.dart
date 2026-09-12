//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'me_work_requests_get200_response_requests_inner.g.dart';

/// MeWorkRequestsGet200ResponseRequestsInner
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
@BuiltValue()
abstract class MeWorkRequestsGet200ResponseRequestsInner implements Built<MeWorkRequestsGet200ResponseRequestsInner, MeWorkRequestsGet200ResponseRequestsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'kind')
  MeWorkRequestsGet200ResponseRequestsInnerKindEnum get kind;
  // enum kindEnum {  route_change,  leave,  };

  @BuiltValueField(wireName: r'status')
  MeWorkRequestsGet200ResponseRequestsInnerStatusEnum get status;
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

  MeWorkRequestsGet200ResponseRequestsInner._();

  factory MeWorkRequestsGet200ResponseRequestsInner([void updates(MeWorkRequestsGet200ResponseRequestsInnerBuilder b)]) = _$MeWorkRequestsGet200ResponseRequestsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MeWorkRequestsGet200ResponseRequestsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MeWorkRequestsGet200ResponseRequestsInner> get serializer => _$MeWorkRequestsGet200ResponseRequestsInnerSerializer();
}

class _$MeWorkRequestsGet200ResponseRequestsInnerSerializer implements PrimitiveSerializer<MeWorkRequestsGet200ResponseRequestsInner> {
  @override
  final Iterable<Type> types = const [MeWorkRequestsGet200ResponseRequestsInner, _$MeWorkRequestsGet200ResponseRequestsInner];

  @override
  final String wireName = r'MeWorkRequestsGet200ResponseRequestsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MeWorkRequestsGet200ResponseRequestsInner object, {
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
      specifiedType: const FullType(MeWorkRequestsGet200ResponseRequestsInnerKindEnum),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(MeWorkRequestsGet200ResponseRequestsInnerStatusEnum),
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
  }

  @override
  Object serialize(
    Serializers serializers,
    MeWorkRequestsGet200ResponseRequestsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MeWorkRequestsGet200ResponseRequestsInnerBuilder result,
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
            specifiedType: const FullType(MeWorkRequestsGet200ResponseRequestsInnerKindEnum),
          ) as MeWorkRequestsGet200ResponseRequestsInnerKindEnum;
          result.kind = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MeWorkRequestsGet200ResponseRequestsInnerStatusEnum),
          ) as MeWorkRequestsGet200ResponseRequestsInnerStatusEnum;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MeWorkRequestsGet200ResponseRequestsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MeWorkRequestsGet200ResponseRequestsInnerBuilder();
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

class MeWorkRequestsGet200ResponseRequestsInnerKindEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'route_change')
  static const MeWorkRequestsGet200ResponseRequestsInnerKindEnum routeChange = _$meWorkRequestsGet200ResponseRequestsInnerKindEnum_routeChange;
  @BuiltValueEnumConst(wireName: r'leave')
  static const MeWorkRequestsGet200ResponseRequestsInnerKindEnum leave = _$meWorkRequestsGet200ResponseRequestsInnerKindEnum_leave;

  static Serializer<MeWorkRequestsGet200ResponseRequestsInnerKindEnum> get serializer => _$meWorkRequestsGet200ResponseRequestsInnerKindEnumSerializer;

  const MeWorkRequestsGet200ResponseRequestsInnerKindEnum._(String name): super(name);

  static BuiltSet<MeWorkRequestsGet200ResponseRequestsInnerKindEnum> get values => _$meWorkRequestsGet200ResponseRequestsInnerKindEnumValues;
  static MeWorkRequestsGet200ResponseRequestsInnerKindEnum valueOf(String name) => _$meWorkRequestsGet200ResponseRequestsInnerKindEnumValueOf(name);
}

class MeWorkRequestsGet200ResponseRequestsInnerStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'pending')
  static const MeWorkRequestsGet200ResponseRequestsInnerStatusEnum pending = _$meWorkRequestsGet200ResponseRequestsInnerStatusEnum_pending;
  @BuiltValueEnumConst(wireName: r'approved')
  static const MeWorkRequestsGet200ResponseRequestsInnerStatusEnum approved = _$meWorkRequestsGet200ResponseRequestsInnerStatusEnum_approved;
  @BuiltValueEnumConst(wireName: r'declined')
  static const MeWorkRequestsGet200ResponseRequestsInnerStatusEnum declined = _$meWorkRequestsGet200ResponseRequestsInnerStatusEnum_declined;
  @BuiltValueEnumConst(wireName: r'withdrawn')
  static const MeWorkRequestsGet200ResponseRequestsInnerStatusEnum withdrawn = _$meWorkRequestsGet200ResponseRequestsInnerStatusEnum_withdrawn;

  static Serializer<MeWorkRequestsGet200ResponseRequestsInnerStatusEnum> get serializer => _$meWorkRequestsGet200ResponseRequestsInnerStatusEnumSerializer;

  const MeWorkRequestsGet200ResponseRequestsInnerStatusEnum._(String name): super(name);

  static BuiltSet<MeWorkRequestsGet200ResponseRequestsInnerStatusEnum> get values => _$meWorkRequestsGet200ResponseRequestsInnerStatusEnumValues;
  static MeWorkRequestsGet200ResponseRequestsInnerStatusEnum valueOf(String name) => _$meWorkRequestsGet200ResponseRequestsInnerStatusEnumValueOf(name);
}


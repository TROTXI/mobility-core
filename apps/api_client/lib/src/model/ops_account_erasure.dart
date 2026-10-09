//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_account_erasure.g.dart';

/// OpsAccountErasure
///
/// Properties:
/// * [userId]
/// * [erasedAt]
/// * [sessionsRevoked]
/// * [devicesRevoked]
/// * [identitiesScrubbed]
/// * [trackedTasks]
/// * [trackedDone]
/// * [trackedCancelled]
/// * [trackedPending]
/// * [trackedUnavailable]
/// * [trackedCleanupState]
@BuiltValue()
abstract class OpsAccountErasure
    implements Built<OpsAccountErasure, OpsAccountErasureBuilder> {
  @BuiltValueField(wireName: r'userId')
  String get userId;

  @BuiltValueField(wireName: r'erasedAt')
  DateTime get erasedAt;

  @BuiltValueField(wireName: r'sessionsRevoked')
  int get sessionsRevoked;

  @BuiltValueField(wireName: r'devicesRevoked')
  int get devicesRevoked;

  @BuiltValueField(wireName: r'identitiesScrubbed')
  int get identitiesScrubbed;

  @BuiltValueField(wireName: r'trackedTasks')
  int get trackedTasks;

  @BuiltValueField(wireName: r'trackedDone')
  int get trackedDone;

  @BuiltValueField(wireName: r'trackedCancelled')
  int get trackedCancelled;

  @BuiltValueField(wireName: r'trackedPending')
  int get trackedPending;

  @BuiltValueField(wireName: r'trackedUnavailable')
  int get trackedUnavailable;

  @BuiltValueField(wireName: r'trackedCleanupState')
  OpsAccountErasureTrackedCleanupStateEnum get trackedCleanupState;
  // enum trackedCleanupStateEnum {  pending,  retry_needed,  tracked_complete,  };

  OpsAccountErasure._();

  factory OpsAccountErasure([void updates(OpsAccountErasureBuilder b)]) =
      _$OpsAccountErasure;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsAccountErasureBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsAccountErasure> get serializer =>
      _$OpsAccountErasureSerializer();
}

class _$OpsAccountErasureSerializer
    implements PrimitiveSerializer<OpsAccountErasure> {
  @override
  final Iterable<Type> types = const [OpsAccountErasure, _$OpsAccountErasure];

  @override
  final String wireName = r'OpsAccountErasure';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsAccountErasure object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'userId';
    yield serializers.serialize(
      object.userId,
      specifiedType: const FullType(String),
    );
    yield r'erasedAt';
    yield serializers.serialize(
      object.erasedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'sessionsRevoked';
    yield serializers.serialize(
      object.sessionsRevoked,
      specifiedType: const FullType(int),
    );
    yield r'devicesRevoked';
    yield serializers.serialize(
      object.devicesRevoked,
      specifiedType: const FullType(int),
    );
    yield r'identitiesScrubbed';
    yield serializers.serialize(
      object.identitiesScrubbed,
      specifiedType: const FullType(int),
    );
    yield r'trackedTasks';
    yield serializers.serialize(
      object.trackedTasks,
      specifiedType: const FullType(int),
    );
    yield r'trackedDone';
    yield serializers.serialize(
      object.trackedDone,
      specifiedType: const FullType(int),
    );
    yield r'trackedCancelled';
    yield serializers.serialize(
      object.trackedCancelled,
      specifiedType: const FullType(int),
    );
    yield r'trackedPending';
    yield serializers.serialize(
      object.trackedPending,
      specifiedType: const FullType(int),
    );
    yield r'trackedUnavailable';
    yield serializers.serialize(
      object.trackedUnavailable,
      specifiedType: const FullType(int),
    );
    yield r'trackedCleanupState';
    yield serializers.serialize(
      object.trackedCleanupState,
      specifiedType: const FullType(OpsAccountErasureTrackedCleanupStateEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsAccountErasure object, {
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
    required OpsAccountErasureBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'userId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.userId = valueDes;
          break;
        case r'erasedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.erasedAt = valueDes;
          break;
        case r'sessionsRevoked':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.sessionsRevoked = valueDes;
          break;
        case r'devicesRevoked':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.devicesRevoked = valueDes;
          break;
        case r'identitiesScrubbed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.identitiesScrubbed = valueDes;
          break;
        case r'trackedTasks':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.trackedTasks = valueDes;
          break;
        case r'trackedDone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.trackedDone = valueDes;
          break;
        case r'trackedCancelled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.trackedCancelled = valueDes;
          break;
        case r'trackedPending':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.trackedPending = valueDes;
          break;
        case r'trackedUnavailable':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.trackedUnavailable = valueDes;
          break;
        case r'trackedCleanupState':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(OpsAccountErasureTrackedCleanupStateEnum),
          ) as OpsAccountErasureTrackedCleanupStateEnum;
          result.trackedCleanupState = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OpsAccountErasure deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsAccountErasureBuilder();
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

class OpsAccountErasureTrackedCleanupStateEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'pending')
  static const OpsAccountErasureTrackedCleanupStateEnum pending =
      _$opsAccountErasureTrackedCleanupStateEnum_pending;
  @BuiltValueEnumConst(wireName: r'retry_needed')
  static const OpsAccountErasureTrackedCleanupStateEnum retryNeeded =
      _$opsAccountErasureTrackedCleanupStateEnum_retryNeeded;
  @BuiltValueEnumConst(wireName: r'tracked_complete')
  static const OpsAccountErasureTrackedCleanupStateEnum trackedComplete =
      _$opsAccountErasureTrackedCleanupStateEnum_trackedComplete;

  static Serializer<OpsAccountErasureTrackedCleanupStateEnum> get serializer =>
      _$opsAccountErasureTrackedCleanupStateEnumSerializer;

  const OpsAccountErasureTrackedCleanupStateEnum._(String name) : super(name);

  static BuiltSet<OpsAccountErasureTrackedCleanupStateEnum> get values =>
      _$opsAccountErasureTrackedCleanupStateEnumValues;
  static OpsAccountErasureTrackedCleanupStateEnum valueOf(String name) =>
      _$opsAccountErasureTrackedCleanupStateEnumValueOf(name);
}

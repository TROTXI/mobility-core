//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_operator.g.dart';

/// OpsOperator
///
/// Properties:
/// * [id]
/// * [displayName]
/// * [email]
/// * [passkeyCount]
/// * [activeSessions]
/// * [lastPasskeyUsedAt]
/// * [joinedAt]
/// * [editToken]
@BuiltValue()
abstract class OpsOperator implements Built<OpsOperator, OpsOperatorBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'displayName')
  String get displayName;

  @BuiltValueField(wireName: r'email')
  String? get email;

  @BuiltValueField(wireName: r'passkeyCount')
  int get passkeyCount;

  @BuiltValueField(wireName: r'activeSessions')
  int get activeSessions;

  @BuiltValueField(wireName: r'lastPasskeyUsedAt')
  DateTime? get lastPasskeyUsedAt;

  @BuiltValueField(wireName: r'joinedAt')
  DateTime get joinedAt;

  @BuiltValueField(wireName: r'editToken')
  String get editToken;

  OpsOperator._();

  factory OpsOperator([void updates(OpsOperatorBuilder b)]) = _$OpsOperator;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsOperatorBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsOperator> get serializer => _$OpsOperatorSerializer();
}

class _$OpsOperatorSerializer implements PrimitiveSerializer<OpsOperator> {
  @override
  final Iterable<Type> types = const [OpsOperator, _$OpsOperator];

  @override
  final String wireName = r'OpsOperator';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsOperator object, {
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
    yield r'email';
    yield object.email == null
        ? null
        : serializers.serialize(
            object.email,
            specifiedType: const FullType.nullable(String),
          );
    yield r'passkeyCount';
    yield serializers.serialize(
      object.passkeyCount,
      specifiedType: const FullType(int),
    );
    yield r'activeSessions';
    yield serializers.serialize(
      object.activeSessions,
      specifiedType: const FullType(int),
    );
    yield r'lastPasskeyUsedAt';
    yield object.lastPasskeyUsedAt == null
        ? null
        : serializers.serialize(
            object.lastPasskeyUsedAt,
            specifiedType: const FullType.nullable(DateTime),
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
    OpsOperator object, {
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
    required OpsOperatorBuilder result,
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
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.email = valueDes;
          break;
        case r'passkeyCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.passkeyCount = valueDes;
          break;
        case r'activeSessions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.activeSessions = valueDes;
          break;
        case r'lastPasskeyUsedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.lastPasskeyUsedAt = valueDes;
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
  OpsOperator deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsOperatorBuilder();
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

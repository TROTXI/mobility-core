//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/maintenance_result_failures_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'maintenance_result.g.dart';

/// MaintenanceResult
///
/// Properties:
/// * [considered] 
/// * [succeeded] 
/// * [blocked] 
/// * [failed] 
/// * [failures] 
@BuiltValue()
abstract class MaintenanceResult implements Built<MaintenanceResult, MaintenanceResultBuilder> {
  @BuiltValueField(wireName: r'considered')
  int get considered;

  @BuiltValueField(wireName: r'succeeded')
  int get succeeded;

  @BuiltValueField(wireName: r'blocked')
  int get blocked;

  @BuiltValueField(wireName: r'failed')
  int get failed;

  @BuiltValueField(wireName: r'failures')
  BuiltList<MaintenanceResultFailuresInner> get failures;

  MaintenanceResult._();

  factory MaintenanceResult([void updates(MaintenanceResultBuilder b)]) = _$MaintenanceResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MaintenanceResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MaintenanceResult> get serializer => _$MaintenanceResultSerializer();
}

class _$MaintenanceResultSerializer implements PrimitiveSerializer<MaintenanceResult> {
  @override
  final Iterable<Type> types = const [MaintenanceResult, _$MaintenanceResult];

  @override
  final String wireName = r'MaintenanceResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MaintenanceResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'considered';
    yield serializers.serialize(
      object.considered,
      specifiedType: const FullType(int),
    );
    yield r'succeeded';
    yield serializers.serialize(
      object.succeeded,
      specifiedType: const FullType(int),
    );
    yield r'blocked';
    yield serializers.serialize(
      object.blocked,
      specifiedType: const FullType(int),
    );
    yield r'failed';
    yield serializers.serialize(
      object.failed,
      specifiedType: const FullType(int),
    );
    yield r'failures';
    yield serializers.serialize(
      object.failures,
      specifiedType: const FullType(BuiltList, [FullType(MaintenanceResultFailuresInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MaintenanceResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MaintenanceResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'considered':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.considered = valueDes;
          break;
        case r'succeeded':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.succeeded = valueDes;
          break;
        case r'blocked':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.blocked = valueDes;
          break;
        case r'failed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.failed = valueDes;
          break;
        case r'failures':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(MaintenanceResultFailuresInner)]),
          ) as BuiltList<MaintenanceResultFailuresInner>;
          result.failures.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MaintenanceResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MaintenanceResultBuilder();
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


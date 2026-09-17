//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'maintenance_result_failures_inner.g.dart';

/// MaintenanceResultFailuresInner
///
/// Properties:
/// * [resourceId] 
/// * [reason] 
@BuiltValue()
abstract class MaintenanceResultFailuresInner implements Built<MaintenanceResultFailuresInner, MaintenanceResultFailuresInnerBuilder> {
  @BuiltValueField(wireName: r'resourceId')
  String get resourceId;

  @BuiltValueField(wireName: r'reason')
  String get reason;

  MaintenanceResultFailuresInner._();

  factory MaintenanceResultFailuresInner([void updates(MaintenanceResultFailuresInnerBuilder b)]) = _$MaintenanceResultFailuresInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MaintenanceResultFailuresInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MaintenanceResultFailuresInner> get serializer => _$MaintenanceResultFailuresInnerSerializer();
}

class _$MaintenanceResultFailuresInnerSerializer implements PrimitiveSerializer<MaintenanceResultFailuresInner> {
  @override
  final Iterable<Type> types = const [MaintenanceResultFailuresInner, _$MaintenanceResultFailuresInner];

  @override
  final String wireName = r'MaintenanceResultFailuresInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MaintenanceResultFailuresInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'resourceId';
    yield serializers.serialize(
      object.resourceId,
      specifiedType: const FullType(String),
    );
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MaintenanceResultFailuresInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MaintenanceResultFailuresInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'resourceId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.resourceId = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MaintenanceResultFailuresInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MaintenanceResultFailuresInnerBuilder();
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


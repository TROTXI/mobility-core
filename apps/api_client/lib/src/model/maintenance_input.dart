//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'maintenance_input.g.dart';

/// MaintenanceInput
///
/// Properties:
/// * [limit] 
@BuiltValue()
abstract class MaintenanceInput implements Built<MaintenanceInput, MaintenanceInputBuilder> {
  @BuiltValueField(wireName: r'limit')
  int get limit;

  MaintenanceInput._();

  factory MaintenanceInput([void updates(MaintenanceInputBuilder b)]) = _$MaintenanceInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MaintenanceInputBuilder b) => b
      ..limit = 100;

  @BuiltValueSerializer(custom: true)
  static Serializer<MaintenanceInput> get serializer => _$MaintenanceInputSerializer();
}

class _$MaintenanceInputSerializer implements PrimitiveSerializer<MaintenanceInput> {
  @override
  final Iterable<Type> types = const [MaintenanceInput, _$MaintenanceInput];

  @override
  final String wireName = r'MaintenanceInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MaintenanceInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'limit';
    yield serializers.serialize(
      object.limit,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MaintenanceInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MaintenanceInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'limit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.limit = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MaintenanceInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MaintenanceInputBuilder();
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


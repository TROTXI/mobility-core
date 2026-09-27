//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'position_input.g.dart';

/// PositionInput
///
/// Properties:
/// * [clientFixId] 
/// * [capturedAt] 
/// * [latitude] 
/// * [longitude] 
/// * [accuracyMeters] 
@BuiltValue()
abstract class PositionInput implements Built<PositionInput, PositionInputBuilder> {
  @BuiltValueField(wireName: r'clientFixId')
  String get clientFixId;

  @BuiltValueField(wireName: r'capturedAt')
  DateTime get capturedAt;

  @BuiltValueField(wireName: r'latitude')
  num get latitude;

  @BuiltValueField(wireName: r'longitude')
  num get longitude;

  @BuiltValueField(wireName: r'accuracyMeters')
  num? get accuracyMeters;

  PositionInput._();

  factory PositionInput([void updates(PositionInputBuilder b)]) = _$PositionInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PositionInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PositionInput> get serializer => _$PositionInputSerializer();
}

class _$PositionInputSerializer implements PrimitiveSerializer<PositionInput> {
  @override
  final Iterable<Type> types = const [PositionInput, _$PositionInput];

  @override
  final String wireName = r'PositionInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PositionInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'clientFixId';
    yield serializers.serialize(
      object.clientFixId,
      specifiedType: const FullType(String),
    );
    yield r'capturedAt';
    yield serializers.serialize(
      object.capturedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'latitude';
    yield serializers.serialize(
      object.latitude,
      specifiedType: const FullType(num),
    );
    yield r'longitude';
    yield serializers.serialize(
      object.longitude,
      specifiedType: const FullType(num),
    );
    if (object.accuracyMeters != null) {
      yield r'accuracyMeters';
      yield serializers.serialize(
        object.accuracyMeters,
        specifiedType: const FullType(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PositionInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PositionInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'clientFixId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientFixId = valueDes;
          break;
        case r'capturedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.capturedAt = valueDes;
          break;
        case r'latitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.latitude = valueDes;
          break;
        case r'longitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.longitude = valueDes;
          break;
        case r'accuracyMeters':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.accuracyMeters = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PositionInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PositionInputBuilder();
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


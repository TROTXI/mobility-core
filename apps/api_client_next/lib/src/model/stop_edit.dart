//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/point.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'stop_edit.g.dart';

/// StopEdit
///
/// Properties:
/// * [name] 
/// * [location] 
/// * [archived] 
@BuiltValue()
abstract class StopEdit implements Built<StopEdit, StopEditBuilder> {
  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'location')
  Point? get location;

  @BuiltValueField(wireName: r'archived')
  bool? get archived;

  StopEdit._();

  factory StopEdit([void updates(StopEditBuilder b)]) = _$StopEdit;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StopEditBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StopEdit> get serializer => _$StopEditSerializer();
}

class _$StopEditSerializer implements PrimitiveSerializer<StopEdit> {
  @override
  final Iterable<Type> types = const [StopEdit, _$StopEdit];

  @override
  final String wireName = r'StopEdit';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StopEdit object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.location != null) {
      yield r'location';
      yield serializers.serialize(
        object.location,
        specifiedType: const FullType(Point),
      );
    }
    if (object.archived != null) {
      yield r'archived';
      yield serializers.serialize(
        object.archived,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    StopEdit object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required StopEditBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'location':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Point),
          ) as Point;
          result.location.replace(valueDes);
          break;
        case r'archived':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.archived = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  StopEdit deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StopEditBuilder();
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


//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'trace_hold_input.g.dart';

/// TraceHoldInput
///
/// Properties:
/// * [incidentId] 
/// * [tripId] 
/// * [receivedFrom] 
/// * [receivedTo] 
/// * [reason] 
/// * [reviewAt] 
@BuiltValue()
abstract class TraceHoldInput implements Built<TraceHoldInput, TraceHoldInputBuilder> {
  @BuiltValueField(wireName: r'incidentId')
  String get incidentId;

  @BuiltValueField(wireName: r'tripId')
  String get tripId;

  @BuiltValueField(wireName: r'receivedFrom')
  DateTime get receivedFrom;

  @BuiltValueField(wireName: r'receivedTo')
  DateTime get receivedTo;

  @BuiltValueField(wireName: r'reason')
  String get reason;

  @BuiltValueField(wireName: r'reviewAt')
  DateTime get reviewAt;

  TraceHoldInput._();

  factory TraceHoldInput([void updates(TraceHoldInputBuilder b)]) = _$TraceHoldInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TraceHoldInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TraceHoldInput> get serializer => _$TraceHoldInputSerializer();
}

class _$TraceHoldInputSerializer implements PrimitiveSerializer<TraceHoldInput> {
  @override
  final Iterable<Type> types = const [TraceHoldInput, _$TraceHoldInput];

  @override
  final String wireName = r'TraceHoldInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TraceHoldInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'incidentId';
    yield serializers.serialize(
      object.incidentId,
      specifiedType: const FullType(String),
    );
    yield r'tripId';
    yield serializers.serialize(
      object.tripId,
      specifiedType: const FullType(String),
    );
    yield r'receivedFrom';
    yield serializers.serialize(
      object.receivedFrom,
      specifiedType: const FullType(DateTime),
    );
    yield r'receivedTo';
    yield serializers.serialize(
      object.receivedTo,
      specifiedType: const FullType(DateTime),
    );
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
    yield r'reviewAt';
    yield serializers.serialize(
      object.reviewAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TraceHoldInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TraceHoldInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'incidentId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.incidentId = valueDes;
          break;
        case r'tripId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.tripId = valueDes;
          break;
        case r'receivedFrom':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.receivedFrom = valueDes;
          break;
        case r'receivedTo':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.receivedTo = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reason = valueDes;
          break;
        case r'reviewAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.reviewAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TraceHoldInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TraceHoldInputBuilder();
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


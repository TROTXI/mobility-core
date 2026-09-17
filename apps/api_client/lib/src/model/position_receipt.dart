//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'position_receipt.g.dart';

/// PositionReceipt
///
/// Properties:
/// * [clientFixId] 
/// * [receivedAt] 
/// * [capturedAt] 
/// * [effectiveCapturedAt] 
/// * [acceptedForLive] 
/// * [clockAdjusted] 
@BuiltValue()
abstract class PositionReceipt implements Built<PositionReceipt, PositionReceiptBuilder> {
  @BuiltValueField(wireName: r'clientFixId')
  String get clientFixId;

  @BuiltValueField(wireName: r'receivedAt')
  DateTime get receivedAt;

  @BuiltValueField(wireName: r'capturedAt')
  DateTime get capturedAt;

  @BuiltValueField(wireName: r'effectiveCapturedAt')
  DateTime get effectiveCapturedAt;

  @BuiltValueField(wireName: r'acceptedForLive')
  bool get acceptedForLive;

  @BuiltValueField(wireName: r'clockAdjusted')
  bool get clockAdjusted;

  PositionReceipt._();

  factory PositionReceipt([void updates(PositionReceiptBuilder b)]) = _$PositionReceipt;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PositionReceiptBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PositionReceipt> get serializer => _$PositionReceiptSerializer();
}

class _$PositionReceiptSerializer implements PrimitiveSerializer<PositionReceipt> {
  @override
  final Iterable<Type> types = const [PositionReceipt, _$PositionReceipt];

  @override
  final String wireName = r'PositionReceipt';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PositionReceipt object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'clientFixId';
    yield serializers.serialize(
      object.clientFixId,
      specifiedType: const FullType(String),
    );
    yield r'receivedAt';
    yield serializers.serialize(
      object.receivedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'capturedAt';
    yield serializers.serialize(
      object.capturedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'effectiveCapturedAt';
    yield serializers.serialize(
      object.effectiveCapturedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'acceptedForLive';
    yield serializers.serialize(
      object.acceptedForLive,
      specifiedType: const FullType(bool),
    );
    yield r'clockAdjusted';
    yield serializers.serialize(
      object.clockAdjusted,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PositionReceipt object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PositionReceiptBuilder result,
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
        case r'receivedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.receivedAt = valueDes;
          break;
        case r'capturedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.capturedAt = valueDes;
          break;
        case r'effectiveCapturedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.effectiveCapturedAt = valueDes;
          break;
        case r'acceptedForLive':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.acceptedForLive = valueDes;
          break;
        case r'clockAdjusted':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.clockAdjusted = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PositionReceipt deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PositionReceiptBuilder();
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


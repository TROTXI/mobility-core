//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/commute_slot.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commute_slot_response.g.dart';

/// CommuteSlotResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class CommuteSlotResponse implements Built<CommuteSlotResponse, CommuteSlotResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  CommuteSlot get data;

  CommuteSlotResponse._();

  factory CommuteSlotResponse([void updates(CommuteSlotResponseBuilder b)]) = _$CommuteSlotResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommuteSlotResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommuteSlotResponse> get serializer => _$CommuteSlotResponseSerializer();
}

class _$CommuteSlotResponseSerializer implements PrimitiveSerializer<CommuteSlotResponse> {
  @override
  final Iterable<Type> types = const [CommuteSlotResponse, _$CommuteSlotResponse];

  @override
  final String wireName = r'CommuteSlotResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommuteSlotResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(CommuteSlot),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CommuteSlotResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CommuteSlotResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CommuteSlot),
          ) as CommuteSlot;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CommuteSlotResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommuteSlotResponseBuilder();
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


//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/commute_leg.dart';
import 'package:trotxi_api_client_next/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commute_slot_input.g.dart';

/// CommuteSlotInput
///
/// Properties:
/// * [routeId] 
/// * [legs] 
/// * [availableFrom] 
@BuiltValue()
abstract class CommuteSlotInput implements Built<CommuteSlotInput, CommuteSlotInputBuilder> {
  @BuiltValueField(wireName: r'routeId')
  String get routeId;

  @BuiltValueField(wireName: r'legs')
  BuiltList<CommuteLeg> get legs;

  @BuiltValueField(wireName: r'availableFrom')
  Date get availableFrom;

  CommuteSlotInput._();

  factory CommuteSlotInput([void updates(CommuteSlotInputBuilder b)]) = _$CommuteSlotInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommuteSlotInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommuteSlotInput> get serializer => _$CommuteSlotInputSerializer();
}

class _$CommuteSlotInputSerializer implements PrimitiveSerializer<CommuteSlotInput> {
  @override
  final Iterable<Type> types = const [CommuteSlotInput, _$CommuteSlotInput];

  @override
  final String wireName = r'CommuteSlotInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommuteSlotInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'routeId';
    yield serializers.serialize(
      object.routeId,
      specifiedType: const FullType(String),
    );
    yield r'legs';
    yield serializers.serialize(
      object.legs,
      specifiedType: const FullType(BuiltList, [FullType(CommuteLeg)]),
    );
    yield r'availableFrom';
    yield serializers.serialize(
      object.availableFrom,
      specifiedType: const FullType(Date),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CommuteSlotInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CommuteSlotInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'routeId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.routeId = valueDes;
          break;
        case r'legs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(CommuteLeg)]),
          ) as BuiltList<CommuteLeg>;
          result.legs.replace(valueDes);
          break;
        case r'availableFrom':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.availableFrom = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CommuteSlotInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommuteSlotInputBuilder();
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


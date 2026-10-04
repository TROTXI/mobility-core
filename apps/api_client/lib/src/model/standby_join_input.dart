//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/purchase_input.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'standby_join_input.g.dart';

/// StandbyJoinInput
///
/// Properties:
/// * [selection]
/// * [travelDays]
@BuiltValue()
abstract class StandbyJoinInput
    implements Built<StandbyJoinInput, StandbyJoinInputBuilder> {
  @BuiltValueField(wireName: r'selection')
  PurchaseInput get selection;

  @BuiltValueField(wireName: r'travelDays')
  BuiltList<int> get travelDays;

  StandbyJoinInput._();

  factory StandbyJoinInput([void updates(StandbyJoinInputBuilder b)]) =
      _$StandbyJoinInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StandbyJoinInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StandbyJoinInput> get serializer =>
      _$StandbyJoinInputSerializer();
}

class _$StandbyJoinInputSerializer
    implements PrimitiveSerializer<StandbyJoinInput> {
  @override
  final Iterable<Type> types = const [StandbyJoinInput, _$StandbyJoinInput];

  @override
  final String wireName = r'StandbyJoinInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StandbyJoinInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'selection';
    yield serializers.serialize(
      object.selection,
      specifiedType: const FullType(PurchaseInput),
    );
    yield r'travelDays';
    yield serializers.serialize(
      object.travelDays,
      specifiedType: const FullType(BuiltList, [FullType(int)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    StandbyJoinInput object, {
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
    required StandbyJoinInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'selection':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PurchaseInput),
          ) as PurchaseInput;
          result.selection.replace(valueDes);
          break;
        case r'travelDays':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(int)]),
          ) as BuiltList<int>;
          result.travelDays.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  StandbyJoinInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StandbyJoinInputBuilder();
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

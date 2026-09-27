//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/money.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'refund_initiation_input.g.dart';

/// RefundInitiationInput
///
/// Properties:
<<<<<<< HEAD
/// * [amount] 
/// * [reason] 
@BuiltValue()
abstract class RefundInitiationInput implements Built<RefundInitiationInput, RefundInitiationInputBuilder> {
=======
/// * [amount]
/// * [reason]
@BuiltValue()
abstract class RefundInitiationInput
    implements Built<RefundInitiationInput, RefundInitiationInputBuilder> {
>>>>>>> origin/main
  @BuiltValueField(wireName: r'amount')
  Money get amount;

  @BuiltValueField(wireName: r'reason')
  String get reason;

  RefundInitiationInput._();

<<<<<<< HEAD
  factory RefundInitiationInput([void updates(RefundInitiationInputBuilder b)]) = _$RefundInitiationInput;
=======
  factory RefundInitiationInput(
      [void updates(RefundInitiationInputBuilder b)]) = _$RefundInitiationInput;
>>>>>>> origin/main

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RefundInitiationInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
<<<<<<< HEAD
  static Serializer<RefundInitiationInput> get serializer => _$RefundInitiationInputSerializer();
}

class _$RefundInitiationInputSerializer implements PrimitiveSerializer<RefundInitiationInput> {
  @override
  final Iterable<Type> types = const [RefundInitiationInput, _$RefundInitiationInput];
=======
  static Serializer<RefundInitiationInput> get serializer =>
      _$RefundInitiationInputSerializer();
}

class _$RefundInitiationInputSerializer
    implements PrimitiveSerializer<RefundInitiationInput> {
  @override
  final Iterable<Type> types = const [
    RefundInitiationInput,
    _$RefundInitiationInput
  ];
>>>>>>> origin/main

  @override
  final String wireName = r'RefundInitiationInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RefundInitiationInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(Money),
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
    RefundInitiationInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
<<<<<<< HEAD
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
=======
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
>>>>>>> origin/main
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RefundInitiationInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Money),
          ) as Money;
          result.amount.replace(valueDes);
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
  RefundInitiationInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RefundInitiationInputBuilder();
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
<<<<<<< HEAD

=======
>>>>>>> origin/main

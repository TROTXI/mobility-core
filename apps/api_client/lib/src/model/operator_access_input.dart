//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'operator_access_input.g.dart';

/// OperatorAccessInput
///
/// Properties:
/// * [action]
@BuiltValue()
abstract class OperatorAccessInput
    implements Built<OperatorAccessInput, OperatorAccessInputBuilder> {
  @BuiltValueField(wireName: r'action')
  OperatorAccessInputActionEnum get action;
  // enum actionEnum {  delete,  make_superadmin,  make_admin,  };

  OperatorAccessInput._();

  factory OperatorAccessInput([void updates(OperatorAccessInputBuilder b)]) =
      _$OperatorAccessInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OperatorAccessInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OperatorAccessInput> get serializer =>
      _$OperatorAccessInputSerializer();
}

class _$OperatorAccessInputSerializer
    implements PrimitiveSerializer<OperatorAccessInput> {
  @override
  final Iterable<Type> types = const [
    OperatorAccessInput,
    _$OperatorAccessInput
  ];

  @override
  final String wireName = r'OperatorAccessInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OperatorAccessInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'action';
    yield serializers.serialize(
      object.action,
      specifiedType: const FullType(OperatorAccessInputActionEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OperatorAccessInput object, {
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
    required OperatorAccessInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OperatorAccessInputActionEnum),
          ) as OperatorAccessInputActionEnum;
          result.action = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OperatorAccessInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OperatorAccessInputBuilder();
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

class OperatorAccessInputActionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'delete')
  static const OperatorAccessInputActionEnum delete =
      _$operatorAccessInputActionEnum_delete;
  @BuiltValueEnumConst(wireName: r'make_superadmin')
  static const OperatorAccessInputActionEnum makeSuperadmin =
      _$operatorAccessInputActionEnum_makeSuperadmin;
  @BuiltValueEnumConst(wireName: r'make_admin')
  static const OperatorAccessInputActionEnum makeAdmin =
      _$operatorAccessInputActionEnum_makeAdmin;

  static Serializer<OperatorAccessInputActionEnum> get serializer =>
      _$operatorAccessInputActionEnumSerializer;

  const OperatorAccessInputActionEnum._(String name) : super(name);

  static BuiltSet<OperatorAccessInputActionEnum> get values =>
      _$operatorAccessInputActionEnumValues;
  static OperatorAccessInputActionEnum valueOf(String name) =>
      _$operatorAccessInputActionEnumValueOf(name);
}

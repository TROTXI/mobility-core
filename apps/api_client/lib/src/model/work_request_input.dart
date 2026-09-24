//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/work_request_input_one_of.dart';
import 'package:trotxi_api_client/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/work_request_input_one_of1.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/one_of.dart';

part 'work_request_input.g.dart';

/// WorkRequestInput
///
/// Properties:
/// * [kind]
/// * [routeId]
/// * [fromDate]
/// * [note]
/// * [toDate]
@BuiltValue()
abstract class WorkRequestInput
    implements Built<WorkRequestInput, WorkRequestInputBuilder> {
  /// One Of [WorkRequestInputOneOf], [WorkRequestInputOneOf1]
  OneOf get oneOf;

  WorkRequestInput._();

  factory WorkRequestInput([void updates(WorkRequestInputBuilder b)]) =
      _$WorkRequestInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WorkRequestInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WorkRequestInput> get serializer =>
      _$WorkRequestInputSerializer();
}

class _$WorkRequestInputSerializer
    implements PrimitiveSerializer<WorkRequestInput> {
  @override
  final Iterable<Type> types = const [WorkRequestInput, _$WorkRequestInput];

  @override
  final String wireName = r'WorkRequestInput';

  Iterable<Object?> _serializeProperties(
      Serializers serializers, WorkRequestInput object) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    WorkRequestInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final oneOf = object.oneOf;
    return serializers.serialize(oneOf.value,
        specifiedType: FullType(oneOf.valueType))!;
  }

  @override
  WorkRequestInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WorkRequestInputBuilder();
    Object? oneOfDataSrc;
    final targetType = const FullType(OneOf, [
      FullType(WorkRequestInputOneOf),
      FullType(WorkRequestInputOneOf1),
    ]);
    oneOfDataSrc = serialized;
    result.oneOf = serializers.deserialize(oneOfDataSrc,
        specifiedType: targetType) as OneOf;
    return result.build();
  }
}

class WorkRequestInputKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'leave')
  static const WorkRequestInputKindEnum leave =
      _$workRequestInputKindEnum_leave;

  static Serializer<WorkRequestInputKindEnum> get serializer =>
      _$workRequestInputKindEnumSerializer;

  const WorkRequestInputKindEnum._(String name) : super(name);

  static BuiltSet<WorkRequestInputKindEnum> get values =>
      _$workRequestInputKindEnumValues;
  static WorkRequestInputKindEnum valueOf(String name) =>
      _$workRequestInputKindEnumValueOf(name);
}

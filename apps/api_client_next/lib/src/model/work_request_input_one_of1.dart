//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'work_request_input_one_of1.g.dart';

/// WorkRequestInputOneOf1
///
/// Properties:
/// * [kind] 
/// * [fromDate] 
/// * [toDate] 
/// * [note] 
@BuiltValue()
abstract class WorkRequestInputOneOf1 implements Built<WorkRequestInputOneOf1, WorkRequestInputOneOf1Builder> {
  @BuiltValueField(wireName: r'kind')
  WorkRequestInputOneOf1KindEnum get kind;
  // enum kindEnum {  leave,  };

  @BuiltValueField(wireName: r'fromDate')
  Date get fromDate;

  @BuiltValueField(wireName: r'toDate')
  Date get toDate;

  @BuiltValueField(wireName: r'note')
  String? get note;

  WorkRequestInputOneOf1._();

  factory WorkRequestInputOneOf1([void updates(WorkRequestInputOneOf1Builder b)]) = _$WorkRequestInputOneOf1;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WorkRequestInputOneOf1Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WorkRequestInputOneOf1> get serializer => _$WorkRequestInputOneOf1Serializer();
}

class _$WorkRequestInputOneOf1Serializer implements PrimitiveSerializer<WorkRequestInputOneOf1> {
  @override
  final Iterable<Type> types = const [WorkRequestInputOneOf1, _$WorkRequestInputOneOf1];

  @override
  final String wireName = r'WorkRequestInputOneOf1';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WorkRequestInputOneOf1 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(WorkRequestInputOneOf1KindEnum),
    );
    yield r'fromDate';
    yield serializers.serialize(
      object.fromDate,
      specifiedType: const FullType(Date),
    );
    yield r'toDate';
    yield serializers.serialize(
      object.toDate,
      specifiedType: const FullType(Date),
    );
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    WorkRequestInputOneOf1 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WorkRequestInputOneOf1Builder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(WorkRequestInputOneOf1KindEnum),
          ) as WorkRequestInputOneOf1KindEnum;
          result.kind = valueDes;
          break;
        case r'fromDate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.fromDate = valueDes;
          break;
        case r'toDate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.toDate = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.note = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WorkRequestInputOneOf1 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WorkRequestInputOneOf1Builder();
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

class WorkRequestInputOneOf1KindEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'leave')
  static const WorkRequestInputOneOf1KindEnum leave = _$workRequestInputOneOf1KindEnum_leave;

  static Serializer<WorkRequestInputOneOf1KindEnum> get serializer => _$workRequestInputOneOf1KindEnumSerializer;

  const WorkRequestInputOneOf1KindEnum._(String name): super(name);

  static BuiltSet<WorkRequestInputOneOf1KindEnum> get values => _$workRequestInputOneOf1KindEnumValues;
  static WorkRequestInputOneOf1KindEnum valueOf(String name) => _$workRequestInputOneOf1KindEnumValueOf(name);
}


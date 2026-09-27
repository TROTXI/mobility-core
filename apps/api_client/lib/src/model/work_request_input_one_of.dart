//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'work_request_input_one_of.g.dart';

/// WorkRequestInputOneOf
///
/// Properties:
/// * [kind] 
/// * [routeId] 
/// * [fromDate] 
/// * [note] 
@BuiltValue()
abstract class WorkRequestInputOneOf implements Built<WorkRequestInputOneOf, WorkRequestInputOneOfBuilder> {
  @BuiltValueField(wireName: r'kind')
  WorkRequestInputOneOfKindEnum get kind;
  // enum kindEnum {  route_change,  };

  @BuiltValueField(wireName: r'routeId')
  String get routeId;

  @BuiltValueField(wireName: r'fromDate')
  Date? get fromDate;

  @BuiltValueField(wireName: r'note')
  String? get note;

  WorkRequestInputOneOf._();

  factory WorkRequestInputOneOf([void updates(WorkRequestInputOneOfBuilder b)]) = _$WorkRequestInputOneOf;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WorkRequestInputOneOfBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WorkRequestInputOneOf> get serializer => _$WorkRequestInputOneOfSerializer();
}

class _$WorkRequestInputOneOfSerializer implements PrimitiveSerializer<WorkRequestInputOneOf> {
  @override
  final Iterable<Type> types = const [WorkRequestInputOneOf, _$WorkRequestInputOneOf];

  @override
  final String wireName = r'WorkRequestInputOneOf';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WorkRequestInputOneOf object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(WorkRequestInputOneOfKindEnum),
    );
    yield r'routeId';
    yield serializers.serialize(
      object.routeId,
      specifiedType: const FullType(String),
    );
    if (object.fromDate != null) {
      yield r'fromDate';
      yield serializers.serialize(
        object.fromDate,
        specifiedType: const FullType(Date),
      );
    }
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
    WorkRequestInputOneOf object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WorkRequestInputOneOfBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(WorkRequestInputOneOfKindEnum),
          ) as WorkRequestInputOneOfKindEnum;
          result.kind = valueDes;
          break;
        case r'routeId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.routeId = valueDes;
          break;
        case r'fromDate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.fromDate = valueDes;
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
  WorkRequestInputOneOf deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WorkRequestInputOneOfBuilder();
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

class WorkRequestInputOneOfKindEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'route_change')
  static const WorkRequestInputOneOfKindEnum routeChange = _$workRequestInputOneOfKindEnum_routeChange;

  static Serializer<WorkRequestInputOneOfKindEnum> get serializer => _$workRequestInputOneOfKindEnumSerializer;

  const WorkRequestInputOneOfKindEnum._(String name): super(name);

  static BuiltSet<WorkRequestInputOneOfKindEnum> get values => _$workRequestInputOneOfKindEnumValues;
  static WorkRequestInputOneOfKindEnum valueOf(String name) => _$workRequestInputOneOfKindEnumValueOf(name);
}


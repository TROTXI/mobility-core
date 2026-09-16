//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/schedule_input_departure_one_of.dart';
import 'package:trotxi_api_client/src/model/schedule_input_departure_one_of1.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/one_of.dart';

part 'schedule_input_departure.g.dart';

/// ScheduleInputDeparture
///
/// Properties:
/// * [kind] 
/// * [departureId] 
@BuiltValue()
abstract class ScheduleInputDeparture implements Built<ScheduleInputDeparture, ScheduleInputDepartureBuilder> {
  /// One Of [ScheduleInputDepartureOneOf], [ScheduleInputDepartureOneOf1]
  OneOf get oneOf;

  ScheduleInputDeparture._();

  factory ScheduleInputDeparture([void updates(ScheduleInputDepartureBuilder b)]) = _$ScheduleInputDeparture;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ScheduleInputDepartureBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ScheduleInputDeparture> get serializer => _$ScheduleInputDepartureSerializer();
}

class _$ScheduleInputDepartureSerializer implements PrimitiveSerializer<ScheduleInputDeparture> {
  @override
  final Iterable<Type> types = const [ScheduleInputDeparture, _$ScheduleInputDeparture];

  @override
  final String wireName = r'ScheduleInputDeparture';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ScheduleInputDeparture object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    ScheduleInputDeparture object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final oneOf = object.oneOf;
    return serializers.serialize(oneOf.value, specifiedType: FullType(oneOf.valueType))!;
  }

  @override
  ScheduleInputDeparture deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ScheduleInputDepartureBuilder();
    Object? oneOfDataSrc;
    final targetType = const FullType(OneOf, [FullType(ScheduleInputDepartureOneOf), FullType(ScheduleInputDepartureOneOf1), ]);
    oneOfDataSrc = serialized;
    result.oneOf = serializers.deserialize(oneOfDataSrc, specifiedType: targetType) as OneOf;
    return result.build();
  }
}

class ScheduleInputDepartureKindEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'existing')
  static const ScheduleInputDepartureKindEnum existing = _$scheduleInputDepartureKindEnum_existing;

  static Serializer<ScheduleInputDepartureKindEnum> get serializer => _$scheduleInputDepartureKindEnumSerializer;

  const ScheduleInputDepartureKindEnum._(String name): super(name);

  static BuiltSet<ScheduleInputDepartureKindEnum> get values => _$scheduleInputDepartureKindEnumValues;
  static ScheduleInputDepartureKindEnum valueOf(String name) => _$scheduleInputDepartureKindEnumValueOf(name);
}


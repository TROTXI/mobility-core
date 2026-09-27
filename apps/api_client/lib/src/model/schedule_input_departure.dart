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
<<<<<<< HEAD
/// * [kind] 
/// * [departureId] 
@BuiltValue()
abstract class ScheduleInputDeparture implements Built<ScheduleInputDeparture, ScheduleInputDepartureBuilder> {
=======
/// * [kind]
/// * [departureId]
@BuiltValue()
abstract class ScheduleInputDeparture
    implements Built<ScheduleInputDeparture, ScheduleInputDepartureBuilder> {
>>>>>>> origin/main
  /// One Of [ScheduleInputDepartureOneOf], [ScheduleInputDepartureOneOf1]
  OneOf get oneOf;

  ScheduleInputDeparture._();

<<<<<<< HEAD
  factory ScheduleInputDeparture([void updates(ScheduleInputDepartureBuilder b)]) = _$ScheduleInputDeparture;
=======
  factory ScheduleInputDeparture(
          [void updates(ScheduleInputDepartureBuilder b)]) =
      _$ScheduleInputDeparture;
>>>>>>> origin/main

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ScheduleInputDepartureBuilder b) => b;

  @BuiltValueSerializer(custom: true)
<<<<<<< HEAD
  static Serializer<ScheduleInputDeparture> get serializer => _$ScheduleInputDepartureSerializer();
}

class _$ScheduleInputDepartureSerializer implements PrimitiveSerializer<ScheduleInputDeparture> {
  @override
  final Iterable<Type> types = const [ScheduleInputDeparture, _$ScheduleInputDeparture];
=======
  static Serializer<ScheduleInputDeparture> get serializer =>
      _$ScheduleInputDepartureSerializer();
}

class _$ScheduleInputDepartureSerializer
    implements PrimitiveSerializer<ScheduleInputDeparture> {
  @override
  final Iterable<Type> types = const [
    ScheduleInputDeparture,
    _$ScheduleInputDeparture
  ];
>>>>>>> origin/main

  @override
  final String wireName = r'ScheduleInputDeparture';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ScheduleInputDeparture object, {
    FullType specifiedType = FullType.unspecified,
<<<<<<< HEAD
  }) sync* {
  }
=======
  }) sync* {}
>>>>>>> origin/main

  @override
  Object serialize(
    Serializers serializers,
    ScheduleInputDeparture object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final oneOf = object.oneOf;
<<<<<<< HEAD
    return serializers.serialize(oneOf.value, specifiedType: FullType(oneOf.valueType))!;
=======
    return serializers.serialize(oneOf.value,
        specifiedType: FullType(oneOf.valueType))!;
>>>>>>> origin/main
  }

  @override
  ScheduleInputDeparture deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ScheduleInputDepartureBuilder();
    Object? oneOfDataSrc;
<<<<<<< HEAD
    final targetType = const FullType(OneOf, [FullType(ScheduleInputDepartureOneOf), FullType(ScheduleInputDepartureOneOf1), ]);
    oneOfDataSrc = serialized;
    result.oneOf = serializers.deserialize(oneOfDataSrc, specifiedType: targetType) as OneOf;
=======
    final targetType = const FullType(OneOf, [
      FullType(ScheduleInputDepartureOneOf),
      FullType(ScheduleInputDepartureOneOf1),
    ]);
    oneOfDataSrc = serialized;
    result.oneOf = serializers.deserialize(oneOfDataSrc,
        specifiedType: targetType) as OneOf;
>>>>>>> origin/main
    return result.build();
  }
}

class ScheduleInputDepartureKindEnum extends EnumClass {
<<<<<<< HEAD

  @BuiltValueEnumConst(wireName: r'existing')
  static const ScheduleInputDepartureKindEnum existing = _$scheduleInputDepartureKindEnum_existing;

  static Serializer<ScheduleInputDepartureKindEnum> get serializer => _$scheduleInputDepartureKindEnumSerializer;

  const ScheduleInputDepartureKindEnum._(String name): super(name);

  static BuiltSet<ScheduleInputDepartureKindEnum> get values => _$scheduleInputDepartureKindEnumValues;
  static ScheduleInputDepartureKindEnum valueOf(String name) => _$scheduleInputDepartureKindEnumValueOf(name);
}

=======
  @BuiltValueEnumConst(wireName: r'existing')
  static const ScheduleInputDepartureKindEnum existing =
      _$scheduleInputDepartureKindEnum_existing;

  static Serializer<ScheduleInputDepartureKindEnum> get serializer =>
      _$scheduleInputDepartureKindEnumSerializer;

  const ScheduleInputDepartureKindEnum._(String name) : super(name);

  static BuiltSet<ScheduleInputDepartureKindEnum> get values =>
      _$scheduleInputDepartureKindEnumValues;
  static ScheduleInputDepartureKindEnum valueOf(String name) =>
      _$scheduleInputDepartureKindEnumValueOf(name);
}
>>>>>>> origin/main

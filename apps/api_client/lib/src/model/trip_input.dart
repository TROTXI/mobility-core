//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'trip_input.g.dart';

/// TripInput
///
/// Properties:
/// * [scheduleId] 
/// * [serviceDate] 
/// * [runNumber] 
/// * [scheduledAt] 
@BuiltValue()
abstract class TripInput implements Built<TripInput, TripInputBuilder> {
  @BuiltValueField(wireName: r'scheduleId')
  String get scheduleId;

  @BuiltValueField(wireName: r'serviceDate')
  Date get serviceDate;

  @BuiltValueField(wireName: r'runNumber')
  TripInputRunNumberEnum? get runNumber;
  // enum runNumberEnum {  1,  };

  @BuiltValueField(wireName: r'scheduledAt')
  DateTime get scheduledAt;

  TripInput._();

  factory TripInput([void updates(TripInputBuilder b)]) = _$TripInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TripInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TripInput> get serializer => _$TripInputSerializer();
}

class _$TripInputSerializer implements PrimitiveSerializer<TripInput> {
  @override
  final Iterable<Type> types = const [TripInput, _$TripInput];

  @override
  final String wireName = r'TripInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TripInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'scheduleId';
    yield serializers.serialize(
      object.scheduleId,
      specifiedType: const FullType(String),
    );
    yield r'serviceDate';
    yield serializers.serialize(
      object.serviceDate,
      specifiedType: const FullType(Date),
    );
    if (object.runNumber != null) {
      yield r'runNumber';
      yield serializers.serialize(
        object.runNumber,
        specifiedType: const FullType(TripInputRunNumberEnum),
      );
    }
    yield r'scheduledAt';
    yield serializers.serialize(
      object.scheduledAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TripInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TripInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'scheduleId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.scheduleId = valueDes;
          break;
        case r'serviceDate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.serviceDate = valueDes;
          break;
        case r'runNumber':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TripInputRunNumberEnum),
          ) as TripInputRunNumberEnum;
          result.runNumber = valueDes;
          break;
        case r'scheduledAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.scheduledAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TripInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TripInputBuilder();
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

class TripInputRunNumberEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 1)
  static const TripInputRunNumberEnum number1 = _$tripInputRunNumberEnum_number1;

  static Serializer<TripInputRunNumberEnum> get serializer => _$tripInputRunNumberEnumSerializer;

  const TripInputRunNumberEnum._(String name): super(name);

  static BuiltSet<TripInputRunNumberEnum> get values => _$tripInputRunNumberEnumValues;
  static TripInputRunNumberEnum valueOf(String name) => _$tripInputRunNumberEnumValueOf(name);
}


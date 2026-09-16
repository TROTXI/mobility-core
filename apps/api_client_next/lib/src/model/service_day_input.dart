//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'service_day_input.g.dart';

/// ServiceDayInput
///
/// Properties:
/// * [travelDate] 
/// * [direction] 
/// * [limit] 
/// * [routeId] 
@BuiltValue()
abstract class ServiceDayInput implements Built<ServiceDayInput, ServiceDayInputBuilder> {
  @BuiltValueField(wireName: r'travelDate')
  Date get travelDate;

  @BuiltValueField(wireName: r'direction')
  ServiceDayInputDirectionEnum get direction;
  // enum directionEnum {  outbound,  return,  };

  @BuiltValueField(wireName: r'limit')
  int get limit;

  @BuiltValueField(wireName: r'routeId')
  String? get routeId;

  ServiceDayInput._();

  factory ServiceDayInput([void updates(ServiceDayInputBuilder b)]) = _$ServiceDayInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ServiceDayInputBuilder b) => b
      ..limit = 100;

  @BuiltValueSerializer(custom: true)
  static Serializer<ServiceDayInput> get serializer => _$ServiceDayInputSerializer();
}

class _$ServiceDayInputSerializer implements PrimitiveSerializer<ServiceDayInput> {
  @override
  final Iterable<Type> types = const [ServiceDayInput, _$ServiceDayInput];

  @override
  final String wireName = r'ServiceDayInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ServiceDayInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'travelDate';
    yield serializers.serialize(
      object.travelDate,
      specifiedType: const FullType(Date),
    );
    yield r'direction';
    yield serializers.serialize(
      object.direction,
      specifiedType: const FullType(ServiceDayInputDirectionEnum),
    );
    yield r'limit';
    yield serializers.serialize(
      object.limit,
      specifiedType: const FullType(int),
    );
    if (object.routeId != null) {
      yield r'routeId';
      yield serializers.serialize(
        object.routeId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ServiceDayInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ServiceDayInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'travelDate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.travelDate = valueDes;
          break;
        case r'direction':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ServiceDayInputDirectionEnum),
          ) as ServiceDayInputDirectionEnum;
          result.direction = valueDes;
          break;
        case r'limit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.limit = valueDes;
          break;
        case r'routeId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.routeId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ServiceDayInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ServiceDayInputBuilder();
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

class ServiceDayInputDirectionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'outbound')
  static const ServiceDayInputDirectionEnum outbound = _$serviceDayInputDirectionEnum_outbound;
  @BuiltValueEnumConst(wireName: r'return')
  static const ServiceDayInputDirectionEnum return_ = _$serviceDayInputDirectionEnum_return_;

  static Serializer<ServiceDayInputDirectionEnum> get serializer => _$serviceDayInputDirectionEnumSerializer;

  const ServiceDayInputDirectionEnum._(String name): super(name);

  static BuiltSet<ServiceDayInputDirectionEnum> get values => _$serviceDayInputDirectionEnumValues;
  static ServiceDayInputDirectionEnum valueOf(String name) => _$serviceDayInputDirectionEnumValueOf(name);
}


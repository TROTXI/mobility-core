//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client_next/src/model/point.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'incident_input.g.dart';

/// IncidentInput
///
/// Properties:
/// * [tripId] 
/// * [category] 
/// * [note] 
/// * [location] 
@BuiltValue()
abstract class IncidentInput implements Built<IncidentInput, IncidentInputBuilder> {
  @BuiltValueField(wireName: r'tripId')
  String? get tripId;

  @BuiltValueField(wireName: r'category')
  IncidentInputCategoryEnum get category;
  // enum categoryEnum {  vehicle,  collision,  passenger_safety,  route_blocked,  other,  };

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'location')
  Point? get location;

  IncidentInput._();

  factory IncidentInput([void updates(IncidentInputBuilder b)]) = _$IncidentInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(IncidentInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<IncidentInput> get serializer => _$IncidentInputSerializer();
}

class _$IncidentInputSerializer implements PrimitiveSerializer<IncidentInput> {
  @override
  final Iterable<Type> types = const [IncidentInput, _$IncidentInput];

  @override
  final String wireName = r'IncidentInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    IncidentInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.tripId != null) {
      yield r'tripId';
      yield serializers.serialize(
        object.tripId,
        specifiedType: const FullType(String),
      );
    }
    yield r'category';
    yield serializers.serialize(
      object.category,
      specifiedType: const FullType(IncidentInputCategoryEnum),
    );
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType(String),
      );
    }
    if (object.location != null) {
      yield r'location';
      yield serializers.serialize(
        object.location,
        specifiedType: const FullType(Point),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    IncidentInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required IncidentInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'tripId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.tripId = valueDes;
          break;
        case r'category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(IncidentInputCategoryEnum),
          ) as IncidentInputCategoryEnum;
          result.category = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.note = valueDes;
          break;
        case r'location':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Point),
          ) as Point;
          result.location.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  IncidentInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = IncidentInputBuilder();
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

class IncidentInputCategoryEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'vehicle')
  static const IncidentInputCategoryEnum vehicle = _$incidentInputCategoryEnum_vehicle;
  @BuiltValueEnumConst(wireName: r'collision')
  static const IncidentInputCategoryEnum collision = _$incidentInputCategoryEnum_collision;
  @BuiltValueEnumConst(wireName: r'passenger_safety')
  static const IncidentInputCategoryEnum passengerSafety = _$incidentInputCategoryEnum_passengerSafety;
  @BuiltValueEnumConst(wireName: r'route_blocked')
  static const IncidentInputCategoryEnum routeBlocked = _$incidentInputCategoryEnum_routeBlocked;
  @BuiltValueEnumConst(wireName: r'other')
  static const IncidentInputCategoryEnum other = _$incidentInputCategoryEnum_other;

  static Serializer<IncidentInputCategoryEnum> get serializer => _$incidentInputCategoryEnumSerializer;

  const IncidentInputCategoryEnum._(String name): super(name);

  static BuiltSet<IncidentInputCategoryEnum> get values => _$incidentInputCategoryEnumValues;
  static IncidentInputCategoryEnum valueOf(String name) => _$incidentInputCategoryEnumValueOf(name);
}


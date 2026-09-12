//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'me_incidents_post_request.g.dart';

/// MeIncidentsPostRequest
///
/// Properties:
/// * [tripId] 
/// * [category] 
/// * [note] 
/// * [lat] 
/// * [lng] 
@BuiltValue()
abstract class MeIncidentsPostRequest implements Built<MeIncidentsPostRequest, MeIncidentsPostRequestBuilder> {
  @BuiltValueField(wireName: r'tripId')
  String? get tripId;

  @BuiltValueField(wireName: r'category')
  MeIncidentsPostRequestCategoryEnum get category;
  // enum categoryEnum {  vehicle,  collision,  passenger_safety,  route_blocked,  other,  };

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'lat')
  num? get lat;

  @BuiltValueField(wireName: r'lng')
  num? get lng;

  MeIncidentsPostRequest._();

  factory MeIncidentsPostRequest([void updates(MeIncidentsPostRequestBuilder b)]) = _$MeIncidentsPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MeIncidentsPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MeIncidentsPostRequest> get serializer => _$MeIncidentsPostRequestSerializer();
}

class _$MeIncidentsPostRequestSerializer implements PrimitiveSerializer<MeIncidentsPostRequest> {
  @override
  final Iterable<Type> types = const [MeIncidentsPostRequest, _$MeIncidentsPostRequest];

  @override
  final String wireName = r'MeIncidentsPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MeIncidentsPostRequest object, {
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
      specifiedType: const FullType(MeIncidentsPostRequestCategoryEnum),
    );
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType(String),
      );
    }
    if (object.lat != null) {
      yield r'lat';
      yield serializers.serialize(
        object.lat,
        specifiedType: const FullType(num),
      );
    }
    if (object.lng != null) {
      yield r'lng';
      yield serializers.serialize(
        object.lng,
        specifiedType: const FullType(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    MeIncidentsPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MeIncidentsPostRequestBuilder result,
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
            specifiedType: const FullType(MeIncidentsPostRequestCategoryEnum),
          ) as MeIncidentsPostRequestCategoryEnum;
          result.category = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.note = valueDes;
          break;
        case r'lat':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.lat = valueDes;
          break;
        case r'lng':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.lng = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MeIncidentsPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MeIncidentsPostRequestBuilder();
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

class MeIncidentsPostRequestCategoryEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'vehicle')
  static const MeIncidentsPostRequestCategoryEnum vehicle = _$meIncidentsPostRequestCategoryEnum_vehicle;
  @BuiltValueEnumConst(wireName: r'collision')
  static const MeIncidentsPostRequestCategoryEnum collision = _$meIncidentsPostRequestCategoryEnum_collision;
  @BuiltValueEnumConst(wireName: r'passenger_safety')
  static const MeIncidentsPostRequestCategoryEnum passengerSafety = _$meIncidentsPostRequestCategoryEnum_passengerSafety;
  @BuiltValueEnumConst(wireName: r'route_blocked')
  static const MeIncidentsPostRequestCategoryEnum routeBlocked = _$meIncidentsPostRequestCategoryEnum_routeBlocked;
  @BuiltValueEnumConst(wireName: r'other')
  static const MeIncidentsPostRequestCategoryEnum other = _$meIncidentsPostRequestCategoryEnum_other;

  static Serializer<MeIncidentsPostRequestCategoryEnum> get serializer => _$meIncidentsPostRequestCategoryEnumSerializer;

  const MeIncidentsPostRequestCategoryEnum._(String name): super(name);

  static BuiltSet<MeIncidentsPostRequestCategoryEnum> get values => _$meIncidentsPostRequestCategoryEnumValues;
  static MeIncidentsPostRequestCategoryEnum valueOf(String name) => _$meIncidentsPostRequestCategoryEnumValueOf(name);
}


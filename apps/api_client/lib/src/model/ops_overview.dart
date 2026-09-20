//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/ops_overview_trips_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_overview.g.dart';

/// OpsOverview
///
/// Properties:
/// * [generatedAt] 
/// * [window] 
/// * [staleFixAfterSeconds] 
/// * [trips] 
@BuiltValue()
abstract class OpsOverview implements Built<OpsOverview, OpsOverviewBuilder> {
  @BuiltValueField(wireName: r'generatedAt')
  DateTime get generatedAt;

  @BuiltValueField(wireName: r'window')
  OpsOverviewWindowEnum get window;
  // enum windowEnum {  morning,  evening,  };

  @BuiltValueField(wireName: r'staleFixAfterSeconds')
  int get staleFixAfterSeconds;

  @BuiltValueField(wireName: r'trips')
  BuiltList<OpsOverviewTripsInner> get trips;

  OpsOverview._();

  factory OpsOverview([void updates(OpsOverviewBuilder b)]) = _$OpsOverview;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsOverviewBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsOverview> get serializer => _$OpsOverviewSerializer();
}

class _$OpsOverviewSerializer implements PrimitiveSerializer<OpsOverview> {
  @override
  final Iterable<Type> types = const [OpsOverview, _$OpsOverview];

  @override
  final String wireName = r'OpsOverview';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsOverview object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'generatedAt';
    yield serializers.serialize(
      object.generatedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'window';
    yield serializers.serialize(
      object.window,
      specifiedType: const FullType(OpsOverviewWindowEnum),
    );
    yield r'staleFixAfterSeconds';
    yield serializers.serialize(
      object.staleFixAfterSeconds,
      specifiedType: const FullType(int),
    );
    yield r'trips';
    yield serializers.serialize(
      object.trips,
      specifiedType: const FullType(BuiltList, [FullType(OpsOverviewTripsInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsOverview object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OpsOverviewBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'generatedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.generatedAt = valueDes;
          break;
        case r'window':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OpsOverviewWindowEnum),
          ) as OpsOverviewWindowEnum;
          result.window = valueDes;
          break;
        case r'staleFixAfterSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.staleFixAfterSeconds = valueDes;
          break;
        case r'trips':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(OpsOverviewTripsInner)]),
          ) as BuiltList<OpsOverviewTripsInner>;
          result.trips.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OpsOverview deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsOverviewBuilder();
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

class OpsOverviewWindowEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'morning')
  static const OpsOverviewWindowEnum morning = _$opsOverviewWindowEnum_morning;
  @BuiltValueEnumConst(wireName: r'evening')
  static const OpsOverviewWindowEnum evening = _$opsOverviewWindowEnum_evening;

  static Serializer<OpsOverviewWindowEnum> get serializer => _$opsOverviewWindowEnumSerializer;

  const OpsOverviewWindowEnum._(String name): super(name);

  static BuiltSet<OpsOverviewWindowEnum> get values => _$opsOverviewWindowEnumValues;
  static OpsOverviewWindowEnum valueOf(String name) => _$opsOverviewWindowEnumValueOf(name);
}


//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'stop_eta.g.dart';

/// StopEta
///
/// Properties:
/// * [stopOccurrenceId] 
/// * [durationSeconds] 
/// * [distanceMeters] 
/// * [basis] 
@BuiltValue()
abstract class StopEta implements Built<StopEta, StopEtaBuilder> {
  @BuiltValueField(wireName: r'stopOccurrenceId')
  String get stopOccurrenceId;

  @BuiltValueField(wireName: r'durationSeconds')
  int get durationSeconds;

  @BuiltValueField(wireName: r'distanceMeters')
  num get distanceMeters;

  @BuiltValueField(wireName: r'basis')
  StopEtaBasisEnum get basis;
  // enum basisEnum {  observed,  fallback,  };

  StopEta._();

  factory StopEta([void updates(StopEtaBuilder b)]) = _$StopEta;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StopEtaBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StopEta> get serializer => _$StopEtaSerializer();
}

class _$StopEtaSerializer implements PrimitiveSerializer<StopEta> {
  @override
  final Iterable<Type> types = const [StopEta, _$StopEta];

  @override
  final String wireName = r'StopEta';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StopEta object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'stopOccurrenceId';
    yield serializers.serialize(
      object.stopOccurrenceId,
      specifiedType: const FullType(String),
    );
    yield r'durationSeconds';
    yield serializers.serialize(
      object.durationSeconds,
      specifiedType: const FullType(int),
    );
    yield r'distanceMeters';
    yield serializers.serialize(
      object.distanceMeters,
      specifiedType: const FullType(num),
    );
    yield r'basis';
    yield serializers.serialize(
      object.basis,
      specifiedType: const FullType(StopEtaBasisEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    StopEta object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required StopEtaBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'stopOccurrenceId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.stopOccurrenceId = valueDes;
          break;
        case r'durationSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.durationSeconds = valueDes;
          break;
        case r'distanceMeters':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.distanceMeters = valueDes;
          break;
        case r'basis':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(StopEtaBasisEnum),
          ) as StopEtaBasisEnum;
          result.basis = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  StopEta deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StopEtaBuilder();
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

class StopEtaBasisEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'observed')
  static const StopEtaBasisEnum observed = _$stopEtaBasisEnum_observed;
  @BuiltValueEnumConst(wireName: r'fallback')
  static const StopEtaBasisEnum fallback = _$stopEtaBasisEnum_fallback;

  static Serializer<StopEtaBasisEnum> get serializer => _$stopEtaBasisEnumSerializer;

  const StopEtaBasisEnum._(String name): super(name);

  static BuiltSet<StopEtaBasisEnum> get values => _$stopEtaBasisEnumValues;
  static StopEtaBasisEnum valueOf(String name) => _$stopEtaBasisEnumValueOf(name);
}


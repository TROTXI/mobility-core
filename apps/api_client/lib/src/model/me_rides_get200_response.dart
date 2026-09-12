//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'me_rides_get200_response.g.dart';

/// MeRidesGet200Response
///
/// Properties:
/// * [remainingRides] 
/// * [creditPesewas] 
/// * [ridesPerPeriod] 
/// * [renewsAt] 
@BuiltValue()
abstract class MeRidesGet200Response implements Built<MeRidesGet200Response, MeRidesGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'remainingRides')
  int get remainingRides;

  @BuiltValueField(wireName: r'creditPesewas')
  int get creditPesewas;

  @BuiltValueField(wireName: r'ridesPerPeriod')
  int? get ridesPerPeriod;

  @BuiltValueField(wireName: r'renewsAt')
  DateTime? get renewsAt;

  MeRidesGet200Response._();

  factory MeRidesGet200Response([void updates(MeRidesGet200ResponseBuilder b)]) = _$MeRidesGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MeRidesGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MeRidesGet200Response> get serializer => _$MeRidesGet200ResponseSerializer();
}

class _$MeRidesGet200ResponseSerializer implements PrimitiveSerializer<MeRidesGet200Response> {
  @override
  final Iterable<Type> types = const [MeRidesGet200Response, _$MeRidesGet200Response];

  @override
  final String wireName = r'MeRidesGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MeRidesGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'remainingRides';
    yield serializers.serialize(
      object.remainingRides,
      specifiedType: const FullType(int),
    );
    yield r'creditPesewas';
    yield serializers.serialize(
      object.creditPesewas,
      specifiedType: const FullType(int),
    );
    yield r'ridesPerPeriod';
    yield object.ridesPerPeriod == null ? null : serializers.serialize(
      object.ridesPerPeriod,
      specifiedType: const FullType.nullable(int),
    );
    yield r'renewsAt';
    yield object.renewsAt == null ? null : serializers.serialize(
      object.renewsAt,
      specifiedType: const FullType.nullable(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MeRidesGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MeRidesGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'remainingRides':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.remainingRides = valueDes;
          break;
        case r'creditPesewas':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.creditPesewas = valueDes;
          break;
        case r'ridesPerPeriod':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.ridesPerPeriod = valueDes;
          break;
        case r'renewsAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.renewsAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MeRidesGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MeRidesGet200ResponseBuilder();
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



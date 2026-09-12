//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'trips_id_summary_get200_response_by_method.g.dart';

/// TripsIdSummaryGet200ResponseByMethod
///
/// Properties:
/// * [qr] 
/// * [pin] 
/// * [photo] 
@BuiltValue()
abstract class TripsIdSummaryGet200ResponseByMethod implements Built<TripsIdSummaryGet200ResponseByMethod, TripsIdSummaryGet200ResponseByMethodBuilder> {
  @BuiltValueField(wireName: r'qr')
  int get qr;

  @BuiltValueField(wireName: r'pin')
  int get pin;

  @BuiltValueField(wireName: r'photo')
  int get photo;

  TripsIdSummaryGet200ResponseByMethod._();

  factory TripsIdSummaryGet200ResponseByMethod([void updates(TripsIdSummaryGet200ResponseByMethodBuilder b)]) = _$TripsIdSummaryGet200ResponseByMethod;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TripsIdSummaryGet200ResponseByMethodBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TripsIdSummaryGet200ResponseByMethod> get serializer => _$TripsIdSummaryGet200ResponseByMethodSerializer();
}

class _$TripsIdSummaryGet200ResponseByMethodSerializer implements PrimitiveSerializer<TripsIdSummaryGet200ResponseByMethod> {
  @override
  final Iterable<Type> types = const [TripsIdSummaryGet200ResponseByMethod, _$TripsIdSummaryGet200ResponseByMethod];

  @override
  final String wireName = r'TripsIdSummaryGet200ResponseByMethod';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TripsIdSummaryGet200ResponseByMethod object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'qr';
    yield serializers.serialize(
      object.qr,
      specifiedType: const FullType(int),
    );
    yield r'pin';
    yield serializers.serialize(
      object.pin,
      specifiedType: const FullType(int),
    );
    yield r'photo';
    yield serializers.serialize(
      object.photo,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TripsIdSummaryGet200ResponseByMethod object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TripsIdSummaryGet200ResponseByMethodBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'qr':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.qr = valueDes;
          break;
        case r'pin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.pin = valueDes;
          break;
        case r'photo':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.photo = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TripsIdSummaryGet200ResponseByMethod deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TripsIdSummaryGet200ResponseByMethodBuilder();
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



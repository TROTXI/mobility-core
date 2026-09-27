//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reservation_detail_route.g.dart';

/// Current corridor name; the reservation does not snapshot route renames.
///
/// Properties:
/// * [id]
/// * [name]
@BuiltValue()
abstract class ReservationDetailRoute
    implements Built<ReservationDetailRoute, ReservationDetailRouteBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  ReservationDetailRoute._();

  factory ReservationDetailRoute(
          [void updates(ReservationDetailRouteBuilder b)]) =
      _$ReservationDetailRoute;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReservationDetailRouteBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReservationDetailRoute> get serializer =>
      _$ReservationDetailRouteSerializer();
}

class _$ReservationDetailRouteSerializer
    implements PrimitiveSerializer<ReservationDetailRoute> {
  @override
  final Iterable<Type> types = const [
    ReservationDetailRoute,
    _$ReservationDetailRoute
  ];

  @override
  final String wireName = r'ReservationDetailRoute';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReservationDetailRoute object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReservationDetailRoute object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReservationDetailRouteBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReservationDetailRoute deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReservationDetailRouteBuilder();
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

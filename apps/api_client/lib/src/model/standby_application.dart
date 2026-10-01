//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/standby_application_offer.dart';
import 'package:trotxi_api_client/src/model/purchase_input.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'standby_application.g.dart';

/// StandbyApplication
///
/// Properties:
/// * [id]
/// * [riderId]
/// * [riderName]
/// * [routeName]
/// * [state]
/// * [selection]
/// * [offer]
/// * [createdAt]
@BuiltValue()
abstract class StandbyApplication
    implements Built<StandbyApplication, StandbyApplicationBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'riderId')
  String get riderId;

  @BuiltValueField(wireName: r'riderName')
  String get riderName;

  @BuiltValueField(wireName: r'routeName')
  String get routeName;

  @BuiltValueField(wireName: r'state')
  StandbyApplicationStateEnum get state;
  // enum stateEnum {  submitted,  offered,  withdrawn,  checkout_open,  };

  @BuiltValueField(wireName: r'selection')
  PurchaseInput get selection;

  @BuiltValueField(wireName: r'offer')
  StandbyApplicationOffer? get offer;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  StandbyApplication._();

  factory StandbyApplication([void updates(StandbyApplicationBuilder b)]) =
      _$StandbyApplication;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StandbyApplicationBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StandbyApplication> get serializer =>
      _$StandbyApplicationSerializer();
}

class _$StandbyApplicationSerializer
    implements PrimitiveSerializer<StandbyApplication> {
  @override
  final Iterable<Type> types = const [StandbyApplication, _$StandbyApplication];

  @override
  final String wireName = r'StandbyApplication';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StandbyApplication object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'riderId';
    yield serializers.serialize(
      object.riderId,
      specifiedType: const FullType(String),
    );
    yield r'riderName';
    yield serializers.serialize(
      object.riderName,
      specifiedType: const FullType(String),
    );
    yield r'routeName';
    yield serializers.serialize(
      object.routeName,
      specifiedType: const FullType(String),
    );
    yield r'state';
    yield serializers.serialize(
      object.state,
      specifiedType: const FullType(StandbyApplicationStateEnum),
    );
    yield r'selection';
    yield serializers.serialize(
      object.selection,
      specifiedType: const FullType(PurchaseInput),
    );
    yield r'offer';
    yield object.offer == null
        ? null
        : serializers.serialize(
            object.offer,
            specifiedType: const FullType.nullable(StandbyApplicationOffer),
          );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    StandbyApplication object, {
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
    required StandbyApplicationBuilder result,
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
        case r'riderId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.riderId = valueDes;
          break;
        case r'riderName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.riderName = valueDes;
          break;
        case r'routeName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.routeName = valueDes;
          break;
        case r'state':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(StandbyApplicationStateEnum),
          ) as StandbyApplicationStateEnum;
          result.state = valueDes;
          break;
        case r'selection':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PurchaseInput),
          ) as PurchaseInput;
          result.selection.replace(valueDes);
          break;
        case r'offer':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(StandbyApplicationOffer),
          ) as StandbyApplicationOffer?;
          if (valueDes == null) continue;
          result.offer.replace(valueDes);
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  StandbyApplication deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StandbyApplicationBuilder();
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

class StandbyApplicationStateEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'submitted')
  static const StandbyApplicationStateEnum submitted =
      _$standbyApplicationStateEnum_submitted;
  @BuiltValueEnumConst(wireName: r'offered')
  static const StandbyApplicationStateEnum offered =
      _$standbyApplicationStateEnum_offered;
  @BuiltValueEnumConst(wireName: r'withdrawn')
  static const StandbyApplicationStateEnum withdrawn =
      _$standbyApplicationStateEnum_withdrawn;
  @BuiltValueEnumConst(wireName: r'checkout_open')
  static const StandbyApplicationStateEnum checkoutOpen =
      _$standbyApplicationStateEnum_checkoutOpen;

  static Serializer<StandbyApplicationStateEnum> get serializer =>
      _$standbyApplicationStateEnumSerializer;

  const StandbyApplicationStateEnum._(String name) : super(name);

  static BuiltSet<StandbyApplicationStateEnum> get values =>
      _$standbyApplicationStateEnumValues;
  static StandbyApplicationStateEnum valueOf(String name) =>
      _$standbyApplicationStateEnumValueOf(name);
}

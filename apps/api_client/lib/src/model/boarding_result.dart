//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'boarding_result.g.dart';

/// BoardingResult
///
/// Properties:
/// * [reservationId] 
/// * [status] 
/// * [alreadyApplied] 
/// * [chargedRides] 
@BuiltValue()
abstract class BoardingResult implements Built<BoardingResult, BoardingResultBuilder> {
  @BuiltValueField(wireName: r'reservationId')
  String get reservationId;

  @BuiltValueField(wireName: r'status')
  BoardingResultStatusEnum get status;
  // enum statusEnum {  boarded,  no_show,  };

  @BuiltValueField(wireName: r'alreadyApplied')
  bool get alreadyApplied;

  @BuiltValueField(wireName: r'chargedRides')
  int get chargedRides;

  BoardingResult._();

  factory BoardingResult([void updates(BoardingResultBuilder b)]) = _$BoardingResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BoardingResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BoardingResult> get serializer => _$BoardingResultSerializer();
}

class _$BoardingResultSerializer implements PrimitiveSerializer<BoardingResult> {
  @override
  final Iterable<Type> types = const [BoardingResult, _$BoardingResult];

  @override
  final String wireName = r'BoardingResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BoardingResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'reservationId';
    yield serializers.serialize(
      object.reservationId,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(BoardingResultStatusEnum),
    );
    yield r'alreadyApplied';
    yield serializers.serialize(
      object.alreadyApplied,
      specifiedType: const FullType(bool),
    );
    yield r'chargedRides';
    yield serializers.serialize(
      object.chargedRides,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BoardingResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BoardingResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'reservationId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reservationId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BoardingResultStatusEnum),
          ) as BoardingResultStatusEnum;
          result.status = valueDes;
          break;
        case r'alreadyApplied':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.alreadyApplied = valueDes;
          break;
        case r'chargedRides':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.chargedRides = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BoardingResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BoardingResultBuilder();
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

class BoardingResultStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'boarded')
  static const BoardingResultStatusEnum boarded = _$boardingResultStatusEnum_boarded;
  @BuiltValueEnumConst(wireName: r'no_show')
  static const BoardingResultStatusEnum noShow = _$boardingResultStatusEnum_noShow;

  static Serializer<BoardingResultStatusEnum> get serializer => _$boardingResultStatusEnumSerializer;

  const BoardingResultStatusEnum._(String name): super(name);

  static BuiltSet<BoardingResultStatusEnum> get values => _$boardingResultStatusEnumValues;
  static BoardingResultStatusEnum valueOf(String name) => _$boardingResultStatusEnumValueOf(name);
}


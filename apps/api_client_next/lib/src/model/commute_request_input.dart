//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/commute_leg.dart';
import 'package:trotxi_api_client_next/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commute_request_input.g.dart';

/// CommuteRequestInput
///
/// Properties:
/// * [routeId] 
/// * [legs] 
/// * [requestedDate] 
/// * [pauseIfWaitlisted] 
/// * [note] 
@BuiltValue()
abstract class CommuteRequestInput implements Built<CommuteRequestInput, CommuteRequestInputBuilder> {
  @BuiltValueField(wireName: r'routeId')
  String get routeId;

  @BuiltValueField(wireName: r'legs')
  BuiltList<CommuteLeg> get legs;

  @BuiltValueField(wireName: r'requestedDate')
  Date get requestedDate;

  @BuiltValueField(wireName: r'pauseIfWaitlisted')
  bool get pauseIfWaitlisted;

  @BuiltValueField(wireName: r'note')
  String? get note;

  CommuteRequestInput._();

  factory CommuteRequestInput([void updates(CommuteRequestInputBuilder b)]) = _$CommuteRequestInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommuteRequestInputBuilder b) => b
      ..pauseIfWaitlisted = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommuteRequestInput> get serializer => _$CommuteRequestInputSerializer();
}

class _$CommuteRequestInputSerializer implements PrimitiveSerializer<CommuteRequestInput> {
  @override
  final Iterable<Type> types = const [CommuteRequestInput, _$CommuteRequestInput];

  @override
  final String wireName = r'CommuteRequestInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommuteRequestInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'routeId';
    yield serializers.serialize(
      object.routeId,
      specifiedType: const FullType(String),
    );
    yield r'legs';
    yield serializers.serialize(
      object.legs,
      specifiedType: const FullType(BuiltList, [FullType(CommuteLeg)]),
    );
    yield r'requestedDate';
    yield serializers.serialize(
      object.requestedDate,
      specifiedType: const FullType(Date),
    );
    yield r'pauseIfWaitlisted';
    yield serializers.serialize(
      object.pauseIfWaitlisted,
      specifiedType: const FullType(bool),
    );
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CommuteRequestInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CommuteRequestInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'routeId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.routeId = valueDes;
          break;
        case r'legs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(CommuteLeg)]),
          ) as BuiltList<CommuteLeg>;
          result.legs.replace(valueDes);
          break;
        case r'requestedDate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.requestedDate = valueDes;
          break;
        case r'pauseIfWaitlisted':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.pauseIfWaitlisted = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.note = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CommuteRequestInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommuteRequestInputBuilder();
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


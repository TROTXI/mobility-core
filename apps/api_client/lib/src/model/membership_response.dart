//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/membership.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'membership_response.g.dart';

/// MembershipResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class MembershipResponse implements Built<MembershipResponse, MembershipResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  Membership get data;

  MembershipResponse._();

  factory MembershipResponse([void updates(MembershipResponseBuilder b)]) = _$MembershipResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MembershipResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MembershipResponse> get serializer => _$MembershipResponseSerializer();
}

class _$MembershipResponseSerializer implements PrimitiveSerializer<MembershipResponse> {
  @override
  final Iterable<Type> types = const [MembershipResponse, _$MembershipResponse];

  @override
  final String wireName = r'MembershipResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MembershipResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(Membership),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MembershipResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MembershipResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Membership),
          ) as Membership;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MembershipResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MembershipResponseBuilder();
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


//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'me_balance_get200_response.g.dart';

/// MeBalanceGet200Response
///
/// Properties:
/// * [balancePesewas] 
@BuiltValue()
abstract class MeBalanceGet200Response implements Built<MeBalanceGet200Response, MeBalanceGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'balancePesewas')
  int get balancePesewas;

  MeBalanceGet200Response._();

  factory MeBalanceGet200Response([void updates(MeBalanceGet200ResponseBuilder b)]) = _$MeBalanceGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MeBalanceGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MeBalanceGet200Response> get serializer => _$MeBalanceGet200ResponseSerializer();
}

class _$MeBalanceGet200ResponseSerializer implements PrimitiveSerializer<MeBalanceGet200Response> {
  @override
  final Iterable<Type> types = const [MeBalanceGet200Response, _$MeBalanceGet200Response];

  @override
  final String wireName = r'MeBalanceGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MeBalanceGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'balancePesewas';
    yield serializers.serialize(
      object.balancePesewas,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MeBalanceGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MeBalanceGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'balancePesewas':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.balancePesewas = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MeBalanceGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MeBalanceGet200ResponseBuilder();
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


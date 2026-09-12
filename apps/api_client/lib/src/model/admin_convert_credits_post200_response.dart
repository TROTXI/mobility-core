//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_convert_credits_post200_response.g.dart';

/// AdminConvertCreditsPost200Response
///
/// Properties:
/// * [riders] 
/// * [ridesConverted] 
/// * [creditPesewas] 
@BuiltValue()
abstract class AdminConvertCreditsPost200Response implements Built<AdminConvertCreditsPost200Response, AdminConvertCreditsPost200ResponseBuilder> {
  @BuiltValueField(wireName: r'riders')
  int get riders;

  @BuiltValueField(wireName: r'ridesConverted')
  int get ridesConverted;

  @BuiltValueField(wireName: r'creditPesewas')
  int get creditPesewas;

  AdminConvertCreditsPost200Response._();

  factory AdminConvertCreditsPost200Response([void updates(AdminConvertCreditsPost200ResponseBuilder b)]) = _$AdminConvertCreditsPost200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminConvertCreditsPost200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminConvertCreditsPost200Response> get serializer => _$AdminConvertCreditsPost200ResponseSerializer();
}

class _$AdminConvertCreditsPost200ResponseSerializer implements PrimitiveSerializer<AdminConvertCreditsPost200Response> {
  @override
  final Iterable<Type> types = const [AdminConvertCreditsPost200Response, _$AdminConvertCreditsPost200Response];

  @override
  final String wireName = r'AdminConvertCreditsPost200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminConvertCreditsPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'riders';
    yield serializers.serialize(
      object.riders,
      specifiedType: const FullType(int),
    );
    yield r'ridesConverted';
    yield serializers.serialize(
      object.ridesConverted,
      specifiedType: const FullType(int),
    );
    yield r'creditPesewas';
    yield serializers.serialize(
      object.creditPesewas,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminConvertCreditsPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminConvertCreditsPost200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'riders':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.riders = valueDes;
          break;
        case r'ridesConverted':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.ridesConverted = valueDes;
          break;
        case r'creditPesewas':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.creditPesewas = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminConvertCreditsPost200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminConvertCreditsPost200ResponseBuilder();
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


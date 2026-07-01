//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'payments_topup_post_request.g.dart';

/// PaymentsTopupPostRequest
///
/// Properties:
/// * [amountPesewas] 
@BuiltValue()
abstract class PaymentsTopupPostRequest implements Built<PaymentsTopupPostRequest, PaymentsTopupPostRequestBuilder> {
  @BuiltValueField(wireName: r'amountPesewas')
  int get amountPesewas;

  PaymentsTopupPostRequest._();

  factory PaymentsTopupPostRequest([void updates(PaymentsTopupPostRequestBuilder b)]) = _$PaymentsTopupPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PaymentsTopupPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PaymentsTopupPostRequest> get serializer => _$PaymentsTopupPostRequestSerializer();
}

class _$PaymentsTopupPostRequestSerializer implements PrimitiveSerializer<PaymentsTopupPostRequest> {
  @override
  final Iterable<Type> types = const [PaymentsTopupPostRequest, _$PaymentsTopupPostRequest];

  @override
  final String wireName = r'PaymentsTopupPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PaymentsTopupPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'amountPesewas';
    yield serializers.serialize(
      object.amountPesewas,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PaymentsTopupPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PaymentsTopupPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'amountPesewas':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.amountPesewas = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PaymentsTopupPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PaymentsTopupPostRequestBuilder();
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


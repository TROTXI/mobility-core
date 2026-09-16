//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'error_response_error_field_errors_inner.g.dart';

/// ErrorResponseErrorFieldErrorsInner
///
/// Properties:
/// * [field] 
/// * [code] 
@BuiltValue()
abstract class ErrorResponseErrorFieldErrorsInner implements Built<ErrorResponseErrorFieldErrorsInner, ErrorResponseErrorFieldErrorsInnerBuilder> {
  @BuiltValueField(wireName: r'field')
  String get field;

  @BuiltValueField(wireName: r'code')
  String get code;

  ErrorResponseErrorFieldErrorsInner._();

  factory ErrorResponseErrorFieldErrorsInner([void updates(ErrorResponseErrorFieldErrorsInnerBuilder b)]) = _$ErrorResponseErrorFieldErrorsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ErrorResponseErrorFieldErrorsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ErrorResponseErrorFieldErrorsInner> get serializer => _$ErrorResponseErrorFieldErrorsInnerSerializer();
}

class _$ErrorResponseErrorFieldErrorsInnerSerializer implements PrimitiveSerializer<ErrorResponseErrorFieldErrorsInner> {
  @override
  final Iterable<Type> types = const [ErrorResponseErrorFieldErrorsInner, _$ErrorResponseErrorFieldErrorsInner];

  @override
  final String wireName = r'ErrorResponseErrorFieldErrorsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ErrorResponseErrorFieldErrorsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'field';
    yield serializers.serialize(
      object.field,
      specifiedType: const FullType(String),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ErrorResponseErrorFieldErrorsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ErrorResponseErrorFieldErrorsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'field':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.field = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ErrorResponseErrorFieldErrorsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ErrorResponseErrorFieldErrorsInnerBuilder();
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


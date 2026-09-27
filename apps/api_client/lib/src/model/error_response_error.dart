//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/error_response_error_field_errors_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'error_response_error.g.dart';

/// ErrorResponseError
///
/// Properties:
<<<<<<< HEAD
/// * [code] 
/// * [message] 
/// * [requestId] 
/// * [fieldErrors] 
@BuiltValue()
abstract class ErrorResponseError implements Built<ErrorResponseError, ErrorResponseErrorBuilder> {
=======
/// * [code]
/// * [message]
/// * [requestId]
/// * [fieldErrors]
@BuiltValue()
abstract class ErrorResponseError
    implements Built<ErrorResponseError, ErrorResponseErrorBuilder> {
>>>>>>> origin/main
  @BuiltValueField(wireName: r'code')
  String get code;

  @BuiltValueField(wireName: r'message')
  String get message;

  @BuiltValueField(wireName: r'requestId')
  String get requestId;

  @BuiltValueField(wireName: r'fieldErrors')
  BuiltList<ErrorResponseErrorFieldErrorsInner>? get fieldErrors;

  ErrorResponseError._();

<<<<<<< HEAD
  factory ErrorResponseError([void updates(ErrorResponseErrorBuilder b)]) = _$ErrorResponseError;
=======
  factory ErrorResponseError([void updates(ErrorResponseErrorBuilder b)]) =
      _$ErrorResponseError;
>>>>>>> origin/main

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ErrorResponseErrorBuilder b) => b;

  @BuiltValueSerializer(custom: true)
<<<<<<< HEAD
  static Serializer<ErrorResponseError> get serializer => _$ErrorResponseErrorSerializer();
}

class _$ErrorResponseErrorSerializer implements PrimitiveSerializer<ErrorResponseError> {
=======
  static Serializer<ErrorResponseError> get serializer =>
      _$ErrorResponseErrorSerializer();
}

class _$ErrorResponseErrorSerializer
    implements PrimitiveSerializer<ErrorResponseError> {
>>>>>>> origin/main
  @override
  final Iterable<Type> types = const [ErrorResponseError, _$ErrorResponseError];

  @override
  final String wireName = r'ErrorResponseError';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ErrorResponseError object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
    yield r'requestId';
    yield serializers.serialize(
      object.requestId,
      specifiedType: const FullType(String),
    );
    if (object.fieldErrors != null) {
      yield r'fieldErrors';
      yield serializers.serialize(
        object.fieldErrors,
<<<<<<< HEAD
        specifiedType: const FullType(BuiltList, [FullType(ErrorResponseErrorFieldErrorsInner)]),
=======
        specifiedType: const FullType(
            BuiltList, [FullType(ErrorResponseErrorFieldErrorsInner)]),
>>>>>>> origin/main
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ErrorResponseError object, {
    FullType specifiedType = FullType.unspecified,
  }) {
<<<<<<< HEAD
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
=======
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
>>>>>>> origin/main
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ErrorResponseErrorBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        case r'requestId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.requestId = valueDes;
          break;
        case r'fieldErrors':
          final valueDes = serializers.deserialize(
            value,
<<<<<<< HEAD
            specifiedType: const FullType(BuiltList, [FullType(ErrorResponseErrorFieldErrorsInner)]),
=======
            specifiedType: const FullType(
                BuiltList, [FullType(ErrorResponseErrorFieldErrorsInner)]),
>>>>>>> origin/main
          ) as BuiltList<ErrorResponseErrorFieldErrorsInner>;
          result.fieldErrors.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ErrorResponseError deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ErrorResponseErrorBuilder();
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
<<<<<<< HEAD

=======
>>>>>>> origin/main

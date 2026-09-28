//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'refresh_input.g.dart';

/// RefreshInput
///
/// Properties:
/// * [refreshToken]
@BuiltValue()
abstract class RefreshInput
    implements Built<RefreshInput, RefreshInputBuilder> {
  @BuiltValueField(wireName: r'refreshToken')
  String get refreshToken;

  RefreshInput._();

  factory RefreshInput([void updates(RefreshInputBuilder b)]) = _$RefreshInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RefreshInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RefreshInput> get serializer => _$RefreshInputSerializer();
}

class _$RefreshInputSerializer implements PrimitiveSerializer<RefreshInput> {
  @override
  final Iterable<Type> types = const [RefreshInput, _$RefreshInput];

  @override
  final String wireName = r'RefreshInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RefreshInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'refreshToken';
    yield serializers.serialize(
      object.refreshToken,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RefreshInput object, {
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
    required RefreshInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'refreshToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.refreshToken = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RefreshInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RefreshInputBuilder();
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

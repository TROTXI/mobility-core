//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'manifest_rider.g.dart';

/// ManifestRider
///
/// Properties:
<<<<<<< HEAD
/// * [reservationId] 
/// * [displayName] 
/// * [avatarUrl] 
/// * [status] 
/// * [pickupOccurrenceId] 
/// * [dropoffOccurrenceId] 
@BuiltValue()
abstract class ManifestRider implements Built<ManifestRider, ManifestRiderBuilder> {
=======
/// * [reservationId]
/// * [displayName]
/// * [avatarUrl]
/// * [status]
/// * [pickupOccurrenceId]
/// * [dropoffOccurrenceId]
@BuiltValue()
abstract class ManifestRider
    implements Built<ManifestRider, ManifestRiderBuilder> {
>>>>>>> origin/main
  @BuiltValueField(wireName: r'reservationId')
  String get reservationId;

  @BuiltValueField(wireName: r'displayName')
  String get displayName;

  @BuiltValueField(wireName: r'avatarUrl')
  String? get avatarUrl;

  @BuiltValueField(wireName: r'status')
  ManifestRiderStatusEnum get status;
  // enum statusEnum {  pending,  reserved,  declined,  unseated,  boarded,  no_show,  operator_cancelled,  };

  @BuiltValueField(wireName: r'pickupOccurrenceId')
  String get pickupOccurrenceId;

  @BuiltValueField(wireName: r'dropoffOccurrenceId')
  String get dropoffOccurrenceId;

  ManifestRider._();

<<<<<<< HEAD
  factory ManifestRider([void updates(ManifestRiderBuilder b)]) = _$ManifestRider;
=======
  factory ManifestRider([void updates(ManifestRiderBuilder b)]) =
      _$ManifestRider;
>>>>>>> origin/main

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ManifestRiderBuilder b) => b;

  @BuiltValueSerializer(custom: true)
<<<<<<< HEAD
  static Serializer<ManifestRider> get serializer => _$ManifestRiderSerializer();
=======
  static Serializer<ManifestRider> get serializer =>
      _$ManifestRiderSerializer();
>>>>>>> origin/main
}

class _$ManifestRiderSerializer implements PrimitiveSerializer<ManifestRider> {
  @override
  final Iterable<Type> types = const [ManifestRider, _$ManifestRider];

  @override
  final String wireName = r'ManifestRider';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ManifestRider object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'reservationId';
    yield serializers.serialize(
      object.reservationId,
      specifiedType: const FullType(String),
    );
    yield r'displayName';
    yield serializers.serialize(
      object.displayName,
      specifiedType: const FullType(String),
    );
    yield r'avatarUrl';
<<<<<<< HEAD
    yield object.avatarUrl == null ? null : serializers.serialize(
      object.avatarUrl,
      specifiedType: const FullType.nullable(String),
    );
=======
    yield object.avatarUrl == null
        ? null
        : serializers.serialize(
            object.avatarUrl,
            specifiedType: const FullType.nullable(String),
          );
>>>>>>> origin/main
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(ManifestRiderStatusEnum),
    );
    yield r'pickupOccurrenceId';
    yield serializers.serialize(
      object.pickupOccurrenceId,
      specifiedType: const FullType(String),
    );
    yield r'dropoffOccurrenceId';
    yield serializers.serialize(
      object.dropoffOccurrenceId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ManifestRider object, {
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
    required ManifestRiderBuilder result,
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
        case r'displayName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.displayName = valueDes;
          break;
        case r'avatarUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.avatarUrl = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ManifestRiderStatusEnum),
          ) as ManifestRiderStatusEnum;
          result.status = valueDes;
          break;
        case r'pickupOccurrenceId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.pickupOccurrenceId = valueDes;
          break;
        case r'dropoffOccurrenceId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.dropoffOccurrenceId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ManifestRider deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ManifestRiderBuilder();
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

class ManifestRiderStatusEnum extends EnumClass {
<<<<<<< HEAD

  @BuiltValueEnumConst(wireName: r'pending')
  static const ManifestRiderStatusEnum pending = _$manifestRiderStatusEnum_pending;
  @BuiltValueEnumConst(wireName: r'reserved')
  static const ManifestRiderStatusEnum reserved = _$manifestRiderStatusEnum_reserved;
  @BuiltValueEnumConst(wireName: r'declined')
  static const ManifestRiderStatusEnum declined = _$manifestRiderStatusEnum_declined;
  @BuiltValueEnumConst(wireName: r'unseated')
  static const ManifestRiderStatusEnum unseated = _$manifestRiderStatusEnum_unseated;
  @BuiltValueEnumConst(wireName: r'boarded')
  static const ManifestRiderStatusEnum boarded = _$manifestRiderStatusEnum_boarded;
  @BuiltValueEnumConst(wireName: r'no_show')
  static const ManifestRiderStatusEnum noShow = _$manifestRiderStatusEnum_noShow;
  @BuiltValueEnumConst(wireName: r'operator_cancelled')
  static const ManifestRiderStatusEnum operatorCancelled = _$manifestRiderStatusEnum_operatorCancelled;

  static Serializer<ManifestRiderStatusEnum> get serializer => _$manifestRiderStatusEnumSerializer;

  const ManifestRiderStatusEnum._(String name): super(name);

  static BuiltSet<ManifestRiderStatusEnum> get values => _$manifestRiderStatusEnumValues;
  static ManifestRiderStatusEnum valueOf(String name) => _$manifestRiderStatusEnumValueOf(name);
}

=======
  @BuiltValueEnumConst(wireName: r'pending')
  static const ManifestRiderStatusEnum pending =
      _$manifestRiderStatusEnum_pending;
  @BuiltValueEnumConst(wireName: r'reserved')
  static const ManifestRiderStatusEnum reserved =
      _$manifestRiderStatusEnum_reserved;
  @BuiltValueEnumConst(wireName: r'declined')
  static const ManifestRiderStatusEnum declined =
      _$manifestRiderStatusEnum_declined;
  @BuiltValueEnumConst(wireName: r'unseated')
  static const ManifestRiderStatusEnum unseated =
      _$manifestRiderStatusEnum_unseated;
  @BuiltValueEnumConst(wireName: r'boarded')
  static const ManifestRiderStatusEnum boarded =
      _$manifestRiderStatusEnum_boarded;
  @BuiltValueEnumConst(wireName: r'no_show')
  static const ManifestRiderStatusEnum noShow =
      _$manifestRiderStatusEnum_noShow;
  @BuiltValueEnumConst(wireName: r'operator_cancelled')
  static const ManifestRiderStatusEnum operatorCancelled =
      _$manifestRiderStatusEnum_operatorCancelled;

  static Serializer<ManifestRiderStatusEnum> get serializer =>
      _$manifestRiderStatusEnumSerializer;

  const ManifestRiderStatusEnum._(String name) : super(name);

  static BuiltSet<ManifestRiderStatusEnum> get values =>
      _$manifestRiderStatusEnumValues;
  static ManifestRiderStatusEnum valueOf(String name) =>
      _$manifestRiderStatusEnumValueOf(name);
}
>>>>>>> origin/main

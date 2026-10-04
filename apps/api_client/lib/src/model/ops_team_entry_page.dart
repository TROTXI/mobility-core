//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/commute_request_page_page.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/ops_team_entry.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_team_entry_page.g.dart';

/// OpsTeamEntryPage
///
/// Properties:
/// * [data]
/// * [page]
@BuiltValue()
abstract class OpsTeamEntryPage
    implements Built<OpsTeamEntryPage, OpsTeamEntryPageBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<OpsTeamEntry> get data;

  @BuiltValueField(wireName: r'page')
  CommuteRequestPagePage get page;

  OpsTeamEntryPage._();

  factory OpsTeamEntryPage([void updates(OpsTeamEntryPageBuilder b)]) =
      _$OpsTeamEntryPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsTeamEntryPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsTeamEntryPage> get serializer =>
      _$OpsTeamEntryPageSerializer();
}

class _$OpsTeamEntryPageSerializer
    implements PrimitiveSerializer<OpsTeamEntryPage> {
  @override
  final Iterable<Type> types = const [OpsTeamEntryPage, _$OpsTeamEntryPage];

  @override
  final String wireName = r'OpsTeamEntryPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsTeamEntryPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(OpsTeamEntry)]),
    );
    yield r'page';
    yield serializers.serialize(
      object.page,
      specifiedType: const FullType(CommuteRequestPagePage),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsTeamEntryPage object, {
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
    required OpsTeamEntryPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(OpsTeamEntry)]),
          ) as BuiltList<OpsTeamEntry>;
          result.data.replace(valueDes);
          break;
        case r'page':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CommuteRequestPagePage),
          ) as CommuteRequestPagePage;
          result.page.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OpsTeamEntryPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsTeamEntryPageBuilder();
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

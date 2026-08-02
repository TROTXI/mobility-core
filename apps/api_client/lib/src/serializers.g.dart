// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serializers.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializers _$serializers = (Serializers().toBuilder()
      ..add(AdminAskDispatchPost200Response.serializer)
      ..add(AdminAskDispatchPostRequest.serializer)
      ..add(AdminAskDispatchPostRequestDirectionEnum.serializer)
      ..add(AdminConvertCreditsPost200Response.serializer)
      ..add(AdminDriversGet200ResponseInner.serializer)
      ..add(AdminDriversIdPatchRequest.serializer)
      ..add(AdminDriversPostRequest.serializer)
      ..add(AdminFlagsGet200ResponseInner.serializer)
      ..add(AdminFlagsKeyPutRequest.serializer)
      ..add(AdminMinVersionsGet200ResponseInner.serializer)
      ..add(AdminMinVersionsGet200ResponseInnerPlatformEnum.serializer)
      ..add(AdminMinVersionsPlatformPutRequest.serializer)
      ..add(AdminResolveDefaultsPost200Response.serializer)
      ..add(AdminResolveNoShowsPost200Response.serializer)
      ..add(AdminRoutesIdPatchRequest.serializer)
      ..add(AdminRoutesIdStopsPost200Response.serializer)
      ..add(AdminRoutesIdStopsPostRequest.serializer)
      ..add(AdminRoutesPostRequest.serializer)
      ..add(AdminStopsGet200ResponseInner.serializer)
      ..add(AdminStopsIdPatchRequest.serializer)
      ..add(AdminStopsPostRequest.serializer)
      ..add(AdminTripsIdAssignmentPutRequest.serializer)
      ..add(AdminTripsIdPatchRequest.serializer)
      ..add(AdminTripsIdPatchRequestStatusEnum.serializer)
      ..add(AdminTripsPostRequest.serializer)
      ..add(AdminTripsPostRequestStatusEnum.serializer)
      ..add(AdminUsersIdRolePatch200Response.serializer)
      ..add(AdminUsersIdRolePatch200ResponseRoleEnum.serializer)
      ..add(AdminUsersIdRolePatchRequest.serializer)
      ..add(AdminUsersIdRolePatchRequestRoleEnum.serializer)
      ..add(AdminVehiclesGet200ResponseInner.serializer)
      ..add(AdminVehiclesIdPatchRequest.serializer)
      ..add(AdminVehiclesPostRequest.serializer)
      ..add(AuthGooglePost200Response.serializer)
      ..add(AuthGooglePostRequest.serializer)
      ..add(AuthRefreshPost200Response.serializer)
      ..add(AuthRefreshPostRequest.serializer)
      ..add(BoardingManifestGet200Response.serializer)
      ..add(BoardingManifestGet200ResponseRidersInner.serializer)
      ..add(BoardingManifestGet200ResponseRidersInnerDirectionEnum.serializer)
      ..add(BoardingScanPost200Response.serializer)
      ..add(BoardingScanPost200ResponseReasonEnum.serializer)
      ..add(BoardingScanPostRequest.serializer)
      ..add(BoardingVerifyPinPost200Response.serializer)
      ..add(BoardingVerifyPinPost200ResponseReasonEnum.serializer)
      ..add(BoardingVerifyPinPostRequest.serializer)
      ..add(FlagsGet200Response.serializer)
      ..add(FlagsGet200ResponseFlagsInner.serializer)
      ..add(FlagsGet200ResponseMinSupportedVersion.serializer)
      ..add(Get200Response.serializer)
      ..add(HealthzGet200Response.serializer)
      ..add(HealthzGet200ResponseStatusEnum.serializer)
      ..add(MeAvatarGet200Response.serializer)
      ..add(MeDevicesPost200Response.serializer)
      ..add(MeDevicesPostRequest.serializer)
      ..add(MeDevicesPostRequestPlatformEnum.serializer)
      ..add(MeGet200Response.serializer)
      ..add(MeGet200ResponseRoleEnum.serializer)
      ..add(MeGet401Response.serializer)
      ..add(MePassGet200Response.serializer)
      ..add(MePatchRequest.serializer)
      ..add(MeReservationsGet200Response.serializer)
      ..add(MeReservationsGet200ResponseReservationsInner.serializer)
      ..add(
          MeReservationsGet200ResponseReservationsInnerDirectionEnum.serializer)
      ..add(MeReservationsGet200ResponseReservationsInnerSource_Enum.serializer)
      ..add(MeReservationsGet200ResponseReservationsInnerStatusEnum.serializer)
      ..add(MeReservationsPostRequest.serializer)
      ..add(MeReservationsPostRequestDirectionEnum.serializer)
      ..add(MeRidesGet200Response.serializer)
      ..add(MeSessionsGet200Response.serializer)
      ..add(MeSessionsGet200ResponseSessionsInner.serializer)
      ..add(PaymentsSubscribePost200Response.serializer)
      ..add(PaymentsSubscribePostRequest.serializer)
      ..add(PaymentsSubscribePostRequestPlanEnum.serializer)
      ..add(ReadyzGet200Response.serializer)
      ..add(ReadyzGet200ResponseStatusEnum.serializer)
      ..add(ReadyzGet503Response.serializer)
      ..add(ReadyzGet503ResponseStatusEnum.serializer)
      ..add(RoutesGet200ResponseInner.serializer)
      ..add(RoutesIdGet200Response.serializer)
      ..add(RoutesIdGet200ResponseStopsInner.serializer)
      ..add(TripsGet200Response.serializer)
      ..add(TripsGet200ResponseTripsInner.serializer)
      ..add(TripsGet200ResponseTripsInnerStatusEnum.serializer)
      ..add(TripsIdPositionGet200Response.serializer)
      ..add(TripsIdPositionGet200ResponseEtaToStopsInner.serializer)
      ..add(TripsIdPositionGet200ResponsePosition.serializer)
      ..add(TripsIdPositionPost200Response.serializer)
      ..add(TripsIdPositionPostRequest.serializer)
      ..add(VersionGet200Response.serializer)
      ..add(WebhooksPaystackPost200Response.serializer)
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(BoardingManifestGet200ResponseRidersInner)
          ]),
          () => ListBuilder<BoardingManifestGet200ResponseRidersInner>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(FlagsGet200ResponseFlagsInner)]),
          () => ListBuilder<FlagsGet200ResponseFlagsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(MeReservationsGet200ResponseReservationsInner)
          ]),
          () => ListBuilder<MeReservationsGet200ResponseReservationsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(MeSessionsGet200ResponseSessionsInner)]),
          () => ListBuilder<MeSessionsGet200ResponseSessionsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(RoutesIdGet200ResponseStopsInner)]),
          () => ListBuilder<RoutesIdGet200ResponseStopsInner>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(TripsGet200ResponseTripsInner)]),
          () => ListBuilder<TripsGet200ResponseTripsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(TripsIdPositionGet200ResponseEtaToStopsInner)
          ]),
          () => ListBuilder<TripsIdPositionGet200ResponseEtaToStopsInner>()))
    .build();

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

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
      ..add(AdminDriverRequestsGet200Response.serializer)
      ..add(AdminDriverRequestsGet200ResponseRequestsInner.serializer)
      ..add(AdminDriverRequestsGet200ResponseRequestsInnerKindEnum.serializer)
      ..add(AdminDriverRequestsGet200ResponseRequestsInnerStatusEnum.serializer)
      ..add(AdminDriverRequestsIdPatchRequest.serializer)
      ..add(AdminDriverRequestsIdPatchRequestStatusEnum.serializer)
      ..add(AdminDriversGet200ResponseInner.serializer)
      ..add(AdminDriversIdCredentialsPatchRequest.serializer)
      ..add(AdminDriversIdCredentialsPatchRequestStatusEnum.serializer)
      ..add(AdminDriversIdCredentialsPost201Response.serializer)
      ..add(AdminDriversIdPatchRequest.serializer)
      ..add(AdminDriversPostRequest.serializer)
      ..add(AdminExpireSubscriptionsPost200Response.serializer)
      ..add(AdminFlagsGet200ResponseInner.serializer)
      ..add(AdminFlagsKeyPutRequest.serializer)
      ..add(AdminIncidentsGet200Response.serializer)
      ..add(AdminIncidentsGet200ResponseIncidentsInner.serializer)
      ..add(AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum.serializer)
      ..add(AdminIncidentsGet200ResponseIncidentsInnerStatusEnum.serializer)
      ..add(AdminIncidentsIdPatchRequest.serializer)
      ..add(AdminIncidentsIdPatchRequestStatusEnum.serializer)
      ..add(AdminLearnRoutesPost200Response.serializer)
      ..add(AdminLearnRoutesPost200ResponseRoutesInner.serializer)
      ..add(
          AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearned.serializer)
      ..add(AdminLearnRoutesPostRequest.serializer)
      ..add(AdminMinVersionsGet200ResponseInner.serializer)
      ..add(AdminMinVersionsGet200ResponseInnerPlatformEnum.serializer)
      ..add(AdminMinVersionsPlatformPutRequest.serializer)
      ..add(AdminPlanPricingGet200Response.serializer)
      ..add(AdminPlanPricingGet200ResponsePlansInner.serializer)
      ..add(AdminPlanPricingGet200ResponsePlansInnerPlanEnum.serializer)
      ..add(AdminPlanPricingPlanPatchRequest.serializer)
      ..add(AdminResolveDefaultsPost200Response.serializer)
      ..add(AdminResolveNoShowsPost200Response.serializer)
      ..add(AdminRoutesIdFarePutRequest.serializer)
      ..add(AdminRoutesIdFaresGet200Response.serializer)
      ..add(AdminRoutesIdFaresGet200ResponseFaresInner.serializer)
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
      ..add(AuthApplePostRequest.serializer)
      ..add(AuthDriverPinPostRequest.serializer)
      ..add(AuthDriverPost200Response.serializer)
      ..add(AuthDriverPost200ResponseDriver.serializer)
      ..add(AuthDriverPostRequest.serializer)
      ..add(AuthGooglePost200Response.serializer)
      ..add(AuthGooglePostRequest.serializer)
      ..add(AuthRefreshPost200Response.serializer)
      ..add(AuthRefreshPostRequest.serializer)
      ..add(BoardingBoardPost200Response.serializer)
      ..add(BoardingBoardPost200ResponseReasonEnum.serializer)
      ..add(BoardingBoardPostRequest.serializer)
      ..add(BoardingManifestGet200Response.serializer)
      ..add(BoardingManifestGet200ResponseRidersInner.serializer)
      ..add(BoardingManifestGet200ResponseRidersInnerDirectionEnum.serializer)
      ..add(BoardingManifestGet200ResponseRidersInnerSource_Enum.serializer)
      ..add(BoardingNoShowPost200Response.serializer)
      ..add(BoardingNoShowPost200ResponseReasonEnum.serializer)
      ..add(BoardingScanPost200Response.serializer)
      ..add(BoardingScanPost200ResponseReasonEnum.serializer)
      ..add(BoardingScanPostRequest.serializer)
      ..add(BoardingVerifyCodePost200Response.serializer)
      ..add(BoardingVerifyCodePost200ResponseReasonEnum.serializer)
      ..add(BoardingVerifyCodePostRequest.serializer)
      ..add(BoardingVerifyPinPost200Response.serializer)
      ..add(BoardingVerifyPinPost200ResponseReasonEnum.serializer)
      ..add(BoardingVerifyPinPostRequest.serializer)
      ..add(FlagsGet200Response.serializer)
      ..add(FlagsGet200ResponseFlagsInner.serializer)
      ..add(FlagsGet200ResponseMapTiles.serializer)
      ..add(FlagsGet200ResponseMinSupportedVersion.serializer)
      ..add(FlagsGet200ResponseOperations.serializer)
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
      ..add(MeIncidentsGet200Response.serializer)
      ..add(MeIncidentsGet200ResponseIncidentsInner.serializer)
      ..add(MeIncidentsGet200ResponseIncidentsInnerCategoryEnum.serializer)
      ..add(MeIncidentsGet200ResponseIncidentsInnerStatusEnum.serializer)
      ..add(MeIncidentsPostRequest.serializer)
      ..add(MeIncidentsPostRequestCategoryEnum.serializer)
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
      ..add(MeWorkRequestsGet200Response.serializer)
      ..add(MeWorkRequestsGet200ResponseRequestsInner.serializer)
      ..add(MeWorkRequestsGet200ResponseRequestsInnerKindEnum.serializer)
      ..add(MeWorkRequestsGet200ResponseRequestsInnerStatusEnum.serializer)
      ..add(MeWorkRequestsPostRequest.serializer)
      ..add(MeWorkRequestsPostRequestOneOf.serializer)
      ..add(MeWorkRequestsPostRequestOneOf1.serializer)
      ..add(MeWorkRequestsPostRequestOneOf1KindEnum.serializer)
      ..add(MeWorkRequestsPostRequestOneOfKindEnum.serializer)
      ..add(MeWorkRoutesGet200Response.serializer)
      ..add(MeWorkRoutesGet200ResponseRoutesInner.serializer)
      ..add(PaymentsSubscribePost200Response.serializer)
      ..add(PaymentsSubscribePostRequest.serializer)
      ..add(PaymentsSubscribePostRequestPlanEnum.serializer)
      ..add(ReadyzGet200Response.serializer)
      ..add(ReadyzGet200ResponseStatusEnum.serializer)
      ..add(ReadyzGet503Response.serializer)
      ..add(ReadyzGet503ResponseStatusEnum.serializer)
      ..add(RoutesGet200ResponseInner.serializer)
      ..add(RoutesIdGeometryGet200Response.serializer)
      ..add(RoutesIdGeometryGet200ResponsePointsInner.serializer)
      ..add(RoutesIdGeometryGet200ResponseSource_Enum.serializer)
      ..add(RoutesIdGet200Response.serializer)
      ..add(RoutesIdGet200ResponseStopsInner.serializer)
      ..add(TripsGet200Response.serializer)
      ..add(TripsGet200ResponseTripsInner.serializer)
      ..add(TripsGet200ResponseTripsInnerStatusEnum.serializer)
      ..add(TripsIdArrivePostRequest.serializer)
      ..add(TripsIdGet200Response.serializer)
      ..add(TripsIdGet200ResponseStatusEnum.serializer)
      ..add(TripsIdGet200ResponseVehicle.serializer)
      ..add(TripsIdPositionGet200Response.serializer)
      ..add(TripsIdPositionGet200ResponseEtaToStopsInner.serializer)
      ..add(TripsIdPositionGet200ResponsePosition.serializer)
      ..add(TripsIdPositionGet200ResponseRiderStop.serializer)
      ..add(TripsIdPositionPost200Response.serializer)
      ..add(TripsIdPositionPostRequest.serializer)
      ..add(TripsIdSummaryGet200Response.serializer)
      ..add(TripsIdSummaryGet200ResponseByMethod.serializer)
      ..add(VersionGet200Response.serializer)
      ..add(WebhooksPaystackPost200Response.serializer)
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(AdminDriverRequestsGet200ResponseRequestsInner)
          ]),
          () => ListBuilder<AdminDriverRequestsGet200ResponseRequestsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(AdminIncidentsGet200ResponseIncidentsInner)
          ]),
          () => ListBuilder<AdminIncidentsGet200ResponseIncidentsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(AdminLearnRoutesPost200ResponseRoutesInner)
          ]),
          () => ListBuilder<AdminLearnRoutesPost200ResponseRoutesInner>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(AdminPlanPricingGet200ResponsePlansInner)]),
          () => ListBuilder<AdminPlanPricingGet200ResponsePlansInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(AdminRoutesIdFaresGet200ResponseFaresInner)
          ]),
          () => ListBuilder<AdminRoutesIdFaresGet200ResponseFaresInner>())
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
          const FullType(BuiltList,
              const [const FullType(MeIncidentsGet200ResponseIncidentsInner)]),
          () => ListBuilder<MeIncidentsGet200ResponseIncidentsInner>())
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
          const FullType(BuiltList, const [
            const FullType(MeWorkRequestsGet200ResponseRequestsInner)
          ]),
          () => ListBuilder<MeWorkRequestsGet200ResponseRequestsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(MeWorkRoutesGet200ResponseRoutesInner)]),
          () => ListBuilder<MeWorkRoutesGet200ResponseRoutesInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(RoutesIdGeometryGet200ResponsePointsInner)
          ]),
          () => ListBuilder<RoutesIdGeometryGet200ResponsePointsInner>())
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

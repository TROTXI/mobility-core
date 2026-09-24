// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serializers.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializers _$serializers = (Serializers().toBuilder()
      ..add(AccessBlock.serializer)
      ..add(AccessBlockKindEnum.serializer)
      ..add(AccessBlockScopeEnum.serializer)
      ..add(Account.serializer)
      ..add(AccountResponse.serializer)
      ..add(AccountRoleEnum.serializer)
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
      ..add(AdminDriversIdCredentialsResetPinPost200Response.serializer)
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
      ..add(AppleSignIn.serializer)
      ..add(ArrivalInput.serializer)
      ..add(AuthApplePostRequest.serializer)
      ..add(AuthDriverPinPostRequest.serializer)
      ..add(AuthDriverPost200Response.serializer)
      ..add(AuthDriverPost200ResponseDriver.serializer)
      ..add(AuthDriverPostRequest.serializer)
      ..add(AuthGooglePost200Response.serializer)
      ..add(AuthGooglePostRequest.serializer)
      ..add(AuthRefreshPost200Response.serializer)
      ..add(AuthRefreshPostRequest.serializer)
      ..add(Avatar.serializer)
      ..add(AvatarResponse.serializer)
      ..add(BoardingBoardPost200Response.serializer)
      ..add(BoardingBoardPost200ResponseReasonEnum.serializer)
      ..add(BoardingBoardPostRequest.serializer)
      ..add(BoardingInput.serializer)
      ..add(BoardingInputOneOf.serializer)
      ..add(BoardingInputOneOf1.serializer)
      ..add(BoardingInputOneOf1KindEnum.serializer)
      ..add(BoardingInputOneOf2.serializer)
      ..add(BoardingInputOneOf2KindEnum.serializer)
      ..add(BoardingInputOneOfKindEnum.serializer)
      ..add(BoardingManifestGet200Response.serializer)
      ..add(BoardingManifestGet200ResponseRidersInner.serializer)
      ..add(BoardingManifestGet200ResponseRidersInnerDirectionEnum.serializer)
      ..add(BoardingManifestGet200ResponseRidersInnerSource_Enum.serializer)
      ..add(BoardingNoShowPost200Response.serializer)
      ..add(BoardingNoShowPost200ResponseReasonEnum.serializer)
      ..add(BoardingResult.serializer)
      ..add(BoardingResultResponse.serializer)
      ..add(BoardingResultStatusEnum.serializer)
      ..add(BoardingScanPost200Response.serializer)
      ..add(BoardingScanPost200ResponseReasonEnum.serializer)
      ..add(BoardingScanPostRequest.serializer)
      ..add(BoardingVerifyCodePost200Response.serializer)
      ..add(BoardingVerifyCodePost200ResponseReasonEnum.serializer)
      ..add(BoardingVerifyCodePostRequest.serializer)
      ..add(BoardingVerifyPinPost200Response.serializer)
      ..add(BoardingVerifyPinPost200ResponseReasonEnum.serializer)
      ..add(BoardingVerifyPinPostRequest.serializer)
      ..add(Bootstrap.serializer)
      ..add(BootstrapApplicationsInner.serializer)
      ..add(BootstrapApplicationsInnerApiMajorEnum.serializer)
      ..add(BootstrapApplicationsInnerAppEnum.serializer)
      ..add(BootstrapApplicationsInnerPlatformEnum.serializer)
      ..add(BootstrapFlagsInner.serializer)
      ..add(BootstrapMapTiles.serializer)
      ..add(BootstrapOperations.serializer)
      ..add(Build.serializer)
      ..add(CommuteDecision.serializer)
      ..add(CommuteDecisionOneOf.serializer)
      ..add(CommuteDecisionOneOf1.serializer)
      ..add(CommuteDecisionOneOf1ActionEnum.serializer)
      ..add(CommuteDecisionOneOf2.serializer)
      ..add(CommuteDecisionOneOf2ActionEnum.serializer)
      ..add(CommuteDecisionOneOf3.serializer)
      ..add(CommuteDecisionOneOf3ActionEnum.serializer)
      ..add(CommuteDecisionOneOf4.serializer)
      ..add(CommuteDecisionOneOf4ActionEnum.serializer)
      ..add(CommuteDecisionOneOf5.serializer)
      ..add(CommuteDecisionOneOf5ActionEnum.serializer)
      ..add(CommuteDecisionOneOf6.serializer)
      ..add(CommuteDecisionOneOf6ActionEnum.serializer)
      ..add(CommuteDecisionOneOfActionEnum.serializer)
      ..add(CommuteLeg.serializer)
      ..add(CommuteLegDirectionEnum.serializer)
      ..add(CommuteLegView.serializer)
      ..add(CommuteLegViewDirectionEnum.serializer)
      ..add(CommuteLegViewTimeZoneEnum.serializer)
      ..add(CommuteRequest.serializer)
      ..add(CommuteRequestInput.serializer)
      ..add(CommuteRequestPage.serializer)
      ..add(CommuteRequestPagePage.serializer)
      ..add(CommuteRequestResponse.serializer)
      ..add(CommuteRequestStatusEnum.serializer)
      ..add(CommuteSlot.serializer)
      ..add(CommuteSlotInput.serializer)
      ..add(CommuteSlotPage.serializer)
      ..add(CommuteSlotResponse.serializer)
      ..add(CommuteSlotStateEnum.serializer)
      ..add(CredentialAction.serializer)
      ..add(CredentialActionActionEnum.serializer)
      ..add(CredentialIssue.serializer)
      ..add(CredentialSecret.serializer)
      ..add(CredentialSecretResponse.serializer)
      ..add(CreditEntry.serializer)
      ..add(CreditEntryCurrencyEnum.serializer)
      ..add(CreditEntryPage.serializer)
      ..add(CreditEntryReasonEnum.serializer)
      ..add(DecisionEvent.serializer)
      ..add(DecisionEventPage.serializer)
      ..add(Device.serializer)
      ..add(DeviceInput.serializer)
      ..add(DeviceInputPlatformEnum.serializer)
      ..add(DevicePlatformEnum.serializer)
      ..add(DeviceResponse.serializer)
      ..add(Driver.serializer)
      ..add(DriverEdit.serializer)
      ..add(DriverInput.serializer)
      ..add(DriverPage.serializer)
      ..add(DriverResponse.serializer)
      ..add(DriverSelf.serializer)
      ..add(DriverSelfCredential.serializer)
      ..add(DriverSelfCredentialStatusEnum.serializer)
      ..add(DriverSelfResponse.serializer)
      ..add(DriverSignIn.serializer)
      ..add(DriverTokens.serializer)
      ..add(DriverTokensDriver.serializer)
      ..add(DriverTokensResponse.serializer)
      ..add(DriverTrip.serializer)
      ..add(DriverTripDirectionEnum.serializer)
      ..add(DriverTripPage.serializer)
      ..add(DriverTripResponse.serializer)
      ..add(DriverTripRunNumberEnum.serializer)
      ..add(DriverTripStatusEnum.serializer)
      ..add(ErrorResponse.serializer)
      ..add(ErrorResponseError.serializer)
      ..add(ErrorResponseErrorFieldErrorsInner.serializer)
      ..add(Fare.serializer)
      ..add(FareInput.serializer)
      ..add(FarePage.serializer)
      ..add(FareResponse.serializer)
      ..add(Flag.serializer)
      ..add(FlagEdit.serializer)
      ..add(FlagPage.serializer)
      ..add(FlagResponse.serializer)
      ..add(FlagsGet200Response.serializer)
      ..add(FlagsGet200ResponseFlagsInner.serializer)
      ..add(FlagsGet200ResponseMapTiles.serializer)
      ..add(FlagsGet200ResponseMinSupportedVersion.serializer)
      ..add(FlagsGet200ResponseOperations.serializer)
      ..add(Geometry.serializer)
      ..add(GeometryResponse.serializer)
      ..add(GeometrySource_Enum.serializer)
      ..add(GeometryStopDistancesInner.serializer)
      ..add(Get200Response.serializer)
      ..add(GoogleSignIn.serializer)
      ..add(Health.serializer)
      ..add(HealthStatusEnum.serializer)
      ..add(HealthzGet200Response.serializer)
      ..add(HealthzGet200ResponseStatusEnum.serializer)
      ..add(Incident.serializer)
      ..add(IncidentCategoryEnum.serializer)
      ..add(IncidentDecision.serializer)
      ..add(IncidentDecisionStatusEnum.serializer)
      ..add(IncidentInput.serializer)
      ..add(IncidentInputCategoryEnum.serializer)
      ..add(IncidentLocation.serializer)
      ..add(IncidentPage.serializer)
      ..add(IncidentResponse.serializer)
      ..add(IncidentStatusEnum.serializer)
      ..add(LiveTrip.serializer)
      ..add(LiveTripPosition.serializer)
      ..add(LiveTripResponse.serializer)
      ..add(LiveTripStateEnum.serializer)
      ..add(MaintenanceInput.serializer)
      ..add(MaintenanceResult.serializer)
      ..add(MaintenanceResultFailuresInner.serializer)
      ..add(MaintenanceResultResponse.serializer)
      ..add(Manifest.serializer)
      ..add(ManifestResponse.serializer)
      ..add(ManifestRider.serializer)
      ..add(ManifestRiderStatusEnum.serializer)
      ..add(MeAvatarGet200Response.serializer)
      ..add(MeBalanceGet200Response.serializer)
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
      ..add(Membership.serializer)
      ..add(MembershipAccess.serializer)
      ..add(MembershipCommute.serializer)
      ..add(MembershipCoverage.serializer)
      ..add(MembershipCoverageRenewalModeEnum.serializer)
      ..add(MembershipCoverageStateEnum.serializer)
      ..add(MembershipEntitlements.serializer)
      ..add(MembershipMembership.serializer)
      ..add(MembershipMembershipLifecycleEnum.serializer)
      ..add(MembershipResponse.serializer)
      ..add(MinimumVersion.serializer)
      ..add(MinimumVersionApiMajorEnum.serializer)
      ..add(MinimumVersionAppEnum.serializer)
      ..add(MinimumVersionEdit.serializer)
      ..add(MinimumVersionEditApiMajorEnum.serializer)
      ..add(MinimumVersionPage.serializer)
      ..add(MinimumVersionPlatformEnum.serializer)
      ..add(MinimumVersionResponse.serializer)
      ..add(Money.serializer)
      ..add(MoneyCurrencyEnum.serializer)
      ..add(OpsCommuteRequest.serializer)
      ..add(OpsCommuteRequestPage.serializer)
      ..add(OpsCommuteRequestResponse.serializer)
      ..add(OpsCommuteRequestStatusEnum.serializer)
      ..add(OpsIncident.serializer)
      ..add(OpsIncidentCategoryEnum.serializer)
      ..add(OpsIncidentPage.serializer)
      ..add(OpsIncidentResponse.serializer)
      ..add(OpsIncidentStatusEnum.serializer)
      ..add(OpsOverview.serializer)
      ..add(OpsOverviewResponse.serializer)
      ..add(OpsOverviewTripsInner.serializer)
      ..add(OpsOverviewTripsInnerBadgeEnum.serializer)
      ..add(OpsOverviewTripsInnerStatusEnum.serializer)
      ..add(OpsOverviewWindowEnum.serializer)
      ..add(OpsPurchase.serializer)
      ..add(OpsPurchaseAttemptsInner.serializer)
      ..add(OpsPurchaseAttemptsInnerEnvironmentEnum.serializer)
      ..add(OpsPurchaseAttemptsInnerReceivedAmount.serializer)
      ..add(OpsPurchaseAttemptsInnerReceivedAmountCurrencyEnum.serializer)
      ..add(OpsPurchaseAttemptsInnerStatusEnum.serializer)
      ..add(OpsPurchaseCheckout.serializer)
      ..add(OpsPurchaseCollectionStateEnum.serializer)
      ..add(OpsPurchasePage.serializer)
      ..add(OpsPurchasePlanEnum.serializer)
      ..add(OpsPurchaseResponse.serializer)
      ..add(OpsPurchaseStateEnum.serializer)
      ..add(OpsTrip.serializer)
      ..add(OpsTripDirectionEnum.serializer)
      ..add(OpsTripPage.serializer)
      ..add(OpsTripResponse.serializer)
      ..add(OpsTripRunNumberEnum.serializer)
      ..add(OpsTripStatusEnum.serializer)
      ..add(OpsWorkRequest.serializer)
      ..add(OpsWorkRequestPage.serializer)
      ..add(OpsWorkRequestResponse.serializer)
      ..add(OpsWorkRequestStatusEnum.serializer)
      ..add(OptionalPersonalPause.serializer)
      ..add(OptionalPersonalPauseResponse.serializer)
      ..add(OptionalPersonalPauseStatusEnum.serializer)
      ..add(Pass.serializer)
      ..add(PassResponse.serializer)
      ..add(Pattern.serializer)
      ..add(PatternDirectionEnum.serializer)
      ..add(PatternInput.serializer)
      ..add(PatternInputDirectionEnum.serializer)
      ..add(PatternPage.serializer)
      ..add(PatternResponse.serializer)
      ..add(PatternVersion.serializer)
      ..add(PatternVersionInput.serializer)
      ..add(PatternVersionInputGeometry.serializer)
      ..add(PatternVersionInputStopsInner.serializer)
      ..add(PatternVersionPage.serializer)
      ..add(PatternVersionResponse.serializer)
      ..add(PatternVersionStateEnum.serializer)
      ..add(PaymentMaintenanceResult.serializer)
      ..add(PaymentMaintenanceResultResponse.serializer)
      ..add(PaymentReview.serializer)
      ..add(PaymentReviewKindEnum.serializer)
      ..add(PaymentReviewPage.serializer)
      ..add(PaymentReviewResponse.serializer)
      ..add(PaymentsSubscribePost200Response.serializer)
      ..add(PaymentsSubscribePostRequest.serializer)
      ..add(PaymentsSubscribePostRequestPlanEnum.serializer)
      ..add(PaymentsTopupPostRequest.serializer)
      ..add(PersonalPause.serializer)
      ..add(PersonalPauseInput.serializer)
      ..add(PersonalPausePreview.serializer)
      ..add(PersonalPausePreviewResponse.serializer)
      ..add(PersonalPauseResponse.serializer)
      ..add(PersonalPauseStatusEnum.serializer)
      ..add(PersonalResumeInput.serializer)
      ..add(PinChange.serializer)
      ..add(PlanPricing.serializer)
      ..add(PlanPricingPage.serializer)
      ..add(PlanPricingPlanEnum.serializer)
      ..add(PlanPricingResponse.serializer)
      ..add(Point.serializer)
      ..add(PositionInput.serializer)
      ..add(PositionReceipt.serializer)
      ..add(PositionReceiptResponse.serializer)
      ..add(PricingEdit.serializer)
      ..add(ProfileUpdate.serializer)
      ..add(PublishVersionInput.serializer)
      ..add(Purchase.serializer)
      ..add(PurchaseCollectionStateEnum.serializer)
      ..add(PurchaseInput.serializer)
      ..add(PurchaseInputPlanEnum.serializer)
      ..add(PurchasePage.serializer)
      ..add(PurchasePlanEnum.serializer)
      ..add(PurchaseQuote.serializer)
      ..add(PurchaseQuoteInput.serializer)
      ..add(PurchaseQuoteInputPlanEnum.serializer)
      ..add(PurchaseQuotePlanEnum.serializer)
      ..add(PurchaseQuoteRenewalModeEnum.serializer)
      ..add(PurchaseQuoteResponse.serializer)
      ..add(PurchaseResponse.serializer)
      ..add(PurchaseStateEnum.serializer)
      ..add(ReadyzGet200Response.serializer)
      ..add(ReadyzGet200ResponseStatusEnum.serializer)
      ..add(ReadyzGet503Response.serializer)
      ..add(ReadyzGet503ResponseStatusEnum.serializer)
      ..add(ReasonInput.serializer)
      ..add(ReceivePaystackWebhookRequest.serializer)
      ..add(RefreshInput.serializer)
      ..add(RefundInitiation.serializer)
      ..add(RefundInitiationCollection.serializer)
      ..add(RefundInitiationCollectionResponse.serializer)
      ..add(RefundInitiationInput.serializer)
      ..add(RefundInitiationResponse.serializer)
      ..add(RefundInitiationStateEnum.serializer)
      ..add(Reservation.serializer)
      ..add(ReservationDecision.serializer)
      ..add(ReservationDecisionDecisionEnum.serializer)
      ..add(ReservationDecisionDirectionEnum.serializer)
      ..add(ReservationDecisionResult.serializer)
      ..add(ReservationDecisionResultPass.serializer)
      ..add(ReservationDecisionResultResponse.serializer)
      ..add(ReservationDirectionEnum.serializer)
      ..add(ReservationPage.serializer)
      ..add(ReservationSource_Enum.serializer)
      ..add(ReservationStatusEnum.serializer)
      ..add(Restriction.serializer)
      ..add(RestrictionInput.serializer)
      ..add(RestrictionResponse.serializer)
      ..add(ReviewDecision.serializer)
      ..add(ReviewDecisionDecisionEnum.serializer)
      ..add(RideEntry.serializer)
      ..add(RideEntryPage.serializer)
      ..add(RideEntryReasonEnum.serializer)
      ..add(RoleEdit.serializer)
      ..add(RoleEditRoleEnum.serializer)
      ..add(Root.serializer)
      ..add(Route.serializer)
      ..add(RouteEdit.serializer)
      ..add(RouteInput.serializer)
      ..add(RoutePage.serializer)
      ..add(RouteResponse.serializer)
      ..add(RoutesGet200ResponseInner.serializer)
      ..add(RoutesIdGeometryGet200Response.serializer)
      ..add(RoutesIdGeometryGet200ResponsePointsInner.serializer)
      ..add(RoutesIdGeometryGet200ResponseSource_Enum.serializer)
      ..add(RoutesIdGet200Response.serializer)
      ..add(RoutesIdGet200ResponseStopsInner.serializer)
      ..add(Schedule.serializer)
      ..add(ScheduleInput.serializer)
      ..add(ScheduleInputDeparture.serializer)
      ..add(ScheduleInputDepartureOneOf.serializer)
      ..add(ScheduleInputDepartureOneOf1.serializer)
      ..add(ScheduleInputDepartureOneOf1KindEnum.serializer)
      ..add(ScheduleInputDepartureOneOfKindEnum.serializer)
      ..add(ScheduleInputServiceWindowEnum.serializer)
      ..add(ScheduleInputTimeZoneEnum.serializer)
      ..add(SchedulePage.serializer)
      ..add(ScheduleResponse.serializer)
      ..add(ScheduleServiceWindowEnum.serializer)
      ..add(ScheduleTimeZoneEnum.serializer)
      ..add(ServiceDayInput.serializer)
      ..add(ServiceDayInputDirectionEnum.serializer)
      ..add(Session.serializer)
      ..add(SessionPage.serializer)
      ..add(Stop.serializer)
      ..add(StopEdit.serializer)
      ..add(StopEta.serializer)
      ..add(StopEtaBasisEnum.serializer)
      ..add(StopInput.serializer)
      ..add(StopOccurrence.serializer)
      ..add(StopPage.serializer)
      ..add(StopResponse.serializer)
      ..add(Tokens.serializer)
      ..add(TokensResponse.serializer)
      ..add(TraceHold.serializer)
      ..add(TraceHoldInput.serializer)
      ..add(TraceHoldPage.serializer)
      ..add(TraceHoldResponse.serializer)
      ..add(TraceHoldStateEnum.serializer)
      ..add(Trip.serializer)
      ..add(TripAssignment.serializer)
      ..add(TripDirectionEnum.serializer)
      ..add(TripEdit.serializer)
      ..add(TripGenerationInput.serializer)
      ..add(TripInput.serializer)
      ..add(TripInputRunNumberEnum.serializer)
      ..add(TripPage.serializer)
      ..add(TripResponse.serializer)
      ..add(TripRunNumberEnum.serializer)
      ..add(TripStatusEnum.serializer)
      ..add(TripSummary.serializer)
      ..add(TripSummaryResponse.serializer)
      ..add(TripSummaryStatusEnum.serializer)
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
      ..add(Vehicle.serializer)
      ..add(VehicleEdit.serializer)
      ..add(VehicleInput.serializer)
      ..add(VehiclePage.serializer)
      ..add(VehicleResponse.serializer)
      ..add(VersionGet200Response.serializer)
      ..add(WebhookAck.serializer)
      ..add(WebhooksPaystackPost200Response.serializer)
      ..add(WorkDecision.serializer)
      ..add(WorkDecisionStatusEnum.serializer)
      ..add(WorkRequest.serializer)
      ..add(WorkRequestInput.serializer)
      ..add(WorkRequestInputOneOf.serializer)
      ..add(WorkRequestInputOneOf1.serializer)
      ..add(WorkRequestInputOneOf1KindEnum.serializer)
      ..add(WorkRequestInputOneOfKindEnum.serializer)
      ..add(WorkRequestPage.serializer)
      ..add(WorkRequestResponse.serializer)
      ..add(WorkRequestStatusEnum.serializer)
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(AccessBlock)]),
          () => ListBuilder<AccessBlock>())
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
              BuiltList, const [const FullType(BootstrapApplicationsInner)]),
          () => ListBuilder<BootstrapApplicationsInner>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(BootstrapFlagsInner)]),
          () => ListBuilder<BootstrapFlagsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(CommuteLeg)]),
          () => ListBuilder<CommuteLeg>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(CommuteLeg)]),
          () => ListBuilder<CommuteLeg>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(CommuteLeg)]),
          () => ListBuilder<CommuteLeg>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(CommuteLeg)]),
          () => ListBuilder<CommuteLeg>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(CommuteLegView)]),
          () => ListBuilder<CommuteLegView>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(CommuteRequest)]),
          () => ListBuilder<CommuteRequest>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(CommuteSlot)]),
          () => ListBuilder<CommuteSlot>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(CreditEntry)]),
          () => ListBuilder<CreditEntry>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(DecisionEvent)]),
          () => ListBuilder<DecisionEvent>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Driver)]),
          () => ListBuilder<Driver>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(DriverTrip)]),
          () => ListBuilder<DriverTrip>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(ErrorResponseErrorFieldErrorsInner)]),
          () => ListBuilder<ErrorResponseErrorFieldErrorsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Fare)]),
          () => ListBuilder<Fare>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Flag)]),
          () => ListBuilder<Flag>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(FlagsGet200ResponseFlagsInner)]),
          () => ListBuilder<FlagsGet200ResponseFlagsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Incident)]),
          () => ListBuilder<Incident>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(MaintenanceResultFailuresInner)]),
          () => ListBuilder<MaintenanceResultFailuresInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ManifestRider)]),
          () => ListBuilder<ManifestRider>())
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
          const FullType(BuiltList, const [const FullType(MinimumVersion)]),
          () => ListBuilder<MinimumVersion>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(OpsCommuteRequest)]),
          () => ListBuilder<OpsCommuteRequest>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(OpsIncident)]),
          () => ListBuilder<OpsIncident>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(OpsOverviewTripsInner)]),
          () => ListBuilder<OpsOverviewTripsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(OpsPurchase)]),
          () => ListBuilder<OpsPurchase>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(OpsPurchaseAttemptsInner)]),
          () => ListBuilder<OpsPurchaseAttemptsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(OpsTrip)]),
          () => ListBuilder<OpsTrip>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(OpsWorkRequest)]),
          () => ListBuilder<OpsWorkRequest>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Pattern)]),
          () => ListBuilder<Pattern>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(PatternVersion)]),
          () => ListBuilder<PatternVersion>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(PatternVersionInputStopsInner)]),
          () => ListBuilder<PatternVersionInputStopsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(PaymentReview)]),
          () => ListBuilder<PaymentReview>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(PlanPricing)]),
          () => ListBuilder<PlanPricing>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Point)]),
          () => ListBuilder<Point>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GeometryStopDistancesInner)]),
          () => ListBuilder<GeometryStopDistancesInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Point)]),
          () => ListBuilder<Point>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(num)]),
          () => ListBuilder<num>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Purchase)]),
          () => ListBuilder<Purchase>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(RefundInitiation)]),
          () => ListBuilder<RefundInitiation>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Reservation)]),
          () => ListBuilder<Reservation>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(RideEntry)]),
          () => ListBuilder<RideEntry>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Route)]),
          () => ListBuilder<Route>())
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
          const FullType(BuiltList, const [const FullType(Schedule)]),
          () => ListBuilder<Schedule>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Session)]),
          () => ListBuilder<Session>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Stop)]),
          () => ListBuilder<Stop>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(StopEta)]),
          () => ListBuilder<StopEta>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(StopOccurrence)]),
          () => ListBuilder<StopOccurrence>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(StopOccurrence)]),
          () => ListBuilder<StopOccurrence>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(StopOccurrence)]),
          () => ListBuilder<StopOccurrence>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(TraceHold)]),
          () => ListBuilder<TraceHold>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Trip)]),
          () => ListBuilder<Trip>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(TripsGet200ResponseTripsInner)]),
          () => ListBuilder<TripsGet200ResponseTripsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(TripsIdPositionGet200ResponseEtaToStopsInner)
          ]),
          () => ListBuilder<TripsIdPositionGet200ResponseEtaToStopsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Vehicle)]),
          () => ListBuilder<Vehicle>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(WorkRequest)]),
          () => ListBuilder<WorkRequest>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => ListBuilder<int>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => ListBuilder<int>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>()))
    .build();

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

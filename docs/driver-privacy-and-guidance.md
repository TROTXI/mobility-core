# Driver privacy and operating guidance — pilot draft

Updated 26 September 2026. The app's Profile → Privacy & driver guidance screen
contains the practical driver notice and uses configured operations contacts,
not an invented support address. This document records its publication limits.

## Research and design decisions

[Uber's driver notice](https://www.uber.com/global/en/privacy-notice-drivers-delivery-people/)
and [Bolt's driver notice](https://bolt.eu/en/privacy/rides/privacy-for-drivers/)
organise notices around data collected, purposes, recipients and driver controls.
We use that structure, not their advertising, employment or commercial policies.
Trotxi's tracking boundary is a confirmed active trip, not merely being signed in.

[Android's location foreground-service guidance](https://developer.android.com/develop/background-work/services/fgs/service-types#location)
requires starting a while-in-use location service while the app is visible.
The established service may continue with the app hidden; the controller never
starts a newly discovered run from a background roster response. It rechecks
assignments while its execution remains available and stops on removal or logout.
No background-location permission, boot receiver or new server service is added.

[Apple background location guidance](https://developer.apple.com/documentation/corelocation/handling-location-updates-in-the-background)
and the installed Geolocator API inform the background mode and visible indicator.
Physical-device permission and suspension behaviour still need verification;
this is not a promise of recovery after the OS kills the process.

[Google Play's disclosure requirements](https://support.google.com/googleplay/android-developer/answer/9799150)
inform the dedicated disclosure before requesting location access. Permission
denial remains possible; camera and notification consent are separate.

## Notice content and evidence

The app describes identity/profile and photo, assignments, boarding, incidents,
work requests, device notification registration and Firebase analytics, crash and
performance diagnostics. It explains
precise active-trip location, eligible rider/operations access, and safe use.
It does not describe payments as driver salary, advertise 24/7 support, or claim
an incident form summons emergency help.

The offline queue retains at most 1,440 fixes, with 24-hour expiry when processed
and deletion on logout. Raw server traces are eligible for deletion after 30 days
except evidence windows covered by an active hold; maintenance must actually run.
Route-learning samples and trip/history records have different lifetimes, so
the notice does not claim that all information disappears at 30 days.

## Required before publishing final legal terms

- Confirm the legal operator/data controller's name, address and privacy contact.
- Approve record-specific retention schedules and ensure workers run as promised.
- Confirm processor locations, cross-border safeguards and contractual terms.
- Review lawful bases, driver rights and complaints under Ghana's
  [Data Protection Act, 2012](https://cybersecurity.gov.gh/documents/Data_Protection_Act_2012.pdf).
- Publish a public privacy URL for store listings, matching the in-app notice.
- Confirm emergency escalation, support hours and driver/operator agreements.

Until those business/legal facts are supplied, the screen is pilot information,
not final legal terms or a claim that legal compliance has been certified.

## Device acceptance walkthrough

Local verification: 220 driver tests pass, Flutter analysis is clean, Android
debug APK builds, and the merged manifest declares the location foreground
service and permission. The iOS plist passes syntax validation. These checks
do not establish physical-device lock-screen delivery or iOS background reliability.

The tracking notification accent and privacy screen use the existing driver
tokens. Android controls the actual notification surface and lock-screen
visibility; iOS controls its location indicator. The installed Geolocator
Android plugin creates its channel with low visibility (`IMPORTANCE_NONE`),
so a notification card on the lock screen is not guaranteed. Background GPS
and a custom lock-screen widget are different features. No custom widget is
installed, no rider details are put in notification text, and device notification
preferences are not overridden.

On a physical Android phone and, when available, an iPhone: deny location and
verify no trip can start; allow it, start a disposable assigned trip and check
the native tracking notification/indicator. Lock the screen for five minutes
while moving and verify fresh receipts reach staging with original captures.
Repeat with the network unavailable, reconnect and verify one receipt per fix.
Withdraw the assignment and verify collection stops after a successful roster
check. Finish/sign out and verify the native session stops. Force-stop/reboot,
reopen and check active-run recovery without claiming collection during downtime.

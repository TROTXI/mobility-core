# Store submission readiness

**Owner:** Godfred Awuku · **Last updated:** 2026-09-02

**Status:** 🟡 nothing submitted. Two apps, two listings, two sets of everything.

What has to exist before `trotxi_commuter` and `trotxi_driver` can go up. The
privacy answers below are pre-filled from [data-handling.md](data-handling.md),
so fill the forms from here rather than from memory, and change this file when a
data flow changes.

---

## Decide this first

**Does the driver app go on the public stores at all?** It is a tool for staff,
not a consumer product, and putting it on a public listing is the expensive
choice. Apple will ask why a member of the public would download an app they
cannot use, which is a real rejection risk, and Play's background location review
is the hardest single item on this page.

Internal distribution avoids most of it: TestFlight or Apple Business Manager on
one side, a Play internal or closed track on the other. No public listing, no
screenshots, no content rating, and a far shorter privacy review. Unless there is
a reason drivers must find it by searching the store, distribute it privately.
Everything below marked **[driver]** only applies if you choose a public listing.

## Apple App Store

### Blocking today

- [ ] **Apple Developer Program enrolment.** Needs a D-U-N-S number for an
      organisation, which is the slow part. This is [#168](https://github.com/TROTXI/mobility-core/issues/168)
      step 1 and it blocks everything else Apple, including finishing Apple sign-in.
- [ ] **App ID, Services ID, and the `.p8` key.** [#168](https://github.com/TROTXI/mobility-core/issues/168)
      steps 2 to 5. Bundle id is `com.trotxi.trotxiCommuter`.
- [ ] **Set the Apple env vars on Render**, or sign-in returns 503 in production
      and revocation silently does nothing. `APPLE_CLIENT_ID`, `APPLE_TEAM_ID`,
      `APPLE_KEY_ID` are safe to commit; `APPLE_PRIVATE_KEY` is dashboard only.
- [ ] **`PrivacyInfo.xcprivacy` in both app targets.** Neither exists. It declares
      collected data types and required-reason API use, and its absence fails at
      upload rather than at review.
- [ ] **`Info.plist` usage strings.** Both plists are stock. Every permission the
      app touches needs a sentence a rider would understand. Vague strings are one
      of the most common rejections there is.

### Why Apple sign-in is not optional

The commuter app offers Google sign-in, and Apple requires an app offering a
third-party sign-in service to offer Sign in with Apple alongside it. That is the
whole reason [#168](https://github.com/TROTXI/mobility-core/issues/168) exists.
The backend is done and merged; the Flutter screen is not built, and no
`sign_in_with_apple` package is in `pubspec.yaml` yet.

Apple also requires that an app offering account creation offers in-app account
deletion. We have it: `DELETE /me`, reachable from Profile, no email and no
waiting. Point the reviewer at it in the review notes, because they will look.

### App Privacy labels

Answer **"Data Not Linked to You"** only where it says so; everything else is
linked, because it hangs off an account.

| Category                                | Collected                | Linked     | Purpose                      |
| --------------------------------------- | ------------------------ | ---------- | ---------------------------- |
| Contact Info: Name, Email               | Yes                      | Yes        | App Functionality            |
| Contact Info: Phone Number              | Yes                      | Yes        | App Functionality            |
| Identifiers: User ID                    | Yes                      | Yes        | App Functionality            |
| Identifiers: Device ID                  | Yes                      | Not linked | Analytics, App Functionality |
| Purchases: Purchase History             | Yes                      | Yes        | App Functionality            |
| User Content: Photos                    | Yes (avatar, optional)   | Yes        | App Functionality            |
| Usage Data: Product Interaction         | Yes                      | Not linked | Analytics                    |
| Diagnostics: Crash and Performance Data | Yes                      | Not linked | App Functionality            |
| **Location**                            | **No** for the rider app |            |                              |

**Tracking: No.** We do not share data with brokers and we do not track across
other companies' apps. That answer holds only while no advertising SDK and no
IDFA use enters the app. Add either and you inherit App Tracking Transparency and
its prompt, so treat that as a decision rather than a dependency bump.

**[driver] Location: Yes, Precise, Linked, App Functionality.** The driver app
will report vehicle GPS once built. Nothing collects it today.

### Also needed

- [ ] Screenshots at every required size, for each app
- [ ] App icon, description, keywords, support URL, marketing URL
- [ ] Privacy policy URL, live and reachable
- [ ] Age rating questionnaire
- [ ] Export compliance. Standard HTTPS normally qualifies for the exemption, but it is asked on every submission
- [ ] **A demo account for App Review**, with an active subscription and a booked
      trip. Reviewers are not in Accra and cannot board a van, so an app that
      shows an empty state will be rejected as incomplete. Seed one that looks
      like a real rider mid-week.

## Google Play

### Blocking today

- [ ] **Play Console account** for the organisation
- [ ] **`AndroidManifest.xml` permissions.** Both manifests declare none. Push
      needs `POST_NOTIFICATIONS` on Android 13 and up, and **[driver]** GPS needs
      the location permissions
- [ ] **A data deletion URL.** This is the one people miss. In-app deletion is not
      sufficient on its own: Play wants a URL where someone who has uninstalled
      the app can still request deletion. Put a form at
      `https://trotxi.com/delete-account` that reaches [PRIVACY CONTACT EMAIL]

### Data Safety form

Same facts as the Apple table, different shape. Declare collected, linked to the
user, not shared with third parties for advertising, and **"Data is encrypted in
transit": yes**.

| Data type                                         | Collected                | Shared | Purpose                               |
| ------------------------------------------------- | ------------------------ | ------ | ------------------------------------- |
| Personal info: Name, Email, Phone, User IDs       | Yes                      | No     | Account management, App functionality |
| Photos                                            | Yes (optional)           | No     | App functionality                     |
| Financial info: Purchase history                  | Yes                      | No     | App functionality                     |
| App activity: App interactions                    | Yes                      | No     | Analytics                             |
| App info and performance: Crash logs, Diagnostics | Yes                      | No     | App functionality                     |
| Device or other IDs                               | Yes                      | No     | Analytics                             |
| **Location**                                      | **No** for the rider app |        |                                       |

Declare deletion honestly: users can request deletion **and** we delete some data
while retaining anonymised financial records. There is a specific answer for that
combination, and the policy explains why.

**[driver] Background location is the hard one.** Play requires a separate
permission declaration and a video showing the in-app feature that needs it, and
reviews take longer and fail more often than anything else here. Another reason
to distribute the driver app privately.

### Also needed

- [ ] Target API level meeting the current Play requirement
- [ ] Signed release build, Play App Signing enrolled
- [ ] Content rating questionnaire
- [ ] Store listing: screenshots, feature graphic, short and full description
- [ ] Advertising ID declaration. We do not use it, and Firebase Analytics can
      pull it in transitively, so verify the merged manifest rather than assuming
- [ ] Check whether the closed-testing requirement applies to this account type
      before planning a launch date, because it adds weeks

## Shared, and not yet started

- [ ] **Host the privacy policy.** Both stores need a live URL, and Play needs it
      in the Console as well as in the listing
- [ ] **Link it from inside both apps**, on the profile screen
- [ ] **Terms of Service.** Not written. A paid transport service carries real
      liability questions, and this is the document that should not be adapted
      from a template found online
- [ ] **Register with Ghana's Data Protection Commission** under Act 843
- [ ] **Data processing agreements** with Render, Paystack, Cloudflare and Google
- [ ] **Decide the analytics consent model.** Firebase Analytics, Crashlytics and
      Performance are in both apps and start collecting at launch, before a rider
      has agreed to anything

## The order I would do it in

1. Apple Developer enrolment, today, because the D-U-N-S wait is the long pole and everything Apple queues behind it
2. Host the privacy policy and stand up the deletion URL, since both are small and both are hard blocks
3. Permissions and usage strings in both apps, alongside the screens that need them
4. DPC registration and the processor agreements, which run in parallel with everything and need no code
5. Fill both privacy forms from this file
6. Terms of Service, with a lawyer

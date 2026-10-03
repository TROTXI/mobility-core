# Ops dispatcher walkthrough: 2 October 2026

Related: #171. Environment: hosted staging Ops, Safari, authenticated admin.
The selected service window was 2 October, morning. Observations were made
across 2 October Pacific / 3 October UTC. No production data, trip decisions,
account permissions or payments were changed.

## Observed on hosted staging

| Check                           | Result                                                                                                                                                            |
| ------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Admin sign-in                   | User completed passkey sign-in; authenticated Ops pages loaded.                                                                                                   |
| Scheduled and active departures | Dispatch loaded both after selecting the service date.                                                                                                            |
| Active trip detail              | Status, assigned driver/vehicle and ordered stops loaded.                                                                                                         |
| Manifest                        | Read succeeded; this test trip had no confirmed riders. Populated boarding/manifest acceptance remains untested.                                                  |
| Attention filter                | A stale-GPS active trip appeared under Needs attention. The displayed age was stale, not fresh tracking evidence.                                                 |
| Map                             | Basemap, route line, stale vehicle marker and attribution rendered in light and dark themes. Light-theme zoom worked. Original dark appearance was restored.      |
| Incidents                       | Queue loaded with no incidents awaiting review. No incident decision was exercised.                                                                               |
| Driver requests                 | An approved request was visible; Decide was disabled. No pending request was available for a decision walkthrough.                                                |
| Commute changes                 | Queue loaded with no requests awaiting review.                                                                                                                    |
| Account deletions               | Local-status disclaimer displayed; one historical closure showed three of three tracked tasks complete. This does not prove external-provider or backup deletion. |
| Standby                         | Queue was empty. Hosted acceptance is delegated separately under #105.                                                                                            |

No personal names, account IDs, provider references or screenshots containing
customer data are included in this public evidence record. Authenticated
Safari console/CSP errors and a new passkey registration were not inspected;
this record does not close #365.

## Gap found and fixed in this branch

Overview's Dispatch links discarded the selected service date.
Dispatch then loaded its default date range, so an older active trip could
disappear even when its ID was in the search field. The empty Overview date
input also showed a browser-local placeholder rather than the API's actual
service date.

The fix displays the returned service date and carries date and optional trip
search in both Dispatch links. It does not infer direction from the service
window: a morning trip can be a return trip, and Overview does not expose
actual direction. Dispatch opens with All directions; an explicit direction
in a separately supplied URL is still supported. URL dates are validated and
filters update without a component remount. Default ranges use UTC arithmetic.
Regression coverage includes morning-return/evening-outbound trips, calendar
validation, encoded trip IDs, repeated navigation and malformed URL defaults.

## Remaining acceptance before closing #171

- [ ] Merge and deploy this fix, then select an older service date and test
      both View scheduled departures and Open dispatch. The date and selected
      trip search must survive navigation, with All directions selected.
- [ ] Use an approved disposable fixture with a populated manifest and a
      pending incident or driver request. Follow the exception from the
      dispatch context through its decision and verify the resulting state
      and audit record. The read-only checks above are not this test.
- [ ] Reconcile any new gap into a focused issue, then close the tracker only
      when the remaining acceptance has evidence.

Do not manufacture an incident on a real trip or approve a real request just
to make the tracker green. Creating or changing staging fixtures needs the
owner's approval and a named target.

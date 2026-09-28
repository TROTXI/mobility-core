# Driver visual polish

Scope: presentation only; no credential, trip, boarding or GPS rules changed.

## Delivered

- All Material text slots, including primary text, inherit the bundled Poppins
  family. The existing approved colour palette and type scale are unchanged.
- List rows, dialogs, bottom sheets, icons, text buttons and loading indicators
  use the driver theme instead of platform defaults.
- Profile leads with identity and work, groups assignment alerts with device
  permissions, and places appearance settings after operational information.
- Device/light/dark appearance is a compact segmented control. Sign out remains
  explicit but no longer dominates the page as a filled red primary action.
- Schedule, Work & Requests and Incident & Support avoid repeating their page
  heading when opened beneath the Profile navigation bar. Standalone uses still
  show their heading by default.
- The Home identity header reads the driver's account photo and reflects Profile
  uploads immediately. Missing or failed photos fall back to initials, and a
  session change clears the previous driver's photo and ignores stale reads.

## Verification and boundary

The complete driver regression suite and Flutter analysis pass. Additional
checks cover Poppins across every Material text slot, theme colours, profile
scroll/taps at normal and 1.6x text size in both themes, and a single Schedule
heading beneath navigation.

The staging iOS simulator retains its existing driver account. Profile was
visually checked in light and dark, and Schedule was checked during cleanup.
This is not physical-device background-location certification.

Design source: https://www.figma.com/design/M8Pe8QmUlQws49PxKgkcgq?node-id=750-34

The Figma connector reported the account's tool-call limit during this pass.
These changes reuse the checked-in design system; they do not claim complete
pixel-by-pixel parity with every Figma frame. No replacement colours, fonts or
static assets were invented.

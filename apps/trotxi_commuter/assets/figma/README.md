# Figma commuter icons

Source: Trotxi Mobility Core, file `RrZztRtkEf6fyf8qhaIRPt`.
Light home frame `2528:207`; dark home frame `2528:294`.

These SVGs were downloaded from the Figma design-context asset exports.
Root dimensions and view boxes are preserved. `FigmaCommuterIcon` uses the
original vector pieces at their exported sizes and composes the native
rectangle geometry described in the source design. Active/inactive monochrome
states use a color filter; sun/moon illustrations retain their original fills.

Source palette: light page `#F8FAF9`, hero `#061421`, border `#E0E5E3`,
selected navigation `#067647`; dark page `#0E110F`, hero `#1F2822`,
cards `#131614`, border `#292E2B`, selected navigation `#058740`.
Dark secondary accents use `#7DD199`. Navigation dock surfaces and borders
are defined separately to match the frames.

The implementation retains bundled Inter, minimum 44px touch targets, scalable
labels and dynamic card heights instead of the fixed screenshot dimensions.

The 24 × 24 boarding-code icon is the original `2965:68` artwork used by
the approaching-vehicle frame `2444:836`. Ride layouts also reference
confirmation `2444:694`, in-trip `2444:1014`, and completion `2444:1115`.
Maps, routes, stop markers and boarding credentials use API data, never the
prototype's example map or code. System status bars remain OS-owned.

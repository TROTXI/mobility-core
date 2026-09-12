# ADR-0016 — App state: ChangeNotifier controllers scoped with provider

**Status:** accepted · **Date:** 2026-09-09 · **Applies to** `apps/trotxi_commuter`, `apps/trotxi_driver`

## Context

Both Flutter apps run on `StatefulWidget` and `setState`, with one exception:
`AppThemeController` is a `ChangeNotifier` handed down through a hand-written
`InheritedNotifier` scope. Nothing else is shared between screens, and nothing
outlives the widget that owns it.

That has been fine, because until now each screen has been a form or a list that
owns everything it draws. The next work in both apps is not shaped that way:

- The **driver's active run** is read by Today, the trip screen, the manifest and
  the boarding screens. Four screens showing four copies of "how many riders have
  boarded" will disagree, and the one a driver is looking at will be the stale one.
- **GPS publishing** has to keep running while the driver moves between screens.
  Work that outlives the widget that started it cannot live in that widget's state.
- **Offline queuing** of positions and boardings is app state, not screen state.
- Every screen needs the same four async outcomes: nothing yet, loading, data,
  failed. Hand-rolled `isLoading` booleans get this subtly wrong in a different
  way on each screen, and the one that matters (failed, with a retry) is the one
  most often skipped.
- #199 asks the same question of the commuter app's ride-lifecycle states.

Deciding this per-screen, as it comes up, is how the two apps end up with three
patterns between them.

## Decision

**`ChangeNotifier` controllers, scoped and injected with `provider`, plus a
`Loadable<T>` union for async state.** Both apps, same pattern.

- A **controller** is a `ChangeNotifier` owning one slice of app state and the
  repository calls that change it. It holds no `BuildContext`.
- **Repositories** stay as they are: they wrap the generated API client and throw
  the typed errors from `trotxi_client`. Controllers catch those and turn them
  into state. Widgets touch neither Dio nor `built_value`.
- **`provider`** replaces the hand-written `InheritedNotifier` scopes. Widgets
  read with `context.watch<T>()` and act with `context.read<T>()`.
- **`Loadable<T>`** is a sealed union with exactly four cases, so every screen
  renders the same four outcomes and the compiler catches the one you skipped.
- **Screen-local state stays `setState`.** A checkbox, a text field and an
  expanded row do not need a controller, and promoting them to one buys nothing.

## Why not the alternatives

**Riverpod** is the stronger tool: compile-safe injection, `AsyncValue` for free,
no `BuildContext` in the notifier, auto-dispose. It is also a much larger
conceptual jump for a team writing `setState` today, and adopting it in the
driver app alone would leave the two apps architecturally different. Two apps
with two state models is worse than either model chosen consistently. Revisit if
`provider` starts to hurt; the controllers themselves port largely unchanged,
which is part of why this is the safe first step.

**Bloc** buys event sourcing and traceability we do not need, at a boilerplate
cost per feature that a two-person app team will pay every week.

**Staying on `setState`** is not a null option, it is a decision to keep four
screens holding four copies of the same run.

## Consequences

- `provider` is added to the driver app now, and to the commuter app when it
  adopts the pattern. It is a Flutter Favorite, tiny, and the closest thing to
  an official answer.
- `AppThemeControllerScope` is superseded by `ChangeNotifierProvider`; the
  controller itself is unchanged, which is the point.
- Controllers are plain Dart objects with no Flutter dependency beyond
  `ChangeNotifier`, so they are unit-testable without pumping a widget.
- New controllers get a test that asserts the `Loadable` progression, including
  the failure case.
- **The driver app adopts it now. The commuter app is not touched.** #199 is
  live in exactly the files a state refactor would move, and rewriting someone
  else's working tree to land a pattern is how you get a conflict nobody asked
  for. The commuter app adopts this as its ride-lifecycle work lands, by the
  engineer already in there.
- `AppThemeControllerScope` stays where it is for now. It is superseded by
  `ChangeNotifierProvider` in the driver app; the controller class itself is
  unchanged, which is the point and what makes the commuter app's later move
  a small one.

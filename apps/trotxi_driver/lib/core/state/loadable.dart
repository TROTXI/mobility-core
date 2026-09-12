/// The four outcomes of loading something, as one closed set.
///
/// Every screen in this app shows the same four: nothing asked for yet, in
/// flight, here, or failed. Spelled out as booleans (`isLoading`, `error`,
/// a nullable value) each screen invents its own combination, and the one
/// reliably skipped is the failure with a way back — which on a driver's phone
/// at a depot gate is the state that actually happens.
///
/// Sealed, so `switch` over it is exhaustive and the compiler names the case
/// you forgot.
sealed class Loadable<T> {
  const Loadable();

  /// Nothing has been asked for yet.
  const factory Loadable.idle() = Idle<T>;

  /// A request is in flight. [previous] carries whatever was already on screen,
  /// so a refresh does not blank the page a driver is reading.
  const factory Loadable.loading({T? previous}) = LoadingData<T>;

  /// Loaded.
  const factory Loadable.data(T value) = Data<T>;

  /// Failed, with something to show and, usually, a retry.
  const factory Loadable.failure(String message, {T? previous}) = Failure<T>;

  /// The value if there is one, including a stale value kept through a refresh
  /// or a failure.
  T? get valueOrNull => switch (this) {
    Data<T>(:final value) => value,
    LoadingData<T>(:final previous) => previous,
    Failure<T>(:final previous) => previous,
    Idle<T>() => null,
  };

  bool get isLoading => this is LoadingData<T>;
  bool get hasValue => valueOrNull != null;

  /// Whether to show a full-screen spinner, as opposed to refreshing in place
  /// over content that is already there.
  bool get isInitialLoad => this is LoadingData<T> && valueOrNull == null;
}

/// Nothing asked for yet.
final class Idle<T> extends Loadable<T> {
  const Idle();
}

/// In flight, possibly over a value already on screen.
final class LoadingData<T> extends Loadable<T> {
  const LoadingData({this.previous});
  final T? previous;
}

/// Loaded.
final class Data<T> extends Loadable<T> {
  const Data(this.value);
  final T value;
}

/// Failed.
final class Failure<T> extends Loadable<T> {
  const Failure(this.message, {this.previous});
  final String message;
  final T? previous;
}

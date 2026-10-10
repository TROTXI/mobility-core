import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:trotxi_commuter/Features/Onboarding/pages/full_name_page.dart';
import 'package:trotxi_commuter/Features/Onboarding/pages/phone_password_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trotxi_commuter/Features/Onboarding/widgets/splash_view.dart';
import 'package:trotxi_commuter/Features/Onboarding/pages/onboard_page.dart';
import 'package:trotxi_commuter/Features/Home/pages/home_page.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/notifications_inbox_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_client/public_information.dart';
import 'package:trotxi_commuter/core/Tokens/token_storage.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme_controller.dart';
import 'package:trotxi_commuter/core/api/api_debug_interceptor.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/notifications/commuter_notifications.dart';
import 'package:trotxi_commuter/firebase_options.dart';
import 'package:trotxi_commuter/firebase_performance.dart';

// Build inputs, never defaults: run with
// `--dart-define-from-file=config/staging.json` (or a production file).
const _apiBaseUrl = String.fromEnvironment('API_BASE_URL');
const _apiRealm = String.fromEnvironment('API_SESSION_REALM');

final trotxiClientProvider = Provider<CommuterApi>((ref) {
  throw UnimplementedError(
    'trotxiClientProvider has no default  override it in main() with '
    'trotxiClientProvider.overrideWithValue(client) before runApp().',
  );
});

Future<void> main() async {
  var launched = false;
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      TrotxiPublicInformation.ensureConfigured(release: kReleaseMode);
      final tokens = TokenStorage(baseUrl: _apiBaseUrl, realm: _apiRealm);
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Catch Flutter framework errors (widget build errors, layout errors, etc.)
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };

      // Catch errors outside Flutter's error handling (async errors, isolate errors)
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      final package = await PackageInfo.fromPlatform();
      final platform = switch (defaultTargetPlatform) {
        TargetPlatform.iOS => 'ios',
        TargetPlatform.android => 'android',
        _ => throw UnsupportedError(
          'The commuter app requires iOS or Android.',
        ),
      };
      final metadata = wire.ClientMetadata(
        app: 'commuter',
        build: int.parse(package.buildNumber),
        platform: platform,
      );
      final transport = wire.TrotxiClientFactory.create(
        baseUrl: _apiBaseUrl,
        tokenStore: tokens,
        metadata: metadata,
      );
      transport.dio.interceptors.add(PerformanceInterceptor());
      transport.dio.interceptors.add(ApiDebugInterceptor());
      final client = CommuterApi(
        client: transport,
        store: tokens,
        metadata: metadata,
      );
      runApp(TrotxiCommuterApp(client: client));
      launched = true;
    },
    (error, stack) {
      // Catches anything thrown outside the zone above (belt-and-suspenders)
      if (Firebase.apps.isNotEmpty) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      }
      if (!launched) {
        runApp(
          const MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'This build needs its API URL, session realm and public site address. Contact support.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    },
  );
}

class TrotxiCommuterApp extends StatefulWidget {
  const TrotxiCommuterApp({super.key, required this.client});

  final CommuterApi client;

  @override
  State<TrotxiCommuterApp> createState() => _TrotxiCommuterAppState();
}

class _TrotxiCommuterAppState extends State<TrotxiCommuterApp>
    with WidgetsBindingObserver {
  /// Away for less than this and the access token is very likely still good.
  static const _revalidateAfter = Duration(minutes: 5);

  final _themeController = AppThemeController();
  GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  late final CommuterNotifications _notifications = CommuterNotifications(
    api: widget.client,
    openInbox: _openInbox,
    showForegroundNotice: _showRideNotice,
  );
  DateTime? _pausedAt;
  bool _pendingInbox = false;
  bool _openingInbox = false;
  String? _boundOwner;
  late CommuterStage _boundStage;
  late bool _boundUpgrade;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _boundStage = widget.client.stage.value;
    _boundUpgrade = widget.client.upgradeRequired.value;
    widget.client.stage.addListener(_syncNotificationOwner);
    widget.client.identityRevision.addListener(_syncNotificationOwner);
    widget.client.upgradeRequired.addListener(_syncNotificationOwner);
    _notifications.start();
    unawaited(widget.client.load());
  }

  void _syncNotificationOwner() {
    final ready = widget.client.stage.value == CommuterStage.ready;
    final owner = ready ? widget.client.currentAccount?.id : null;
    final stage = widget.client.stage.value;
    final upgrade = widget.client.upgradeRequired.value;
    if (owner != _boundOwner ||
        stage != _boundStage ||
        upgrade != _boundUpgrade) {
      _boundOwner = owner;
      _boundStage = stage;
      _boundUpgrade = upgrade;
      _navigatorKey = GlobalKey<NavigatorState>();
      _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
      _openingInbox = false;
    }
    _notifications.setOwner(owner);
    if (widget.client.stage.value == CommuterStage.signedOut) {
      _pendingInbox = false;
    } else if (ready && _pendingInbox) {
      _openInbox();
    }
  }

  void _openInbox() {
    if (widget.client.stage.value != CommuterStage.ready) {
      _pendingInbox = widget.client.stage.value == CommuterStage.loading;
      return;
    }
    _pendingInbox = false;
    if (_openingInbox) return;
    _openingInbox = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final navigator = _navigatorKey.currentState;
      if (!mounted || navigator == null) {
        _openingInbox = false;
        return;
      }
      await navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => NotificationsInboxPage(client: widget.client),
        ),
      );
      _openingInbox = false;
    });
  }

  void _showRideNotice() {
    final messenger = _scaffoldMessengerKey.currentState;
    if (messenger == null || widget.client.stage.value != CommuterStage.ready) {
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Your commute needs a response.'),
        action: SnackBarAction(label: 'View', onPressed: _openInbox),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.client.stage.removeListener(_syncNotificationOwner);
    widget.client.identityRevision.removeListener(_syncNotificationOwner);
    widget.client.upgradeRequired.removeListener(_syncNotificationOwner);
    _notifications.dispose();
    _themeController.dispose();
    super.dispose();
  }

  /// A phone left idle keeps showing the last signed-in screen, and nothing on
  /// it asks the server anything. On return, make one authenticated call: if
  /// the session has expired the client refreshes, and when that fails it signs
  /// the rider out, which swaps this tree to the sign-in screen.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pausedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (widget.client.stage.value == CommuterStage.ready) {
        unawaited(_notifications.sync());
      }
      final pausedAt = _pausedAt;
      _pausedAt = null;
      if (pausedAt != null &&
          DateTime.now().difference(pausedAt) >= _revalidateAfter &&
          widget.client.stage.value == CommuterStage.ready) {
        unawaited(
          widget.client.account().then<void>(
            (_) {},
            onError: (Object _) {
              // Offline or a transient failure: stay put. An expired session is
              // handled by the client itself, not here.
            },
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // AppThemeControllerScope makes the controller reachable from anywhere
    // in the tree (e.g. the dark-mode toggle in ProfileTab); the
    // AnimatedBuilder re-renders MaterialApp itself whenever it changes,
    // since an InheritedWidget update alone wouldn't re-run this build.
    return AppThemeControllerScope(
      controller: _themeController,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _themeController,
          widget.client.stage,
          widget.client.identityRevision,
          widget.client.upgradeRequired,
        ]),
        builder: (context, _) => ProviderScope(
          key: ValueKey(
            '${widget.client.stage.value}:${widget.client.store.generation}:${widget.client.upgradeRequired.value}',
          ),
          overrides: [trotxiClientProvider.overrideWithValue(widget.client)],
          child: CommuterNotificationsScope(
            notifications: _notifications,
            child: MaterialApp(
              navigatorKey: _navigatorKey,
              scaffoldMessengerKey: _scaffoldMessengerKey,
              title: 'Trotxi Commuter',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: _themeController.themeMode,
              home: widget.client.upgradeRequired.value
                  ? const PopScope(
                      canPop: false,
                      child: Scaffold(
                        body: SafeArea(
                          child: Center(
                            child: Text('Please update the app to continue.'),
                          ),
                        ),
                      ),
                    )
                  : switch (widget.client.stage.value) {
                      CommuterStage.loading => const Scaffold(
                        body: SplashView(),
                      ),
                      CommuterStage.signedOut => OnBoardPage(
                        client: widget.client,
                      ),
                      CommuterStage.ready =>
                        widget
                                    .client
                                    .currentAccount
                                    ?.phoneRegistrationPending ==
                                true
                            ? PhonePasswordPage(
                                client: widget.client,
                                resume: true,
                              )
                            : widget.client.currentAccount?.firstName == null ||
                                  widget.client.currentAccount?.lastName == null
                            ? FullNamePage(
                                client: widget.client,
                                requiredForSignup: true,
                              )
                            : HomePage(client: widget.client),
                      CommuterStage.failed => Scaffold(
                        body: SafeArea(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.client.startupError?.message ??
                                      'Could not restore your session.',
                                ),
                                TextButton(
                                  onPressed: widget.client.load,
                                  child: const Text('Try again'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    },
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart' as cc;
import 'package:cometchat_chat_uikit/cometchat_calls_uikit.dart';

import 'package:sample_app/app_credentials.dart';
import 'package:sample_app/screens/app_credentials_screen.dart';
import 'package:sample_app/screens/home_screen.dart';
import 'package:sample_app/screens/guard_screen.dart';

/// Global navigator key for the app.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Share the navigator key with CometChat's call overlay system
  CallNavigationContext.navigatorKey = navigatorKey;

  // Try to load saved credentials from SharedPreferences
  await AppCredentials.loadSavedCredentials();

  runApp(const SampleApp());
}

class SampleApp extends StatelessWidget {
  const SampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sample App',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      supportedLocales: const [
        Locale('en'),
        Locale('en', 'GB'),
        Locale('ar'),
        Locale('de'),
        Locale('es'),
        Locale('fr'),
        Locale('hi'),
        Locale('hu'),
        Locale('ja'),
        Locale('ko'),
        Locale('lt'),
        Locale('ms'),
        Locale('nl'),
        Locale('pt'),
        Locale('ru'),
        Locale('sv'),
        Locale('tr'),
        Locale('zh'),
        Locale('zh', 'TW'),
      ],
      localizationsDelegates: const [
        cc.Translations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: AppCredentials.hasValidCredentials
          ? const SampleAppHome()
          : const AppCredentialsScreen(),
    );
  }
}

/// Main home that initializes CometChat and shows the appropriate screen.
///
/// Separated from [SampleApp] so that [AppCredentialsScreen] can navigate
/// here after the user enters valid credentials.
class SampleAppHome extends StatefulWidget {
  const SampleAppHome({super.key});

  @override
  State<SampleAppHome> createState() => _SampleAppHomeState();
}

class _SampleAppHomeState extends State<SampleAppHome> {
  bool _isInitialized = false;
  bool _isLoggedIn = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initCometChat();
  }

  Future<void> _initCallsSdk() async {
    if (kIsWeb) return; // Calls SDK not supported on web
    await CallEventService.instance.init(
      configuration: CallingConfiguration(),
    );
  }

  Future<void> _initCometChat() async {
    try {
      final settingsBuilder = UIKitSettingsBuilder()
        ..subscriptionType = CometChatSubscriptionType.allUsers
        ..region = AppCredentials.region
        ..autoEstablishSocketConnection = true
        ..appId = AppCredentials.appId
        ..authKey = AppCredentials.authKey;

      // Calls SDK — mobile only
      if (!kIsWeb) {
        settingsBuilder
          ..enableCalls = true
          ..callingConfiguration = CallingConfiguration();
      }

      final uiKitSettings = settingsBuilder.build();

      debugPrint('🚀 Initializing CometChat UIKit...');

      CometChatUIKit.init(
        uiKitSettings: uiKitSettings,
        onSuccess: (message) async {
          debugPrint('✅ CometChat initialized: $message');

          final isValid = await _resolveCachedSession();
          if (isValid) {
            await _initCallsSdk();
          }
          if (mounted) {
            setState(() {
              _isLoggedIn = isValid;
              _isInitialized = true;
            });
          }
        },
        onError: (error) {
          debugPrint(
              '❌ CometChat init error: ${error.code} - ${error.message}');
          if (mounted) setState(() => _error = error.toString());
        },
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Exception during CometChat init: $e');
      debugPrint('   Stack trace: $stackTrace');
      if (mounted) setState(() => _error = e.toString());
    }
  }

  /// Resolve whether we have a valid, live session.
  ///
  /// The UIKit / SDK can return a non-null `getLoggedInUser()` when all we
  /// have is a cached user blob in the TokenStore (Keychain on iOS,
  /// EncryptedSharedPreferences on Android). On iOS that cache survives
  /// app uninstall, so a stale session from a previous install can make
  /// the app route straight to HomeScreen with a dead auth token, after
  /// which every authenticated API call fails with
  /// `AUTH_ERR_AUTH_TOKEN_NOT_FOUND`.
  ///
  /// This method does a lightweight authenticated call
  /// (`CometChat.getUser(uid)`) to prove the cached token is still good.
  /// If the server rejects it with an auth-invalidated code, we tell the
  /// UIKit to log out (which now clears local state cleanly even on
  /// server error) and treat the user as logged out.
  ///
  /// Returns true only when:
  /// 1. A cached user exists, AND
  /// 2. An authenticated call succeeds OR fails with a non-auth reason
  ///    (e.g. offline — we don't want to nuke the session just because
  ///    the device is offline).
  Future<bool> _resolveCachedSession() async {
    final cachedUser = await CometChatUIKit.getLoggedInUser();
    if (cachedUser == null) {
      return false;
    }

    final completer = Completer<_SessionCheckResult>();
    await CometChat.getUser(
      cachedUser.uid,
      onSuccess: (_) {
        if (!completer.isCompleted) {
          completer.complete(_SessionCheckResult.valid);
        }
      },
      onError: (error) {
        if (completer.isCompleted) return;
        if (_isAuthInvalidatedCode(error.code)) {
          completer.complete(_SessionCheckResult.authInvalidated);
        } else {
          // Any other error (network, 5xx, etc.) — trust the cache and
          // let normal retry flows handle it. Do NOT log the user out.
          completer.complete(_SessionCheckResult.unknown);
        }
      },
    );

    final result = await completer.future;
    switch (result) {
      case _SessionCheckResult.valid:
        return true;
      case _SessionCheckResult.unknown:
        debugPrint(
            '⚠️ Session validation inconclusive (likely offline). '
            'Trusting cached session.');
        return true;
      case _SessionCheckResult.authInvalidated:
        debugPrint(
            '⚠️ Cached auth token is no longer valid server-side. '
            'Clearing local session and routing to login.');
        await _forceLogout();
        return false;
    }
  }

  /// Ask the UIKit to log out so local state (TokenStore + loggedInUser)
  /// is cleaned up. Thanks to the SDK fix in AuthRepository.logout(),
  /// this now succeeds even when the server has already revoked the
  /// token — the repository treats auth-invalidated errors from the
  /// logout API as "already logged out" and clears local state anyway.
  Future<void> _forceLogout() async {
    final completer = Completer<void>();
    await CometChatUIKit.logout(
      onSuccess: (_) {
        if (!completer.isCompleted) completer.complete();
      },
      onError: (e) {
        debugPrint('forceLogout onError (ignored): ${e.code} ${e.message}');
        if (!completer.isCompleted) completer.complete();
      },
    );
    await completer.future;
  }

  /// Known server error codes indicating the auth token has been
  /// invalidated. Kept in sync with `ErrorCodes.authInvalidatedCodes` in
  /// the SDK. Declared locally because the app only depends on the
  /// UIKit and does not import SDK internals directly.
  bool _isAuthInvalidatedCode(String? code) {
    if (code == null) return false;
    const invalidated = <String>{
      'AUTH_ERR_AUTH_TOKEN_NOT_FOUND',
    };
    return invalidated.contains(code);
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Error: $_error',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() => _error = null);
                  _initCometChat();
                },
                child: const Text('Retry'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  await AppCredentials.clearCredentials();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const AppCredentialsScreen(),
                    ),
                    (_) => false,
                  );
                },
                child: const Text('Change Credentials'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing CometChat...'),
            ],
          ),
        ),
      );
    }

    return _isLoggedIn ? const HomeScreen() : const GuardScreen();
  }
}

/// Outcome of the startup session validation probe.
enum _SessionCheckResult {
  /// Server accepted the cached auth token.
  valid,

  /// Server explicitly told us the token is gone / revoked.
  authInvalidated,

  /// Could not reach the server or got a non-auth error. Don't drop
  /// the session for this — probably transient.
  unknown,
}

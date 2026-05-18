import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_chat_uikit/cometchat_calls_uikit.dart';
import 'package:sample_app/app_credentials.dart';
import 'package:sample_app/screens/home_screen.dart';
import 'package:sample_app/screens/guard_screen.dart';
import 'package:sample_app/screens/app_credentials_screen.dart';
import 'package:permission_handler/permission_handler.dart';

// Conditional imports — mobile-only services

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load credentials from SharedPreferences (sample apps use this;
  // master_app falls back to hardcoded defaults)
  await AppCredentials.loadSavedCredentials();

  // Android 14+ (targetSdk 34+) requires RECORD_AUDIO and CAMERA to be
  // granted at runtime BEFORE the Calls SDK plugin registers its
  // OngoingCallService (which declares FGS types microphone|camera).
  // If a queued call push is delivered right after SDK init, the plugin
  // auto-starts the service and Android throws SecurityException if
  // either permission is missing — crashing the app before any
  // Dart-level guard can run. We MUST gate all SDK init on both
  // permissions being granted.
  //
  // Strategy:
  //   1. Request mic + camera.
  //   2. If both granted, continue to SDK init.
  //   3. If denied once, request again (Android re-prompts automatically).
  //   4. If permanentlyDenied, jump the user to App Settings and wait for
  //      them to return; re-check status on resume.
  //   5. Only when both are granted do we init Firebase / VoIP / CometChat.
  //
  // Still on the old (pre-crash) path if both already granted: request()
  // returns `granted` immediately with no UI.
  bool callPermsGranted = true;
  if (!kIsWeb) {
    callPermsGranted = await _ensureCallPermissions();
  }

  // Only initialise the push stack when call perms are granted. If the
  // user is still denying, skipping FCM/VoIP prevents the plugin from
  // ever receiving a call push that would try to start its FGS and
  // crash us. The app is still usable for messaging; call features
  // simply stay inert until perms are granted on a later launch.
  if (!kIsWeb && callPermsGranted) {
  }

  // Initialize Firebase (works on all platforms with proper config)

  // Crashlytics — mobile only

  // Share the navigator key with CometChat's call overlay system

  runApp(const BlocSampleApp());
}

/// Ensure mic + camera are granted before we init any part of CometChat.
///
/// Android 14+ FGS rule: OngoingCallService declares `microphone|camera`
/// FGS types, and the OS throws SecurityException at startForeground()
/// if the matching runtime perms aren't granted. Because the plugin can
/// auto-start that service in response to a push that arrives right
/// after CometChat init, we MUST have these granted before SDK init.
///
/// Returns `true` if both perms are granted at the end of the flow,
/// `false` otherwise. Callers use this to decide whether it is safe
/// to bring up FCM / VoIP / the Calls SDK on this launch.
///
/// Behaviour:
/// - Already granted → returns true immediately (no UI).
/// - First deny → prompts again once.
/// - permanentlyDenied → opens system Settings. Once the user returns,
///   we re-check status. We keep looping while any deny is recoverable.
/// - If user chooses to keep denying from Settings, we give up after a
///   few tries and return false. The app stays usable for messaging;
///   calling features stay inert until a future launch where perms get
///   granted. No crash possible because FCM/VoIP never initialise.
Future<bool> _ensureCallPermissions() async {
  // Cheap path: already granted.
  final initialMic = await Permission.microphone.status;
  final initialCam = await Permission.camera.status;
  if (initialMic.isGranted && initialCam.isGranted) {
    return true;
  }

  // Try prompting up to 3 times total. Each iteration asks for whichever
  // perm is not yet granted; if a perm is permanentlyDenied we send the
  // user to Settings and wait for them to return.
  for (var attempt = 0; attempt < 3; attempt++) {
    final micStatus = await Permission.microphone.status;
    final camStatus = await Permission.camera.status;
    if (micStatus.isGranted && camStatus.isGranted) return true;

    final needsSettings =
        micStatus.isPermanentlyDenied || camStatus.isPermanentlyDenied;

    if (needsSettings) {
      // Opens the app's settings page; the returned Future resolves
      // immediately (it just launches the intent). We then await a
      // short delay and re-check on the next loop iteration so the
      // user has time to toggle the switch and return.
      await openAppSettings();
      // Give the user time to act. If they take longer, the next
      // call attempt (Layer 3 chokepoint) will re-prompt anyway.
      await Future<void>.delayed(const Duration(seconds: 3));
      continue;
    }

    // Normal deny — request again. Android shows the system dialog.
    await [Permission.microphone, Permission.camera].request();
  }

  final finalMic = await Permission.microphone.status;
  final finalCam = await Permission.camera.status;
  return finalMic.isGranted && finalCam.isGranted;
}

class BlocSampleApp extends StatefulWidget {
  const BlocSampleApp({super.key});

  @override
  State<BlocSampleApp> createState() => _BlocSampleAppState();
}

class _BlocSampleAppState extends State<BlocSampleApp> {
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
    if (!AppCredentials.hasValidCredentials) {
      if (mounted) setState(() => _isInitialized = true);
      return;
    }
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
    return MaterialApp(
      title: 'CometChat Sample App',
      debugShowCheckedModeBanner: false,
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
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initCometChat,
                child: const Text('Retry'),
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

    // Show credentials screen if not configured (sample apps with blank credentials)
    if (!AppCredentials.hasValidCredentials) {
      return const AppCredentialsScreen();
    }

    if (!AppCredentials.hasValidCredentials) {
      return const AppCredentialsScreen();
    }
    return _isLoggedIn ? const HomeScreen() : const GuardScreen();
  }
}

enum _SessionCheckResult {
  /// Server accepted the cached auth token.
  valid,

  /// Server explicitly told us the token is gone / revoked.
  authInvalidated,

  /// Could not reach the server or got a non-auth error. Don't drop
  /// the session for this — probably transient.
  unknown,
}

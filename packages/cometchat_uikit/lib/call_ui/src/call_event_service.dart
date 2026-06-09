import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:cometchat_calls_sdk/src/plugin/platform/cometchatcalls_plugin_platform_interface.dart';
import '../../cometchat_calls_uikit.dart';
import '../../cometchat_chat_uikit.dart';

/// Singleton service that manages global call SDK event listeners
/// with proper lifecycle (init/dispose).
///
/// Centralizes all call-related SDK listener handling:
/// - Incoming call received → shows [IncomingCallOverlay]
/// - Outgoing call accepted/rejected → navigates or cleans up
/// - Call ended → clears active call state
/// - Updates [CallStateService] for global call state tracking
///
/// Usage:
/// ```dart
/// // Initialize after login
/// CallEventService.instance.init(configuration: callingConfig);
///
/// // Dispose on logout
/// CallEventService.instance.dispose();
/// ```
class CallEventService with CallListener, CometChatCallEventListener {
  CallEventService._();

  static final CallEventService instance = CallEventService._();

  static const String _listenerId = 'CallEventService';

  CallingConfiguration? _configuration;
  User? _loggedInUser;
  bool _initialized = false;

  /// The currently active call, tracked for state management.
  BaseMessage? activeCall;

  /// Whether the Calls SDK has been successfully initialized.
  bool _callsSdkReady = false;

  /// Whether the Calls SDK user login has completed successfully.
  bool _callsSdkLoginReady = false;

  /// Cached user auth token for call log requests.
  /// Fetched once during init and reused by CallLogsBloc.
  String? _cachedAuthToken;

  /// Completer that resolves when the Calls SDK init finishes.
  /// Other components (e.g. CallLogsBloc) can await this instead of
  /// calling CometChatCalls.init() themselves.
  Completer<void>? _callsSdkCompleter;

  /// Completer that resolves when the Calls SDK login finishes.
  /// waitForCallsSdk() awaits both init AND login before returning.
  Completer<void>? _callsSdkLoginCompleter;

  /// Initialize the service: cache logged-in user, register SDK listeners,
  /// and initialize the Calls SDK.
  /// Safe to call multiple times — will no-op if already initialized.
  Future<void> init({CallingConfiguration? configuration}) async {
    if (_initialized) return;
    _configuration = configuration;
    _loggedInUser = await CometChatUIKit.getLoggedInUser();

    assert(
      _loggedInUser != null,
      'CallEventService.init(): No logged-in user. '
      'Call CometChatUIKit.login() before initializing CallEventService.',
    );

    // Initialize the Calls SDK and await completion
    final settings = CometChatUIKit.authenticationSettings;
    assert(
      settings?.appId != null && settings?.region != null,
      'CallEventService.init(): CometChat must be initialized first. '
      'authenticationSettings is null.',
    );
    if (settings != null && settings.appId != null && settings.region != null) {
      await _initCallsSdk(settings.appId!, settings.region!);
    }

    // Log the user into the Calls SDK. CometChatCalls.init() only
    // initializes the SDK — it does NOT authenticate the user. Without
    // this login step, CometChatCalls.generateToken() fails with
    // "User auth token is null" because the Calls SDK's internal
    // CurrentUserRepository has no user record.
    _callsSdkLoginCompleter = Completer<void>();
    await _loginCallsSdk();
    // Only complete the login completer if login succeeded.
    // If it failed after all retries, leave it uncompleted so
    // waitForCallsSdk() will time out rather than proceeding with a broken SDK.
    if (_callsSdkLoginReady && !_callsSdkLoginCompleter!.isCompleted) {
      _callsSdkLoginCompleter!.complete();
    } else if (!_callsSdkLoginReady && !_callsSdkLoginCompleter!.isCompleted) {
      // Login failed — complete anyway so we don't hang forever,
      // but log a warning.
      developer.log(
          'CallEventService: WARNING — Calls SDK login failed, generateToken will fail');
      _callsSdkLoginCompleter!.complete();
    }

    // Pre-cache the auth token so CallLogsBloc doesn't need to fetch it
    try {
      _cachedAuthToken = await CometChat.getUserAuthToken();
    } catch (e) {
      developer.log('CallEventService: getUserAuthToken failed: $e');
    }

    CometChat.addCallListener(_listenerId, this);
    CometChatCallEvents.addCallEventsListener(_listenerId, this);

    _initialized = true;
    developer.log('CallEventService initialized');
  }

  /// Initializes the CometChat Calls SDK and awaits completion.
  /// Sets [_callsSdkReady] on success so other components know the SDK is ready.
  Future<void> _initCallsSdk(String appId, String region) async {
    if (_callsSdkReady) return;

    _callsSdkCompleter = Completer<void>();

    final callAppSettings = (CallAppSettingBuilder()
          ..appId = appId
          ..region = region)
        .build();

    CometChatCalls.init(
      callAppSettings,
      onSuccess: (String msg) {
        _callsSdkReady = true;
        developer.log('CallEventService: Calls SDK initialized: $msg');
        if (_callsSdkCompleter != null && !_callsSdkCompleter!.isCompleted) {
          _callsSdkCompleter!.complete();
        }
      },
      onError: (CometChatCallsException e) {
        developer.log(
          'CallEventService: Calls SDK init FAILED: ${e.code} ${e.message}',
        );
        // Complete anyway so waiters don't hang forever
        if (_callsSdkCompleter != null && !_callsSdkCompleter!.isCompleted) {
          _callsSdkCompleter!.complete();
        }
      },
    );

    // Wait up to 10s for the SDK to initialize
    await _callsSdkCompleter!.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        developer.log('CallEventService: Calls SDK init timed out');
      },
    );
  }

  /// Logs the current user into the Calls SDK using their auth token.
  ///
  /// The Calls SDK maintains its own user session (in SQLite). After
  /// `CometChatCalls.init()`, the SDK is initialized but has no
  /// authenticated user. `CometChatCalls.loginWithAuthToken()` stores
  /// the user + auth token so that `generateToken()` can work.
  Future<void> _loginCallsSdk() async {
    if (!_callsSdkReady) {
      developer
          .log('CallEventService: skipping Calls SDK login — SDK not ready');
      return;
    }

    // The auth token may not be available immediately after CometChatUIKit.init()
    // with a cached session (cold start) or after a fresh login. Retry with
    // longer delays to ensure the token is fully propagated.
    String? authToken;
    for (int attempt = 0; attempt < 15; attempt++) {
      try {
        authToken = await CometChat.getUserAuthToken();
      } catch (e) {
        developer.log(
            'CallEventService: getUserAuthToken attempt ${attempt + 1} failed: $e');
      }
      if (authToken != null && authToken.isNotEmpty) break;
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (authToken == null || authToken.isEmpty) {
      developer.log(
          'CallEventService: no auth token after retries, skipping Calls SDK login');
      return;
    }

    // Retry login up to 3 times — the first attempt may fail if the Calls SDK
    // internally logs out (token rotation) and the re-login response fails.
    for (int loginAttempt = 1; loginAttempt <= 3; loginAttempt++) {
      developer.log(
          'CallEventService: logging into Calls SDK (attempt $loginAttempt)...');
      final completer = Completer<bool>(); // true = success, false = error
      CometChatCalls.loginWithAuthToken(
        authToken: authToken!,
        onSuccess: (user) {
          developer.log('CallEventService: Calls SDK login successful');
          _callsSdkLoginReady = true;
          if (_callsSdkLoginCompleter != null &&
              !_callsSdkLoginCompleter!.isCompleted) {
            _callsSdkLoginCompleter!.complete();
          }
          if (!completer.isCompleted) completer.complete(true);
        },
        onError: (e) {
          developer.log(
              'CallEventService: Calls SDK login error (attempt $loginAttempt): ${e.code} ${e.message}');
          if (!completer.isCompleted) completer.complete(false);
        },
      );

      final success = await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          developer.log(
              'CallEventService: Calls SDK login timed out (attempt $loginAttempt)');
          return false;
        },
      );

      if (success) return;

      if (loginAttempt < 3) {
        // Wait before retrying — give the SDK time to settle after internal logout
        await Future.delayed(const Duration(milliseconds: 1000));
        // Re-fetch auth token in case it changed
        try {
          final refreshed = await CometChat.getUserAuthToken();
          if (refreshed != null && refreshed.isNotEmpty) authToken = refreshed;
        } catch (_) {}
      }
    }

    developer.log('CallEventService: Calls SDK login failed after all retries');

    // Web fallback: The Dart SDK's HTTP login may fail due to CORS or API
    // differences on web, but the JS SDK can still be logged in directly
    // via the native plugin's setNativeAuthToken which calls the bridge's
    // login(). This ensures joinSession works on web even if the Dart
    // SDK's own login API fails.
    if (kIsWeb && authToken != null && authToken.isNotEmpty) {
      developer.log(
          'CallEventService: Web fallback — setting native auth token directly');
      try {
        CometChatCallsPluginPlatform.instance.setNativeAuthToken(authToken);
        _callsSdkLoginReady = true;
        if (_callsSdkLoginCompleter != null &&
            !_callsSdkLoginCompleter!.isCompleted) {
          _callsSdkLoginCompleter!.complete();
        }
      } catch (e) {
        developer.log(
            'CallEventService: Web fallback setNativeAuthToken failed: $e');
      }
    }
  }

  /// Returns true if the Calls SDK has been initialized successfully.
  bool get isCallsSdkReady => _callsSdkReady;

  /// Returns the cached user auth token, or null if not yet fetched.
  String? get cachedAuthToken => _cachedAuthToken;

  /// Waits for the Calls SDK to be ready AND the user to be logged in.
  /// If already ready, returns immediately.
  /// Other components (e.g. CallLogsBloc, VoipCallHandler) should call this
  /// instead of initializing the SDK themselves.
  ///
  /// If [init] hasn't been called yet (e.g. because [_initiateAfterLogin]
  /// fired it without `await`), this method polls briefly, then falls back
  /// to calling [init] directly so the caller never proceeds with an
  /// uninitialized Calls SDK.
  Future<void> waitForCallsSdk() async {
    if (_callsSdkReady && _callsSdkLoginReady) return;

    // If init() hasn't been called yet, poll briefly until it starts.
    if (!_initialized && _callsSdkCompleter == null) {
      for (int i = 0; i < 30; i++) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (_callsSdkCompleter != null || _callsSdkReady) break;
      }
    }

    // Fallback: if init() still hasn't started after polling, trigger it
    // directly. This covers the race where _initiateAfterLogin() fired
    // init() without await and the future hasn't been scheduled yet, or
    // where init() was never called at all.
    if (!_initialized && _callsSdkCompleter == null) {
      developer.log(
        'CallEventService: waitForCallsSdk — init() never started, '
        'triggering it now',
      );
      final settings = CometChatUIKit.authenticationSettings;
      if (settings != null &&
          settings.appId != null &&
          settings.region != null) {
        await init(
          configuration: settings.callingConfiguration,
        );
      }
      // After init completes, check again
      if (_callsSdkReady && _callsSdkLoginReady) return;
    }

    // Wait for SDK init
    if (!_callsSdkReady && _callsSdkCompleter != null) {
      await _callsSdkCompleter!.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          developer.log('CallEventService: waitForCallsSdk (init) timed out');
        },
      );
    }

    // Wait for SDK login — the completer may not exist yet if init() is
    // still running (it creates _callsSdkLoginCompleter after _initCallsSdk
    // finishes). Poll briefly for it.
    if (!_callsSdkLoginReady && _callsSdkLoginCompleter == null) {
      for (int i = 0; i < 25; i++) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (_callsSdkLoginCompleter != null || _callsSdkLoginReady) break;
      }
    }

    if (!_callsSdkLoginReady && _callsSdkLoginCompleter != null) {
      await _callsSdkLoginCompleter!.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          developer.log('CallEventService: waitForCallsSdk (login) timed out');
        },
      );
    }

    if (!_callsSdkReady || !_callsSdkLoginReady) {
      developer.log(
        'CallEventService: waitForCallsSdk finished but SDK not fully ready '
        '(init=$_callsSdkReady, login=$_callsSdkLoginReady)',
      );
    }
  }

  /// Remove all SDK listeners and reset state.
  /// Resets the Calls SDK initialization and login state so that the next
  /// [init()] call will re-initialize and re-login the Calls SDK.
  /// This is necessary for the logout → re-login flow: the Chat SDK logout
  /// clears the native Calls SDK state, so we must re-init on next login.
  void dispose() {
    if (!_initialized) return;
    CometChat.removeCallListener(_listenerId);
    CometChatCallEvents.removeCallEventsListener(_listenerId);

    // End any active call session before clearing state.
    // Without this, the native Calls SDK session stays alive after logout,
    // causing "call is in progress" to persist on re-login.
    _endActiveSessionOnLogout();

    activeCall = null;
    _loggedInUser = null;
    _configuration = null;
    _cachedAuthToken = null;
    _callsSdkReady = false;
    _callsSdkLoginReady = false;
    _callsSdkCompleter = null;
    _callsSdkLoginCompleter = null;
    _initialized = false;

    // Reset service locators so they re-initialize with fresh
    // datasources on next login. Without this, the locators hold
    // references to stale instances from the previous session.
    CallOperationsServiceLocator.instance.reset();
    CallLogsServiceLocator.instance.reset();

    // Reset call state tracking in case a call was active during logout.
    CallStateService.instance.setActiveCallValue(false);
    CallStateService.instance.setActiveIncomingValue(false);
    CallStateService.instance.setActiveOutgoingValue(false);

    // Dismiss any visible incoming call overlay.
    IncomingCallOverlay.dismiss();

    // Logout from the Calls SDK so its internal state is fully cleared.
    // On next init(), we'll re-init and re-login fresh.
    CometChatCalls.logout(
      onSuccess: (_) {
        developer.log('CallEventService: Calls SDK logout successful');
      },
      onError: (e) {
        developer.log('CallEventService: Calls SDK logout error: ${e.message}');
      },
    );

    developer.log('CallEventService disposed');
  }

  /// Ends any active call session during logout.
  /// Leaves the V5 SDK session, clears the Chat SDK's active call,
  /// and aborts the Android foreground service notification.
  void _endActiveSessionOnLogout() {
    try {
      CometChatOngoingCallService.abort();
      CallSession.getInstance()?.leaveSession();
      CometChat.clearActiveCall();
      developer.log('CallEventService: active session ended on logout');
    } catch (e) {
      developer.log('CallEventService: _endActiveSessionOnLogout error: $e');
    }
  }

  /// Re-initializes the Calls SDK after a session ends.
  /// Per the V5 SDK sample app: "The SDK's internal state can get cleared
  /// after a session, so this ensures subsequent calls work properly."
  Future<void> reinitializeAfterSession() async {
    final settings = CometChatUIKit.authenticationSettings;
    if (settings?.appId != null && settings?.region != null) {
      _callsSdkReady = false;
      _callsSdkLoginReady = false;
      _callsSdkCompleter = null;
      _callsSdkLoginCompleter = null;
      await _initCallsSdk(settings!.appId!, settings.region!);

      // Re-login the user — the V5 SDK clears its internal user session
      // after a call ends, so generateToken/joinSession will fail with
      // "auth token is null" unless we re-authenticate.
      _callsSdkLoginCompleter = Completer<void>();
      await _loginCallsSdk();
      if (_callsSdkLoginReady && !_callsSdkLoginCompleter!.isCompleted) {
        _callsSdkLoginCompleter!.complete();
      } else if (!_callsSdkLoginCompleter!.isCompleted) {
        _callsSdkLoginCompleter!.complete();
      }

      developer.log(
          'CallEventService: SDK re-initialized and re-logged in after session');
    }
  }

  // ================================================================
  // SDK Call Events (CallListener)
  // ================================================================

  @override
  void onIncomingCallReceived(Call call) {
    User? user;
    if (call.callInitiator is User) {
      user = call.callInitiator as User;
    }

    // Ignore calls initiated by the logged-in user (echo)
    if (user != null && user.uid == _loggedInUser?.uid) {
      return;
    }

    // On iOS background, the VoIP push + CallKit handles the call.
    // The WebSocket listener should NOT interfere — setting activeCall
    // here can cause the server to auto-reject new calls with "busy"
    // if the app crashes or the call state isn't properly cleared.
    if (defaultTargetPlatform == TargetPlatform.iOS &&
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      developer.log(
        'CallEventService: skipping onIncomingCallReceived in background on iOS '
        '(VoIP push handles it) sessionId=${call.sessionId}',
      );
      return;
    }

    // Deduplicate: ignore if we already have an active incoming call with
    // the same session ID. Duplicate FCM pushes can trigger this listener
    // twice for the same call, which creates a second overlay/bloc and
    // causes the reject API to fail with "call is ended".
    if (activeCall != null &&
        activeCall is Call &&
        (activeCall as Call).sessionId == call.sessionId) {
      developer.log(
        'CallEventService: ignoring duplicate onIncomingCallReceived '
        'for sessionId=${call.sessionId}',
      );
      return;
    }

    developer.log(
        'CallEventService: onIncomingCallReceived sessionId=${call.sessionId}');
    activeCall = call;
    _showIncomingCallOverlay(call, user);
  }

  /// Attempts to show the incoming call overlay, retrying briefly if the
  /// navigator context isn't available yet.
  Future<void> _showIncomingCallOverlay(Call call, User? user) async {
    BuildContext? context;
    for (int i = 0; i < 10; i++) {
      context = CallNavigationContext.navigatorKey.currentContext;
      if (context != null && context.mounted) break;
      context = null;
      await Future.delayed(const Duration(milliseconds: 100));
    }

    developer.log(
        'CallEventService: showing overlay, context=${context != null}, overlay=${CallNavigationContext.navigatorKey.currentState?.overlay != null}');

    if (context != null && context.mounted) {
      IncomingCallOverlay.show(
        context: context,
        call: call,
        user: user,
        onError: _configuration?.incomingCallConfiguration?.onError,
        disableSoundForCalls:
            _configuration?.incomingCallConfiguration?.disableSoundForCalls,
        customSoundForCalls:
            _configuration?.incomingCallConfiguration?.customSoundForCalls,
        customSoundForCallsPackage: _configuration
            ?.incomingCallConfiguration?.customSoundForCallsPackage,
        onAccept: _configuration?.incomingCallConfiguration?.onAccept,
        onDecline: _configuration?.incomingCallConfiguration?.onDecline,
        style: _configuration?.incomingCallConfiguration?.incomingCallStyle,
        callSettingsBuilder:
            _configuration?.incomingCallConfiguration?.callSettingsBuilder,
        height: _configuration?.incomingCallConfiguration?.height,
        width: _configuration?.incomingCallConfiguration?.width,
        declineButtonText:
            _configuration?.incomingCallConfiguration?.declineButtonText,
        acceptButtonText:
            _configuration?.incomingCallConfiguration?.acceptButtonText,
        titleView: _configuration?.incomingCallConfiguration?.titleView,
        leadingView: _configuration?.incomingCallConfiguration?.leadingView,
        trailingView: _configuration?.incomingCallConfiguration?.trailingView,
        subtitleView: _configuration?.incomingCallConfiguration?.subTitleView,
        itemView: _configuration?.incomingCallConfiguration?.itemView,
      );
    } else {
      developer.log(
        'WARNING: CallNavigationContext.navigatorKey has no context. '
        'Did you set CallNavigationContext.navigatorKey = yourNavigatorKey '
        'in main()? Incoming call overlay cannot be shown.',
      );
    }
  }

  @override
  void onOutgoingCallAccepted(Call call) {
    activeCall = call;
  }

  @override
  void onOutgoingCallRejected(Call call) {
    _clearActiveCall(call);
  }

  @override
  void onIncomingCallCancelled(Call call) {
    developer.log(
        'CallEventService: onIncomingCallCancelled sessionId=${call.sessionId}');
    // Small delay to avoid race where cancel arrives before overlay is visible
    Future.delayed(const Duration(milliseconds: 300), () {
      IncomingCallOverlay.dismiss();
    });
    _clearActiveCall(call);
  }

  @override
  void onCallEndedMessageReceived(Call call) {
    developer.log(
        'CallEventService: onCallEndedMessageReceived sessionId=${call.sessionId}');
    IncomingCallOverlay.dismiss();
    _clearActiveCall(call);
  }

  // ================================================================
  // UIKit Call Events (CometChatCallEventListener)
  // ================================================================

  @override
  void ccOutgoingCall(Call call) {
    activeCall = call;
  }

  @override
  void ccCallAccepted(Call call) {
    activeCall = call;
  }

  @override
  void ccCallRejected(Call call) {
    _clearActiveCall(call);
  }

  @override
  void ccCallEnded(Call call) {
    _clearActiveCall(call);
  }

  // ================================================================
  // Internal helpers
  // ================================================================

  /// Clears [activeCall] and the server-side active call state.
  ///
  /// Always clears the server-side state via [CometChat.clearActiveCall()]
  /// regardless of whether the local [activeCall] ID matches. Previous
  /// behavior only cleared when IDs matched, which left stale server state
  /// when the call ended through a path with a mismatched ID — causing
  /// subsequent calls between the same users to fail with "call is ended".
  void _clearActiveCall(Call call) {
    if (activeCall != null && activeCall?.id == call.id) {
      activeCall = null;
    }
    // Always clear server-side state to prevent stale "busy" rejections.
    CometChat.clearActiveCall().then((_) {
      developer.log('CallEventService: clearActiveCall succeeded');
    }).catchError((e) {
      developer.log('CallEventService: clearActiveCall failed: $e');
    });
  }
}

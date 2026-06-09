/**
 * CometChat Calls Bridge for Flutter Web
 *
 * Bridges the Flutter Dart layer (via dart:js_interop) to the
 * CometChat JavaScript Calls SDK v5 (@cometchat/calls-sdk-javascript@5.0.0).
 *
 * JS SDK v5 API uses plain objects (no builders):
 *   - CometChatCalls.init({ appId, region })
 *   - CometChatCalls.login(authToken)
 *   - CometChatCalls.generateToken(sessionId)
 *   - CometChatCalls.joinSession(token, settings, container)
 *   - CometChatCalls.endSession()
 */

window.cometchatCallsBridge = (function () {
  let activeSession = null;

  /**
   * Initialize the CometChat Calls JS SDK.
   */
  function init(appId, region) {
    try {
      CometChatCalls.init({ appId: appId, region: region }).then(
        function (result) {
          if (result && result.success) {
            console.log("cometchatCallsBridge: init success");
          } else {
            console.error("cometchatCallsBridge: init failed", result);
          }
        },
        function (error) {
          console.error("cometchatCallsBridge: init error", error);
        }
      );
    } catch (e) {
      console.error("cometchatCallsBridge: init exception", e);
    }
  }

  /**
   * Login to the Calls SDK with auth token.
   * The Dart plugin calls this with (uid, authToken) but the JS SDK v5
   * uses loginWithAuthToken(authToken) for production auth.
   */
  function login(uid, authToken) {
    try {
      CometChatCalls.loginWithAuthToken(authToken).then(
        function (user) {
          console.log("cometchatCallsBridge: login success", user ? user.uid : "");
        },
        function (error) {
          console.error("cometchatCallsBridge: login error", error);
        }
      );
    } catch (e) {
      console.error("cometchatCallsBridge: login exception", e);
    }
  }

  /**
   * Join a call session and render the call UI into the given container.
   *
   * The Dart plugin passes (containerId, verifyTokenResponse, callSettingsMap).
   * verifyTokenResponse is the call token from the Dart SDK's generateToken.
   * However, the JS SDK needs its own generateToken call, so we extract the
   * session ID and generate a fresh token on the JS side.
   *
   * @param {string} containerId - DOM element ID to render the call UI into
   * @param {string} callTokenOrSessionId - The call token or session ID from Dart
   * @param {object} dartCallSettings - Call settings object from Dart
   */
  function joinSession(containerId, callTokenOrSessionId, dartCallSettings) {
    try {
      console.log("cometchatCallsBridge: joinSession called", {
        containerId: containerId,
        callTokenOrSessionId: callTokenOrSessionId ? callTokenOrSessionId.substring(0, 80) : "NULL",
        dartCallSettings: dartCallSettings
      });
      var isAudioOnly = dartCallSettings && dartCallSettings.isAudioOnly;

      // Request browser media permissions before joining
      var constraints = isAudioOnly
        ? { audio: true }
        : { audio: true, video: true };

      navigator.mediaDevices
        .getUserMedia(constraints)
        .then(function (stream) {
          stream.getTracks().forEach(function (track) { track.stop(); });
          _generateTokenAndJoin(containerId, callTokenOrSessionId, dartCallSettings);
        })
        .catch(function (err) {
          console.warn(
            "cometchatCallsBridge: getUserMedia failed, trying session anyway",
            err
          );
          _generateTokenAndJoin(containerId, callTokenOrSessionId, dartCallSettings);
        });
    } catch (e) {
      console.error("cometchatCallsBridge: joinSession exception", e);
    }
  }

  /**
   * Generate a token on the JS SDK side and then start the session.
   * The JS SDK requires its own generateToken call before joinSession.
   */
  function _generateTokenAndJoin(containerId, callTokenFromDart, dartCallSettings) {
    // First try using the token directly (it might work if it's a proper call token)
    // If that fails with "Session ID is required", we need to generate on JS side
    
    // The Dart SDK passes the verifyTokenResponse which is the raw token string.
    // Try to extract session ID from the call settings or use the token as-is.
    // The session ID might be in dartCallSettings.sessionId
    var sessionId = (dartCallSettings && dartCallSettings.sessionId) || null;
    
    if (sessionId) {
      // We have a session ID — generate token on JS side
      console.log("cometchatCallsBridge: generating token for sessionId:", sessionId);
      CometChatCalls.generateToken(sessionId).then(
        function (result) {
          if (result && result.token) {
            console.log("cometchatCallsBridge: token generated successfully");
            _startSession(containerId, result.token, dartCallSettings);
          } else {
            console.error("cometchatCallsBridge: generateToken returned no token", result);
            // Fallback: try with the Dart-provided token
            _startSession(containerId, callTokenFromDart, dartCallSettings);
          }
        },
        function (error) {
          console.error("cometchatCallsBridge: generateToken failed", error);
          // Fallback: try with the Dart-provided token
          _startSession(containerId, callTokenFromDart, dartCallSettings);
        }
      );
    } else {
      // No session ID available — try the Dart token directly
      // It might be a session ID itself (the Dart SDK sometimes passes sessionId as the token)
      console.log("cometchatCallsBridge: no sessionId in settings, generating token with callToken as sessionId");
      CometChatCalls.generateToken(callTokenFromDart).then(
        function (result) {
          if (result && result.token) {
            console.log("cometchatCallsBridge: token generated from sessionId successfully");
            _startSession(containerId, result.token, dartCallSettings);
          } else {
            console.error("cometchatCallsBridge: generateToken returned no token", result);
            _startSession(containerId, callTokenFromDart, dartCallSettings);
          }
        },
        function (error) {
          console.error("cometchatCallsBridge: generateToken with callToken failed, trying direct", error);
          _startSession(containerId, callTokenFromDart, dartCallSettings);
        }
      );
    }
  }

  /**
   * Internal: wait for container to appear in DOM, then start the session.
   */
  function _startSession(containerId, callTokenOrJson, dartCallSettings) {
    _waitForElement(containerId, 5000).then(function (el) {
      if (!el) {
        console.error(
          "cometchatCallsBridge: container not found after timeout:",
          containerId
        );
        return;
      }

      // The Dart SDK passes the verifyToken API response as a JSON string.
      // Extract the actual call token from it.
      var actualToken = _extractCallToken(callTokenOrJson);
      console.log("cometchatCallsBridge: extracted token:", actualToken ? actualToken.substring(0, 40) + "..." : "NULL");

      // v5 JS SDK uses PascalCase property names (ICallsettings interface)
      var callSettings = {
        sessionType: (dartCallSettings && dartCallSettings.isAudioOnly) ? "VOICE" : "VIDEO",
        layout: "TILE",
        StartAudioMuted: false,
        StartVideoMuted: false,
        ShowMuteAudioButton: false,
        ShowEndCallButton: false,
        ShowPauseVideoButton: false,
        ShowSwitchModeButton: false,
        ShowScreenShareButton: false,
        ShowRecordingButton: false,
        StartRecordingOnCallStart: false,
      };

      CometChatCalls.joinSession(actualToken, callSettings, el).then(
        function (result) {
          if (result && result.error) {
            console.error("cometchatCallsBridge: joinSession error", result.error);
          } else {
            console.log("cometchatCallsBridge: joinSession success");
            activeSession = result;
            _dispatchEvent("onSessionJoined");
            _registerSessionEventListeners();
          }
        },
        function (error) {
          console.error("cometchatCallsBridge: joinSession failed", error);
        }
      );
    });
  }

  /**
   * Extract the actual call token from the verifyTokenResponse.
   * The Dart SDK passes a JSON string like: {"data": {"callToken": "...", ...}}
   * Or it might be the raw token string directly.
   */
  function _extractCallToken(input) {
    if (!input) return input;

    // Try to parse as JSON first
    try {
      var parsed = JSON.parse(input);
      // Check for data.callToken structure
      if (parsed && parsed.data && parsed.data.callToken) {
        return parsed.data.callToken;
      }
      // Check for direct callToken field
      if (parsed && parsed.callToken) {
        return parsed.callToken;
      }
    } catch (e) {
      // Not JSON — might be the raw token string already
    }

    // Return as-is (might be a raw token)
    return input;
  }

  /**
   * Wait for a DOM element to appear AND have non-zero dimensions (polling with timeout).
   * Fixes race condition where Flutter Web's HtmlElementView creates the element
   * but layout hasn't assigned dimensions yet, causing WebRTC to fail with
   * "Container dimensions and number of tiles must be positive".
   */
  function _waitForElement(id, timeoutMs) {
    return new Promise(function (resolve) {
      var interval = 100;
      var elapsed = 0;
      var timer = setInterval(function () {
        elapsed += interval;
        var found = document.getElementById(id);
        if (found) {
          var rect = found.getBoundingClientRect();
          if (rect.width > 0 && rect.height > 0) {
            clearInterval(timer);
            resolve(found);
            return;
          }
        }
        if (elapsed >= timeoutMs) {
          clearInterval(timer);
          // Return element even if dimensions are zero (let SDK handle the error)
          resolve(found || null);
        }
      }, interval);
    });
  }

  /**
   * Register JS SDK event listeners and forward them as DOM events to Dart.
   */
  var _unsubscribers = [];
  function _registerSessionEventListeners() {
    // Clean up any previous listeners
    _unsubscribers.forEach(function (unsub) { if (unsub) unsub(); });
    _unsubscribers = [];

    var events = [
      "onSessionLeft",
      "onSessionTimedOut",
      "onConnectionLost",
      "onConnectionRestored",
      "onConnectionClosed",
      "onParticipantJoined",
      "onParticipantLeft",
      "onLeaveSessionButtonClicked",
    ];

    events.forEach(function (eventName) {
      var unsub = CometChatCalls.addEventListener(eventName, function (data) {
        console.log("cometchatCallsBridge: event received:", eventName);
        _dispatchEvent(eventName);

        // On session end events, clean up
        if (eventName === "onSessionLeft" || eventName === "onSessionTimedOut" || eventName === "onConnectionClosed") {
          activeSession = null;
          _cleanupListeners();
        }
      });
      _unsubscribers.push(unsub);
    });

    // Also listen for the leave button click — the JS SDK's default UI
    // calls leaveSession internally, which fires onSessionLeft
    var leaveUnsub = CometChatCalls.addEventListener("onLeaveSessionButtonClicked", function () {
      console.log("cometchatCallsBridge: leave button clicked, dispatching onSessionLeft");
      // The SDK will fire onSessionLeft after this, but dispatch immediately
      // in case the SDK doesn't fire it fast enough
      setTimeout(function () {
        if (activeSession !== null) {
          _dispatchEvent("onSessionLeft");
          activeSession = null;
          _cleanupListeners();
        }
      }, 1000);
    });
    _unsubscribers.push(leaveUnsub);
  }

  function _cleanupListeners() {
    _unsubscribers.forEach(function (unsub) { if (unsub) unsub(); });
    _unsubscribers = [];
  }

  /**
   * Perform a call action.
   */
  function callAction(action) {
    try {
      switch (action) {
        case "endSession":
          CometChatCalls.endSession().then(
            function () {
              console.log("cometchatCallsBridge: endSession success");
              _dispatchEvent("onSessionLeft");
              activeSession = null;
            },
            function (error) {
              console.error("cometchatCallsBridge: endSession error", error);
            }
          );
          break;
        case "muteAudio":
          CometChatCalls.muteAudio(true);
          break;
        case "unmuteAudio":
          CometChatCalls.muteAudio(false);
          break;
        case "pauseVideo":
          CometChatCalls.pauseVideo(true);
          break;
        case "unpauseVideo":
          CometChatCalls.pauseVideo(false);
          break;
        case "switchCamera":
          break;
        default:
          console.warn("cometchatCallsBridge: unknown action", action);
      }
    } catch (e) {
      console.error("cometchatCallsBridge: callAction exception", e);
    }
  }

  /**
   * Perform a call action with a parameter.
   */
  function callActionWithParam(action, param) {
    try {
      switch (action) {
        case "setAudioMode":
          break;
        case "startRecording":
          CometChatCalls.startRecording();
          break;
        case "stopRecording":
          CometChatCalls.stopRecording();
          break;
        default:
          console.warn("cometchatCallsBridge: unknown actionWithParam", action, param);
      }
    } catch (e) {
      console.error("cometchatCallsBridge: callActionWithParam exception", e);
    }
  }

  /**
   * Dispatch a custom DOM event that the Dart layer listens for.
   */
  function _dispatchEvent(eventType) {
    var event = new CustomEvent("cometchat_calls_event", {
      detail: JSON.stringify({ eventType: eventType }),
    });
    window.dispatchEvent(event);
  }

  return {
    init: init,
    login: login,
    joinSession: joinSession,
    callAction: callAction,
    callActionWithParam: callActionWithParam,
  };
})();

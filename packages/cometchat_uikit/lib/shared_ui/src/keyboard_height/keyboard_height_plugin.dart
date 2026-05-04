import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

/// Callback type for keyboard height changes.
/// Receives keyboard height and safe area bottom in logical pixels.
typedef KeyboardHeightCallback = void Function(double keyboardHeight, double safeAreaBottom);

/// Data class for keyboard height info from native.
class KeyboardHeightInfo {
  final double keyboardHeight;
  final double safeAreaBottom;
  
  const KeyboardHeightInfo({
    required this.keyboardHeight,
    required this.safeAreaBottom,
  });
}

/// A plugin that provides keyboard height before the keyboard animation occurs.
/// 
/// This helps eliminate lag when positioning widgets around the keyboard,
/// such as placing a TextField above the keyboard.
/// 
/// The plugin uses platform channels to get the keyboard height from native code
/// before Flutter's viewInsets are updated.
class KeyboardHeightPlugin {
  static const EventChannel _keyboardHeightEventChannel =
      EventChannel('com.cometchat.keyboard_height_channel');

  /// Static cache for the last known keyboard height (includes safe area).
  /// This is used by sticker/emoji keyboards when the system keyboard is closed.
  /// The value is the full keyboard height as reported by native (keyboardFrame.height on iOS).
  static double _lastKnownKeyboardHeight = 0.0;
  
  /// Static cache for the last known safe area bottom.
  static double _lastKnownSafeAreaBottom = 0.0;
  
  /// Gets the last known keyboard height (includes safe area).
  /// Returns 0 if keyboard has never been opened.
  static double get lastKnownKeyboardHeight => _lastKnownKeyboardHeight;
  
  /// Gets the last known safe area bottom.
  static double get lastKnownSafeAreaBottom => _lastKnownSafeAreaBottom;
  
  /// Sets the last known keyboard height.
  /// This can be called from sticker/emoji keyboard to cache the height
  /// when switching from OS keyboard to custom keyboard.
  static void setLastKnownKeyboardHeight(double height) {
    if (height > 0) {
      _lastKnownKeyboardHeight = height;
    }
  }

  /// Shared broadcast stream from the native EventChannel.
  /// EventChannel.receiveBroadcastStream() tears down the native listener
  /// when ANY subscription cancels. By sharing a single stream via
  /// asBroadcastStream(), multiple KeyboardHeightPlugin instances can
  /// subscribe/unsubscribe independently without killing the native side.
  static Stream<dynamic>? _sharedStream;
  static int _listenerCount = 0;

  static Stream<dynamic> _getSharedStream() {
    _sharedStream ??= _keyboardHeightEventChannel
        .receiveBroadcastStream()
        .asBroadcastStream();
    return _sharedStream!;
  }

  StreamSubscription? _keyboardHeightSubscription;

  /// Registers a callback to be called when the keyboard height changes.
  /// 
  /// The callback receives the keyboard height and safe area bottom in logical pixels.
  /// When the keyboard is hidden, the keyboard height will be 0.
  void onKeyboardHeightChanged(KeyboardHeightCallback callback) {
    // Platform channels are not available on web — skip registration.
    // The composer falls back to viewInsets on web.
    if (kIsWeb) return;

    if (_keyboardHeightSubscription != null) {
      _keyboardHeightSubscription!.cancel();
      _listenerCount--;
    }
    _listenerCount++;
    _keyboardHeightSubscription =
        _getSharedStream().listen(
      (dynamic data) {
        if (data is Map) {
          final keyboardHeight = (data['keyboardHeight'] as num?)?.toDouble() ?? 0.0;
          final safeAreaBottom = (data['safeAreaBottom'] as num?)?.toDouble() ?? 0.0;
          
          // Cache the keyboard height when keyboard is visible
          // This allows sticker/emoji keyboards to use the same height
          if (keyboardHeight > 0) {
            _lastKnownKeyboardHeight = keyboardHeight;
          }
          // Always update safe area bottom
          if (safeAreaBottom > 0) {
            _lastKnownSafeAreaBottom = safeAreaBottom;
          }
          
          callback(keyboardHeight, safeAreaBottom);
        } else if (data is num) {
          // Fallback for old format (just keyboard height)
          final keyboardHeight = data.toDouble();
          if (keyboardHeight > 0) {
            _lastKnownKeyboardHeight = keyboardHeight;
          }
          callback(keyboardHeight, 0.0);
        }
      },
      onError: (error) {
        // Fallback: if platform channel fails, just ignore
        // The composer will fall back to viewInsets
      },
    );
  }

  /// Disposes the plugin and cancels any active subscriptions.
  void dispose() {
    if (_keyboardHeightSubscription != null) {
      _keyboardHeightSubscription!.cancel();
      _keyboardHeightSubscription = null;
      _listenerCount--;
      // Only tear down the shared stream when no listeners remain
      if (_listenerCount <= 0) {
        _sharedStream = null;
        _listenerCount = 0;
      }
    }
  }
}

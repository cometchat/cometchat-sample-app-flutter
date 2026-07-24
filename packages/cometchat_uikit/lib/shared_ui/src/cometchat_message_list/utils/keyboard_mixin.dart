import 'dart:async';
import 'package:flutter/widgets.dart';

/// Mixin for detecting keyboard height changes
///
/// This mixin provides keyboard height detection with debouncing to avoid
/// excessive callbacks during keyboard animation.
///
/// Usage:
/// ```dart
/// class _MyWidgetState extends State<MyWidget>
///     with WidgetsBindingObserver, KeyboardMixin {
///   @override
///   void initState() {
///     super.initState();
///     WidgetsBinding.instance.addObserver(this);
///   }
///
///   @override
///   void dispose() {
///     WidgetsBinding.instance.removeObserver(this);
///     disposeKeyboardMixin();
///     super.dispose();
///   }
///
///   @override
///   void onKeyboardHeightChanged(double height) {
///     // Handle keyboard height change
///   }
/// }
/// ```
mixin KeyboardMixin<T extends StatefulWidget>
    on State<T>, WidgetsBindingObserver {
  /// Timer for debouncing keyboard height changes
  Timer? _keyboardDebounceTimer;

  /// Last known keyboard height
  double _lastKeyboardHeight = 0;

  /// Debounce duration for keyboard height changes
  static const Duration _keyboardDebounceDelay = Duration(milliseconds: 100);

  /// Called when keyboard height changes
  ///
  /// Override this method to handle keyboard height changes.
  /// The height is 0 when keyboard is hidden.
  void onKeyboardHeightChanged(double height);

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _handleMetricsChange();
  }

  /// Handle metrics change with debouncing
  void _handleMetricsChange() {
    _keyboardDebounceTimer?.cancel();
    _keyboardDebounceTimer = Timer(_keyboardDebounceDelay, () {
      if (!mounted) return;

      final view = View.of(context);
      final bottomInset = view.viewInsets.bottom / view.devicePixelRatio;

      if (bottomInset != _lastKeyboardHeight) {
        final previousHeight = _lastKeyboardHeight;
        _lastKeyboardHeight = bottomInset;

        // Only notify if keyboard appeared (height increased from 0)
        // or if keyboard height changed while visible
        if (bottomInset > 0 && previousHeight == 0) {
          onKeyboardHeightChanged(bottomInset);
        } else if (bottomInset > previousHeight && previousHeight > 0) {
          // Keyboard grew (e.g., emoji keyboard)
          onKeyboardHeightChanged(bottomInset - previousHeight);
        }
      }
    });
  }

  /// Dispose the keyboard mixin resources
  ///
  /// Call this in your widget's dispose method.
  void disposeKeyboardMixin() {
    _keyboardDebounceTimer?.cancel();
    _keyboardDebounceTimer = null;
  }

  /// Get the current keyboard height
  double get currentKeyboardHeight => _lastKeyboardHeight;

  /// Check if keyboard is currently visible
  bool get isKeyboardVisible => _lastKeyboardHeight > 0;
}

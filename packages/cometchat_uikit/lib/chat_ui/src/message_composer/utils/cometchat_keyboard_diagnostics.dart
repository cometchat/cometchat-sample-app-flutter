import 'package:flutter/foundation.dart';

/// Source of a keyboard diagnostic event — lets consumers understand which
/// code path inside the composer emitted the sample.
enum CometChatKeyboardDiagnosticsSource {
  /// Emitted from the native keyboard_height plugin callback (Android / iOS
  /// platform channel). Fires earliest, before Flutter's viewInsets update.
  nativePlugin,

  /// Emitted from `didChangeMetrics` when Flutter's `viewInsets` change.
  /// Typically runs after `nativePlugin` for the same keyboard transition.
  viewInsets,

  /// Emitted from `didChangeAppLifecycleState` when the app returns from
  /// background and the composer re-syncs keyboard state.
  appResumed,

  /// Emitted from `activate()` when the composer is re-attached to the tree
  /// (e.g. returning from image viewer / thread screen).
  widgetActivate,
}

/// Snapshot of every keyboard-related value the composer uses at a point in
/// time. Consumers use this to diagnose device-specific spacing issues (extra
/// gap between composer and keyboard, safe-area double-counting, etc.) without
/// instrumenting the UIKit.
///
/// All `*Height` / `*Padding` fields are in logical pixels.
@immutable
class CometChatKeyboardDiagnostics {
  /// Where this sample was captured.
  final CometChatKeyboardDiagnosticsSource source;

  /// Keyboard height reported by the native plugin (already normalised to
  /// logical pixels on Android, native on iOS). Zero when the keyboard is
  /// hidden. May be 0 on web (plugin is a no-op there).
  final double nativeKeyboardHeight;

  /// Safe-area bottom reported by the native plugin (logical pixels).
  /// NOTE: the composer does NOT use this value for layout (see
  /// `composer-big-safe-area-some-devices` fix) — only for diagnostics.
  final double nativeSafeAreaBottom;

  /// `View.of(context).viewInsets.bottom / devicePixelRatio` — Flutter's view
  /// of the keyboard. Kept alongside the native value so consumers can spot
  /// discrepancies (OEM IME insets that include the gesture-nav pill, etc.).
  final double viewInsetsBottom;

  /// `MediaQuery.paddingOf(context).bottom` — Flutter's safe area. The
  /// composer uses this as the single source of truth.
  final double mediaQuerySafeAreaBottom;

  /// The value the composer is writing to its `_bottomPaddingNotifier` — i.e.
  /// the actual padding drawn below the input row.
  final double appliedBottomPadding;

  /// Whether the composer currently considers the keyboard visible.
  final bool isKeyboardVisible;

  /// Cached "stable" keyboard height — set once after the keyboard settles
  /// to avoid jiggle. Re-used for subsequent opens within the same session.
  final double stableKeyboardHeight;

  /// The maximum bottom height observed during the current open session.
  final double maxBottomHeight;

  /// Device pixel ratio when this sample was captured.
  final double devicePixelRatio;

  /// Whether `resizeToAvoidBottomInset` is `true` on the parent Scaffold,
  /// as declared by the composer widget. When `true`, the native plugin path
  /// is skipped and the Scaffold drives the keyboard insets.
  final bool resizeToAvoidBottomInset;

  const CometChatKeyboardDiagnostics({
    required this.source,
    required this.nativeKeyboardHeight,
    required this.nativeSafeAreaBottom,
    required this.viewInsetsBottom,
    required this.mediaQuerySafeAreaBottom,
    required this.appliedBottomPadding,
    required this.isKeyboardVisible,
    required this.stableKeyboardHeight,
    required this.maxBottomHeight,
    required this.devicePixelRatio,
    required this.resizeToAvoidBottomInset,
  });

  @override
  String toString() {
    return 'KbDiag(${source.name} '
        'native=${nativeKeyboardHeight.toStringAsFixed(1)} '
        'nativeSafe=${nativeSafeAreaBottom.toStringAsFixed(1)} '
        'viewInsets=${viewInsetsBottom.toStringAsFixed(1)} '
        'mqSafe=${mediaQuerySafeAreaBottom.toStringAsFixed(1)} '
        'applied=${appliedBottomPadding.toStringAsFixed(1)} '
        'visible=$isKeyboardVisible '
        'stable=${stableKeyboardHeight.toStringAsFixed(1)} '
        'max=${maxBottomHeight.toStringAsFixed(1)} '
        'dpr=${devicePixelRatio.toStringAsFixed(2)} '
        'resizeAvoid=$resizeToAvoidBottomInset)';
  }
}

/// Signature for the keyboard diagnostics callback.
typedef CometChatKeyboardDiagnosticsCallback = void Function(
  CometChatKeyboardDiagnostics diagnostics,
);

import 'package:flutter/foundation.dart';

/// Notifier for tracking message composer height
///
/// This notifier is used to communicate the composer height to the message list
/// so it can adjust its bottom padding accordingly. This ensures messages
/// are not hidden behind the composer.
///
/// Usage:
/// ```dart
/// // In parent widget
/// final composerHeightNotifier = ComposerHeightNotifier();
///
/// // Pass to message list
/// CometChatAnimatedMessageList(
///   composerHeightNotifier: composerHeightNotifier,
///   // ...
/// )
///
/// // Update from composer
/// composerHeightNotifier.setHeight(newHeight);
///
/// // Dispose when done
/// composerHeightNotifier.dispose();
/// ```
class ComposerHeightNotifier extends ChangeNotifier {
  /// Current composer height
  double _height = 0;

  /// Get the current composer height
  double get height => _height;

  /// Set the composer height
  ///
  /// Only notifies listeners if the height actually changed.
  void setHeight(double newHeight) {
    if (_height != newHeight) {
      _height = newHeight;
      notifyListeners();
    }
  }

  /// Reset the height to zero
  void reset() {
    setHeight(0);
  }
}

/// Notifier for tracking loading state during pagination
///
/// This notifier is used to communicate loading state between the message list
/// and loading indicators.
class LoadMoreNotifier extends ChangeNotifier {
  /// Whether currently loading older messages
  bool _isLoadingOlder = false;

  /// Whether currently loading newer messages
  bool _isLoadingNewer = false;

  /// Get whether currently loading older messages
  bool get isLoadingOlder => _isLoadingOlder;

  /// Get whether currently loading newer messages
  bool get isLoadingNewer => _isLoadingNewer;

  /// Set loading older state
  void setLoadingOlder(bool isLoading) {
    if (_isLoadingOlder != isLoading) {
      _isLoadingOlder = isLoading;
      notifyListeners();
    }
  }

  /// Set loading newer state
  void setLoadingNewer(bool isLoading) {
    if (_isLoadingNewer != isLoading) {
      _isLoadingNewer = isLoading;
      notifyListeners();
    }
  }

  /// Reset all loading states
  void reset() {
    _isLoadingOlder = false;
    _isLoadingNewer = false;
    notifyListeners();
  }
}

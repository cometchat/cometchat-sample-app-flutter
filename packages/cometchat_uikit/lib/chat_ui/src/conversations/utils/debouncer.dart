import 'dart:async';

/// Utility class for debouncing rapid function calls
/// Prevents excessive state changes and API calls by delaying execution
/// until a specified duration has passed without new calls
class Debouncer {
  final Duration duration;
  Timer? _timer;

  Debouncer({required this.duration});

  /// Execute a function with debouncing
  /// If called again before the duration expires, the previous call is cancelled
  void call(Function() callback) {
    // Cancel any pending timer
    _timer?.cancel();

    // Schedule the callback to run after the duration
    _timer = Timer(duration, callback);
  }

  /// Cancel any pending debounced call
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Dispose the debouncer and clean up resources
  void dispose() {
    cancel();
  }
}

/// Debouncer that returns a Future for async operations
class AsyncDebouncer {
  final Duration duration;
  Timer? _timer;

  AsyncDebouncer({required this.duration});

  /// Execute an async function with debouncing
  /// Returns a future that completes when the debounced function executes
  Future<void> call(Future<void> Function() callback) {
    // Cancel any pending timer
    _timer?.cancel();

    // Create a completer for this call
    final completer = Completer<void>();

    // Schedule the callback to run after the duration
    _timer = Timer(duration, () async {
      try {
        await callback();
        completer.complete();
      } catch (e) {
        completer.completeError(e);
      }
    });

    return completer.future;
  }

  /// Cancel any pending debounced call
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Dispose the debouncer and clean up resources
  void dispose() {
    cancel();
  }
}

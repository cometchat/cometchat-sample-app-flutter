import 'dart:async';
import 'package:flutter/material.dart';

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({this.milliseconds = 500});

  /// Runs the provided action after [milliseconds] delay.
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  /// Cancels any pending debounced action.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Optionally call this if you dispose a controller using Debouncer.
  void dispose() {
    _timer?.cancel();
  }
}

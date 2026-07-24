/// Main barrel export for Message Information module
///
/// This file exports all public APIs for the message information component,
/// including the widget, style, and BLoC layer (which re-exports domain/data/di).
library;

// Widget exports
export 'widgets/widgets.dart';

// Style
export 'message_information_style.dart';

// BLoC (includes domain, data, and DI re-exports)
export 'bloc/bloc.dart';

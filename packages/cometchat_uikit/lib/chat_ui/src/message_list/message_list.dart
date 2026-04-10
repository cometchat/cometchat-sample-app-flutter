/// Barrel export for message_list module
/// 
/// This module provides the CometChatMessageList component with Clean Architecture.
/// 
/// ## Architecture
/// - BLoC for state management (flutter_bloc)
/// - Repository pattern for data access
/// - Use cases for business logic
/// - Service locator for dependency injection
/// 
/// ## Usage
/// ```dart
/// CometChatMessageList(
///   user: targetUser,
///   messageItemBuilder: (context, message, index, animation) {
///     return MessageBubble(message: message);
///   },
/// )
/// ```

// BLoC exports
export 'bloc/bloc.dart';

// Domain exports
export 'domain/domain.dart';

// Data exports
export 'data/data.dart';

// DI exports
export 'di/di.dart';

// Widget exports
export 'widgets/widgets.dart';

// Style export
export 'cometchat_message_list_style.dart';

// Message option sheet export
export 'cometchat_message_option_sheet.dart';

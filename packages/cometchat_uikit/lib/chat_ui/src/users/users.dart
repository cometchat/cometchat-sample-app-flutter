/// Barrel export for users module with Clean Architecture
///
/// This file provides a single import point for all users module components.
/// Import this file to access all users-related functionality.
///
/// ## Architecture
///
/// The users module uses Clean Architecture with BLoC pattern:
/// - [UsersBloc] for state management
/// - [UsersRepository] for data abstraction
/// - [UsersServiceLocator] for dependency injection
///
/// Example usage:
/// ```dart
/// CometChatUsers(
///   usersBloc: UsersBloc(),
///   onItemTap: (context, user) => print('Tapped: ${user.name}'),
/// );
/// ```

// BLoC
export 'bloc/bloc.dart';

// Domain
export 'domain/domain.dart';

// Data
export 'data/data.dart';

// DI
export 'di/di.dart';

// Widgets
export 'widgets/widgets.dart';

// Main widget
export 'cometchat_users.dart';

// Style
export 'cometchat_users_style.dart';

// Builder protocol
export 'users_builder_protocol.dart';

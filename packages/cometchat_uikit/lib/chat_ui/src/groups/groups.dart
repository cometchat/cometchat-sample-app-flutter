/// Barrel export for groups module with Clean Architecture
///
/// This file provides a single import point for all groups module components.
/// Import this file to access all groups-related functionality.
///
/// ## Migration from GetX to BLoC
///
/// The groups module has been migrated from GetX to Clean Architecture with BLoC.
/// - **New:** Use [GroupsBloc] for state management
/// - **Deprecated:** `CometChatGroupsController` (GetX-based) - will be removed in future
///
/// Example using the new BLoC pattern:
/// ```dart
/// CometChatGroups(
///   groupsBloc: GroupsBloc(),
/// );
/// ```
library;

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

// Main widget (keeping existing for backward compatibility)
export 'cometchat_groups.dart';

// Style (keeping existing)
export 'cometchat_groups_style.dart';

// Builder protocol (keeping existing)
export 'groups_builder_protocol.dart';

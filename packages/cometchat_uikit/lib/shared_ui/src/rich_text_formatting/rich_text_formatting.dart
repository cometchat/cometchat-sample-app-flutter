/// Rich Text Formatting Clean Architecture Module
///
/// This module provides a Clean Architecture implementation for rich text
/// formatting in the CometChat UIKit. It follows the same patterns as the
/// conversations module with BLoC state management.
///
/// ## Architecture
/// - **Domain Layer**: Entities, repository interface, use cases
/// - **Data Layer**: Repository implementation, formatter data sources
/// - **Presentation Layer**: BLoC, events, state
/// - **DI Layer**: Service locator for dependency injection
///
/// ## Usage
/// ```dart
/// // Initialize the service locator
/// RichTextServiceLocator.instance.setup(const RichTextConfiguration());
///
/// // Create a BLoC
/// final bloc = RichTextFormatterBloc();
/// bloc.add(const InitializeFormatter());
///
/// // Apply formatting
/// bloc.add(FormatApplied(
///   formatType: FormatType.bold,
///   text: controller.text,
///   selection: controller.selection,
/// ));
/// ```

// Domain layer exports
export 'domain/domain.dart';

// Data layer exports
export 'data/data.dart';

// BLoC layer exports
export 'bloc/bloc.dart';

// DI layer exports
export 'di/di.dart';

// Presentation layer exports (includes backward compatibility adapter)
export 'presentation/presentation.dart';

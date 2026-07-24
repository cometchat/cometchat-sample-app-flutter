/// Domain layer barrel export for Message Information module
///
/// Exports the repository interface and use cases for the message information
/// following Clean Architecture patterns.
library;

// Repository interface
export 'repositories/message_information_repository.dart';

// Use cases
export 'usecases/fetch_message_receipts_usecase.dart';

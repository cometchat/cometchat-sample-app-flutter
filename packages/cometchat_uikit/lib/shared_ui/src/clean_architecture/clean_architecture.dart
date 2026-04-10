// Clean Architecture - Complete Structure
// This is the main export file for the entire clean architecture

// External Dependencies
export 'package:cometchat_sdk/cometchat_sdk.dart';

// Legacy exports needed by clean architecture
export '../../l10n/translations.dart';
export '../cometchat_ui_kit/cometchat_ui_kit.dart' show CometChatUIKit;

// Core Layer
export 'core/core.dart';

// Domain Layer
export 'domain/domain.dart';

// Data Layer
export 'data/data.dart';

// Presentation Layer
export 'presentation/presentation.dart';

// Services Layer
export 'services/audio_state/domain/entities/audio_state_entity.dart';
export 'services/audio_state/domain/repositories/audio_state_repository.dart';
export 'services/audio_state/domain/usecases/audio_state_usecases.dart';
export 'services/stream/domain/entities/stream_entity.dart';
